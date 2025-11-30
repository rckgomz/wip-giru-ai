# ADR-001: Identity and Access Management

**Status:** Accepted  
**Date:** 2024-11-30  
**Decision:** Use Zitadel for all editions; enterprise features in private repo only

---

## Context

Giru MCP Gateway has three authentication layers:

| Layer | Purpose | Challenge |
|-------|---------|-----------|
| Layer 1 | User → Giru Gateway | Need SSO, MFA for enterprise |
| Layer 2 | Client/Agent → Giru | API authentication |
| Layer 3 | Giru → MCP Servers | Credential management (Vault) |

We evaluated several IAM solutions for Layers 1 and 2:

- **Keycloak**: Mature, full-featured, Java-based, heavy
- **Zitadel**: Modern, Go-native, Kubernetes-friendly, comprehensive APIs
- **Ory Kratos**: Lightweight, Go-native, less mature
- **Authelia**: Simple, limited enterprise features
- **Custom OIDC**: Full control, significant development effort

---

## Decision

### All Editions Use Zitadel

Zitadel is the identity provider for all deployment models. The difference is **which features are implemented**, not the underlying IAM.

### Feature Code Separation (CRITICAL)

| Feature | `giru` (Open Source) | `giru-enterprise` (Private) |
|---------|---------------------|----------------------------|
| Basic Zitadel OIDC | ✅ Code here | Imports from OSS |
| Username/password login | ✅ Code here | Imports from OSS |
| Session API integration | ✅ Code here | Imports from OSS |
| SSO federation (SAML/OIDC) | ❌ **Not present** | ✅ Code here |
| MFA enforcement | ❌ **Not present** | ✅ Code here |
| Social login providers | ❌ **Not present** | ✅ Code here |
| IdP management UI | ❌ **Not present** | ✅ Code here |

**Enterprise feature code MUST NOT exist in the open-source repository.**

---

## Why This Separation?

### The Problem

If enterprise feature code exists in the open-source repo (even behind feature flags), anyone can:
1. Clone the repo
2. Remove the license check
3. Rebuild with all features enabled

### The Solution

**Code that doesn't exist cannot be enabled.**

```
┌─────────────────────────────────────────────────────────────────┐
│                     giru (Open Source)                          │
│  • Basic Zitadel OIDC authentication                           │
│  • Username/password login via Session API                     │
│  • User profile management                                     │
│  • NO SSO, MFA, Social login code                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ imported by
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  giru-enterprise (Private)                      │
│  • Imports all OSS functionality                               │
│  • ADDS: SSO federation service                                │
│  • ADDS: MFA enforcement service                               │
│  • ADDS: Social provider management                            │
│  • ADDS: IdP configuration UI components                       │
│  • License validation (phone-home or signed JWT)               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Architecture

### Open Source: Basic Auth Interface

```go
// giru/internal/auth/provider.go
package auth

type Provider interface {
    // Basic authentication - available to all
    Authenticate(ctx context.Context, creds Credentials) (*Session, error)
    ValidateToken(ctx context.Context, token string) (*Claims, error)
    RefreshToken(ctx context.Context, refreshToken string) (*TokenPair, error)
    Logout(ctx context.Context, sessionID string) error
    
    // User management - available to all
    GetUser(ctx context.Context, userID string) (*User, error)
    UpdateUser(ctx context.Context, user *User) error
}

// ZitadelProvider implements Provider with basic OIDC
type ZitadelProvider struct {
    issuer    string
    clientID  string
    // ... basic config
}
```

### Enterprise: Extended Interface (Private Repo)

```go
// giru-enterprise/internal/auth/enterprise.go
package auth

import (
    "github.com/giru-ai/giru/internal/auth" // Import OSS
)

// EnterpriseProvider extends the base Provider
type EnterpriseProvider interface {
    auth.Provider // Embed base interface
    
    // SSO Federation - ENTERPRISE ONLY
    ConfigureSSO(ctx context.Context, config *SSOConfig) error
    ListIdentityProviders(ctx context.Context) ([]*IdentityProvider, error)
    TestSSOConnection(ctx context.Context, idpID string) (*SSOTestResult, error)
    
    // MFA - ENTERPRISE ONLY
    EnforceMFA(ctx context.Context, orgID string, policy *MFAPolicy) error
    GetMFAStatus(ctx context.Context, userID string) (*MFAStatus, error)
    
    // Social Login - ENTERPRISE ONLY
    AddSocialProvider(ctx context.Context, provider *SocialProvider) error
    ListSocialProviders(ctx context.Context) ([]*SocialProvider, error)
}

// EnterpriseZitadelProvider implements EnterpriseProvider
type EnterpriseZitadelProvider struct {
    *auth.ZitadelProvider // Embed OSS provider
    license  *License
    mgmtAPI  *zitadel.ManagementClient
}

func (p *EnterpriseZitadelProvider) ConfigureSSO(ctx context.Context, cfg *SSOConfig) error {
    // Validate license first
    if err := p.license.RequireFeature("sso"); err != nil {
        return err
    }
    
    // Actual SSO configuration via Zitadel Management API
    return p.mgmtAPI.AddGenericOIDCProvider(ctx, &mgmt.AddGenericOIDCProviderRequest{
        Name:         cfg.Name,
        Issuer:       cfg.Issuer,
        ClientId:     cfg.ClientID,
        ClientSecret: cfg.ClientSecret,
    })
}
```

### UI Component Separation

```
giru/web-ui/src/
├── routes/
│   ├── login/           # Basic login form (OSS)
│   ├── profile/         # User profile (OSS)
│   └── settings/        # Basic settings (OSS)

giru-enterprise/web-ui/src/
├── routes/
│   ├── settings/
│   │   ├── sso/         # SSO configuration (Enterprise)
│   │   ├── mfa/         # MFA policies (Enterprise)
│   │   └── social/      # Social providers (Enterprise)
```

---

## Deployment Models

### Managed SaaS (Your Cloud)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Giru Managed SaaS                           │
├─────────────────────────────────────────────────────────────────┤
│  • You control everything                                       │
│  • Features gated by billing system (Stripe, etc.)             │
│  • UNBYPASSABLE - customers don't have the code                │
│  • Free tier: Basic auth                                       │
│  • Paid tier: SSO, MFA, Social login                           │
└─────────────────────────────────────────────────────────────────┘
```

### Enterprise Self-Hosted

```
┌─────────────────────────────────────────────────────────────────┐
│                  Enterprise Self-Hosted                         │
├─────────────────────────────────────────────────────────────────┤
│  • Customer runs giru-enterprise binary                        │
│  • License key validation (signed JWT or phone-home)           │
│  • Legal protection via commercial license agreement           │
│  • They pay for: features + support + updates + security       │
│  • Tampering = license violation = legal action                │
└─────────────────────────────────────────────────────────────────┘
```

### Community Self-Hosted

```
┌─────────────────────────────────────────────────────────────────┐
│                  Community Self-Hosted                          │
├─────────────────────────────────────────────────────────────────┤
│  • Customer runs giru (OSS) binary                             │
│  • Basic Zitadel auth works perfectly                          │
│  • SSO/MFA/Social code DOES NOT EXIST in this binary           │
│  • Cannot enable what isn't there                              │
│  • Upgrade path: Purchase enterprise license                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## License Validation (Enterprise)

```go
// giru-enterprise/internal/license/validator.go
package license

type License struct {
    CustomerID   string    `json:"customer_id"`
    Features     []string  `json:"features"`
    ExpiresAt    time.Time `json:"expires_at"`
    MaxTenants   int       `json:"max_tenants"`
    Signature    string    `json:"signature"` // RSA signature
}

type Validator struct {
    publicKey *rsa.PublicKey
    apiURL    string // Optional: phone-home validation
}

func (v *Validator) Validate(lic *License) error {
    // 1. Check signature (works offline)
    if err := v.verifySignature(lic); err != nil {
        return ErrInvalidLicense
    }
    
    // 2. Check expiration
    if time.Now().After(lic.ExpiresAt) {
        return ErrLicenseExpired
    }
    
    // 3. Optional: Phone-home validation (for revocation)
    if v.apiURL != "" {
        if err := v.validateOnline(lic); err != nil {
            // Log warning but don't fail (allow offline operation)
            log.Warn("online validation failed", "error", err)
        }
    }
    
    return nil
}

func (l *License) RequireFeature(feature string) error {
    for _, f := range l.Features {
        if f == feature {
            return nil
        }
    }
    return fmt.Errorf("feature %q not licensed", feature)
}

// Feature constants
const (
    FeatureSSO           = "sso"
    FeatureMFA           = "mfa"
    FeatureSocialLogin   = "social_login"
    FeatureMultiTenancy  = "multi_tenancy"
    FeatureAdvancedAudit = "advanced_audit"
)
```

---

## Why Zitadel Over Keycloak

| Factor | Zitadel | Keycloak |
|--------|---------|----------|
| Language | Go (matches our stack) | Java |
| Resource usage | Lighter (~256MB) | Heavier (~512MB-1GB) |
| Kubernetes | Cloud-native, CRDs | Requires operator |
| Custom login UI | Session API (embedded) | Redirect-based only |
| API-first | Full REST/gRPC APIs | Admin REST API |
| Multi-tenancy | Native Organizations | Realms (heavier) |
| Startup time | Fast | Slow (~30s cold start) |

### Key Advantage: Session API

Zitadel's Session API allows building a **fully integrated login experience** within Giru's Admin UI - no redirects to external login pages:

```typescript
// Custom login embedded in Giru Admin UI
const session = await zitadel.post('/v2/sessions', {
  checks: {
    user: { loginName: email },
    password: { password }
  }
});
```

---

## Zitadel APIs for Giru Integration

| API | Endpoint | OSS | Enterprise |
|-----|----------|-----|------------|
| **Session API** | `/v2/sessions` | ✅ Login | ✅ Login |
| **Auth API** | `/auth/v1/*` | ✅ Profile | ✅ Profile + MFA |
| **Management API** | `/management/v1/*` | ✅ Basic users | ✅ Full (IdPs, policies) |
| **OIDC** | `/oauth/v2/*` | ✅ Basic | ✅ + Federation |
| **Admin API** | `/admin/v1/*` | ❌ | ✅ Instance settings |

---

## Configuration

```yaml
# All editions - basic Zitadel config
auth:
  provider: zitadel
  zitadel:
    issuer: https://auth.giru.dev
    project_id: "giru-gateway"
    client_id: ${ZITADEL_CLIENT_ID}
    client_secret: ${ZITADEL_CLIENT_SECRET}

# Enterprise only - extended config (giru-enterprise)
enterprise:
  license_path: /etc/giru/license.jwt
  features:
    sso:
      enabled: true
      default_redirect: /dashboard
    mfa:
      enforce: true
      grace_period: 7d
    social:
      providers:
        - github
        - google
```

---

## Tenant ↔ Zitadel Organization Mapping

```go
// On user login, extract tenant from Zitadel token claims
func extractTenantFromToken(claims jwt.MapClaims) string {
    if orgID, ok := claims["urn:zitadel:iam:org:id"].(string); ok {
        return orgID
    }
    return ""
}

// When creating a Giru tenant, create matching Zitadel organization
func (s *TenantService) Create(ctx context.Context, tenant *Tenant) error {
    // 1. Create in Giru database
    if err := s.db.CreateTenant(ctx, tenant); err != nil {
        return err
    }
    
    // 2. Create matching Zitadel organization
    org, err := s.zitadel.CreateOrganization(ctx, &mgmt.AddOrgRequest{
        Name: tenant.Name,
    })
    if err != nil {
        return fmt.Errorf("create zitadel org: %w", err)
    }
    
    // 3. Store Zitadel org ID reference
    tenant.ZitadelOrgID = org.Id
    return s.db.UpdateTenant(ctx, tenant)
}
```

---

## References

- [Zitadel API Overview](https://zitadel.com/docs/apis/introduction)
- [Zitadel Management API](https://zitadel.com/docs/apis/resources/mgmt)
- [Zitadel Session API (Custom Login)](https://zitadel.com/docs/guides/integrate/login/login-users)
- [Access Zitadel APIs](https://zitadel.com/docs/guides/integrate/zitadel-apis/access-zitadel-apis)

---

## Consequences

### Positive
- Enterprise features cannot be "unlocked" in OSS (code doesn't exist)
- Clear monetization path for enterprise customers
- Same Zitadel base for all editions (consistent UX)
- Custom login UI possible (no redirect UX)
- Go-native, lighter than Keycloak

### Negative
- Two codebases to maintain (OSS + Enterprise)
- Must carefully design interfaces for extension
- Enterprise customers need separate distribution channel

### Risks
- Feature creep into OSS (mitigate: strict code review, CI checks)
- Zitadel API changes (mitigate: version lock, integration tests)
- License bypass attempts (mitigate: legal terms, signed binaries)
