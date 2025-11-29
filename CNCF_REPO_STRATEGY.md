# CNCF Repository Strategy for Giru.ai

## Research: How CNCF Projects Handle Open Core Model

Based on research of successful CNCF and open-source projects with commercial offerings, here's what I found:

---

## Model 1: **Separate Repositories** (Recommended for CNCF Submission)

### Examples: Kong, Cilium/Isovalent, Traefik

**Structure:**
- **Open Source Repo**: `github.com/giru-ai/giru` (Apache 2.0)
- **Enterprise Repo**: `github.com/giru-ai/giru-enterprise` (Private, Proprietary)

**Kong Gateway Example:**
- **Kong OSS**: `github.com/Kong/kong` (Apache 2.0, fully open)
- **Kong Enterprise**: Private repository, distributed as binary/Docker images only
- Enterprise source code NOT available on GitHub (requires special license)

**Cilium/Isovalent Example:**
- **Cilium**: `github.com/cilium/cilium` (Apache 2.0, CNCF Graduated)
- **Isovalent Enterprise**: Private repository, separate Docker images
- Isovalent builds on top of open-source Cilium, adds enterprise features

**Traefik/Traefik Enterprise:**
- **Traefik**: `github.com/traefik/traefik` (MIT License, CNCF Incubating)
- **Traefik Enterprise**: Separate private product

### Advantages for CNCF:
✅ Clear separation of open source vs commercial  
✅ Apache 2.0 license covers entire public repo (CNCF requirement)  
✅ No confusion about what's open source  
✅ Community can fully audit open-source code  
✅ Easier governance for CNCF (no license mixing)  
✅ Enterprise features don't pollute open-source repo  
✅ Clean Git history for open-source project  

### Disadvantages:
❌ Code duplication between repos (shared utilities)  
❌ Need to maintain two codebases  
❌ Integration testing across repos is harder  

---

## Model 2: **Same Repository, License-Based Gating** (NOT Recommended for CNCF)

### Examples: Early Grafana (now changed), GitLab CE vs EE (now changed)

**Structure:**
- Single repository with `packages/core/` and `packages/enterprise/`
- Different licenses in subdirectories
- Runtime license checks

**Why This Doesn't Work for CNCF:**

1. **CNCF License Requirements:**
   - CNCF projects MUST be Apache 2.0, MIT, or compatible OSI-approved license
   - Entire submitted project must be under one license
   - Cannot have proprietary code mixed with Apache 2.0 in same repo

2. **Governance Issues:**
   - CNCF Technical Oversight Committee (TOC) governs the project
   - Cannot govern proprietary code
   - Confusion about what's "donated" to CNCF vs what's commercial

3. **Community Trust:**
   - Community expects 100% of CNCF repo to be open source
   - Mixed licensing creates confusion
   - Harder to attract contributors (which license applies?)

4. **Examples of Projects That Changed:**
   - **Elastic**: Moved from Apache 2.0 to SSPL, left open-source ecosystem
   - **GitLab**: Now fully open source (CE and EE in same repo, both MIT)
   - **Grafana**: Enterprise features are plugins, not in main repo

---

## Model 3: **Plugin Architecture** (Alternative for CNCF)

### Examples: Prometheus, Grafana (current model), Vault

**Structure:**
- **Core**: `github.com/giru-ai/giru` (Apache 2.0, CNCF project)
- **Plugins**: 
  - `github.com/giru-ai/giru-plugin-sso` (Proprietary)
  - `github.com/giru-ai/giru-plugin-audit` (Proprietary)
  - `github.com/giru-ai/giru-ui-enterprise` (Proprietary)

**How It Works:**
- Core provides plugin interfaces/hooks
- Enterprise features implemented as loadable plugins
- Core is 100% Apache 2.0 and functional standalone
- Plugins are separate repositories with proprietary licenses

**Grafana Example:**
- **Grafana Core**: `github.com/grafana/grafana` (AGPL v3, fully open)
- **Enterprise Plugins**: Separate distribution (Datadog, Splunk, etc.)
- Documentation for enterprise features lives in main repo
- But enterprise code is separate

### Advantages for CNCF:
✅ Core project is 100% Apache 2.0  
✅ Clear plugin architecture (good for ecosystem)  
✅ Third parties can build commercial plugins too  
✅ Clean separation of concerns  
✅ CNCF governs core, company controls plugins  

### Disadvantages:
❌ Need to design plugin system upfront  
❌ Some features hard to implement as plugins  
❌ Performance overhead from plugin architecture  

---

## Recommended Strategy for Giru.ai CNCF Submission

### **Option A: Separate Repositories (Cleanest for CNCF)**

```
┌─────────────────────────────────────────────────────────────┐
│  Open Source (CNCF Donation)                                │
│  Repository: github.com/giru-ai/giru                        │
│  License: Apache 2.0                                        │
├─────────────────────────────────────────────────────────────┤
│  giru/                                                      │
│  ├── packages/                                              │
│  │   ├── envoy/           # Envoy configs                  │
│  │   ├── opa/             # Core OPA policies              │
│  │   ├── control-plane/  # Go backend (Fiber)              │
│  │   ├── cli/            # CLI tool                        │
│  │   └── web-ui/         # Basic web UI (Svelte)           │
│  ├── deployments/                                           │
│  ├── docs/                                                  │
│  ├── examples/                                              │
│  └── LICENSE            # Apache 2.0                        │
│                                                             │
│  Features:                                                  │
│  ✅ Basic routing and load balancing                        │
│  ✅ API key authentication                                  │
│  ✅ JWT validation                                          │
│  ✅ Basic rate limiting                                     │
│  ✅ Health checking                                         │
│  ✅ Prometheus metrics                                      │
│  ✅ Single-tenant mode                                      │
│  ✅ Basic web UI for configuration                         │
│  ✅ OPA policy engine integration                          │
│  ✅ Tool-level access control (basic)                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Enterprise (Commercial Product)                            │
│  Repository: github.com/giru-ai/giru-enterprise (Private)   │
│  License: Proprietary                                       │
├─────────────────────────────────────────────────────────────┤
│  giru-enterprise/                                           │
│  ├── opa-policies/                                          │
│  │   ├── compliance/    # SOC2, HIPAA, GDPR policies       │
│  │   ├── advanced/      # ML-based, adaptive policies      │
│  │   └── custom/        # Customer-specific policies       │
│  ├── control-plane-extensions/                             │
│  │   ├── auth/          # SSO (SAML, OIDC, Azure AD)       │
│  │   ├── multi-tenancy/ # Tenant isolation                 │
│  │   ├── audit/         # Enhanced audit logging           │
│  │   ├── analytics/     # Advanced analytics & billing     │
│  │   └── license/       # License validation               │
│  ├── web-ui-enterprise/                                     │
│  │   ├── advanced-dashboard/                               │
│  │   ├── compliance-reports/                               │
│  │   └── tenant-management/                                │
│  ├── helm/              # Enterprise Helm charts           │
│  └── LICENSE            # Proprietary                       │
│                                                             │
│  Additional Features:                                       │
│  ✅ SSO (SAML, OIDC, Azure AD, Okta, Google)                │
│  ✅ MFA (TOTP, WebAuthn)                                    │
│  ✅ Multi-tenancy with resource isolation                   │
│  ✅ Compliance policies (SOC2, HIPAA, GDPR)                 │
│  ✅ Advanced audit logging & compliance reporting           │
│  ✅ Advanced analytics and billing metrics                  │
│  ✅ Advanced web UI with tenant management                  │
│  ✅ 24/7 support and SLA guarantees                         │
└─────────────────────────────────────────────────────────────┘
```

### Integration Strategy

**How Enterprise Builds on Open Source:**

```go
// giru-enterprise/main.go
package main

import (
    // Import open-source core
    "github.com/giru-ai/giru/packages/control-plane/pkg/server"
    "github.com/giru-ai/giru/packages/control-plane/pkg/config"
    
    // Import enterprise extensions
    "github.com/giru-ai/giru-enterprise/auth/sso"
    "github.com/giru-ai/giru-enterprise/multitenancy"
    "github.com/giru-ai/giru-enterprise/audit"
    "github.com/giru-ai/giru-enterprise/license"
)

func main() {
    // Load base configuration from open-source
    cfg, _ := config.Load()
    
    // Validate enterprise license
    lic, err := license.Validate()
    if err != nil {
        log.Fatal("Invalid enterprise license")
    }
    
    // Create base server from open-source
    srv := server.New(cfg)
    
    // Register enterprise extensions
    if lic.HasFeature("sso") {
        srv.RegisterAuthProvider(sso.NewSAMLProvider())
        srv.RegisterAuthProvider(sso.NewOIDCProvider())
    }
    
    if lic.HasFeature("multi-tenancy") {
        srv.EnableMultiTenancy(multitenancy.NewManager())
    }
    
    if lic.HasFeature("audit") {
        srv.RegisterAuditLogger(audit.NewEnhancedLogger())
    }
    
    // Start server with enterprise features
    srv.Start()
}
```

**Shared Libraries:**

Create a third repository for shared utilities:

```
github.com/giru-ai/giru-common (Apache 2.0)
  - Common data models
  - Shared utilities
  - API contracts
  - Protocol buffers
```

Both repositories import from `giru-common`.

---

## CNCF Submission Strategy

### Phase 1: Open Source Launch (Before CNCF)
**Months 1-4: Build MVP in Open Source Repo**

```bash
# Repository: github.com/giru-ai/giru
# Focus: Core functionality, 100% Apache 2.0
```

**Deliverables:**
- ✅ Working MCP gateway (Envoy + OPA + Control Plane)
- ✅ CLI tool
- ✅ Basic web UI
- ✅ Documentation
- ✅ Examples and tutorials
- ✅ Deployment manifests (K8s, Docker Compose)
- ✅ CI/CD pipelines
- ✅ Community governance docs (CONTRIBUTING.md, CODE_OF_CONDUCT.md)

**Goals:**
- Build community traction
- Get early adopters
- Demonstrate production readiness
- Gather feedback

### Phase 2: CNCF Sandbox Application
**Month 5: Apply to CNCF Sandbox**

**Requirements for Sandbox:**
1. Apache 2.0 or compatible OSI-approved license ✅
2. Hosted on GitHub under neutral organization ✅
3. Demonstrates adoption (GitHub stars, production users)
4. Clear governance model
5. TOC sponsor (find CNCF TOC member to sponsor)
6. Aligns with CNCF charter (cloud-native infrastructure)

**Submission Checklist:**
- [ ] Transfer repo to `cncf/giru` or keep under `giru-ai/giru` with CLA
- [ ] Sign CNCF CLA (Contributor License Agreement)
- [ ] Document adopters (minimum 3 production users)
- [ ] Create governance documentation
- [ ] Get TOC sponsor
- [ ] Present to CNCF TOC

### Phase 3: Enterprise Product Launch
**Month 6-8: Launch Commercial Offering**

```bash
# Repository: github.com/giru-ai/giru-enterprise (Private)
# Built on top of CNCF open-source project
```

**Positioning:**
- "Enterprise distribution of CNCF Giru project"
- Similar to:
  - Isovalent Enterprise (built on Cilium)
  - Kong Enterprise (built on Kong Gateway)
  - Traefik Enterprise (built on Traefik)

**Marketing Message:**
> "Giru is a CNCF Sandbox project for MCP gateway infrastructure. 
> Giru Enterprise adds production-grade features for Fortune 500 
> enterprises: SSO, compliance policies, multi-tenancy, 24/7 support."

### Phase 4: CNCF Incubation
**Month 12-18: Apply for Incubation**

**Requirements for Incubation:**
1. Documented adopters (minimum 3 production deployments)
2. Healthy growth in contributors and contributions
3. Security audit completed
4. Clear versioning and release process
5. Documented governance
6. Demonstrates substantial ongoing development

### Phase 5: CNCF Graduation
**Month 24-36: Apply for Graduation**

**Requirements for Graduation:**
1. Adopted by large-scale production users
2. Multiple corporate contributors
3. Documented governance process
4. Security audit by third party
5. Core infrastructure dependency
6. Demonstrates maturity and stability

---

## Legal & Licensing Strategy

### Contributor License Agreement (CLA)

**For CNCF Project:**
- Contributors sign CNCF CLA
- Copyright assigned to CNCF or Linux Foundation
- Ensures CNCF can license the code

**For Enterprise:**
- Separate CLA for enterprise contributors
- Copyright retained by Giru Inc.

### Trademark Strategy

**Open Source Project:**
- "Giru" trademark owned by Giru Inc.
- CNCF has usage rights per standard agreement
- Community can use "Giru" to refer to the project

**Commercial Product:**
- "Giru Enterprise" trademark owned by Giru Inc.
- Clear differentiation in branding

### License Compliance

**Open Source (CNCF):**
```
Copyright 2025 The Giru Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

**Enterprise:**
```
Copyright 2025 Giru Inc. All Rights Reserved.

This software is proprietary and confidential. Unauthorized copying,
modification, distribution, or use of this software is strictly prohibited.
```

---

## Revenue Model with CNCF Project

### How to Make Money from Open Source CNCF Project

**1. Enterprise Features (Separate Repo)**
- SSO, compliance, multi-tenancy, advanced UI
- Distributed as binary/Docker images
- Annual subscription: $50K-$500K per year

**2. Support and Services**
- 24/7 support with SLA
- Professional services (implementation, training)
- Dedicated account management

**3. Managed SaaS (Future)**
- Fully managed Giru in the cloud
- Usage-based pricing
- Built on open-source core

**4. Training and Certification**
- Giru Certified Administrator
- Giru Certified Developer
- Training courses

**5. Open Core Model Examples:**
- **Cilium (CNCF)** → Isovalent Enterprise (~$100M funding)
- **Kong Gateway (CNCF)** → Kong Enterprise ($200M+ funding)
- **Traefik (CNCF)** → Traefik Enterprise
- **Prometheus (CNCF)** → Grafana Cloud (built on Prometheus)

---

## Updated Repository Structure

### Recommended: Two Repositories

**Repository 1: giru-ai/giru (Public, Apache 2.0)**
```
giru/
├── LICENSE                     # Apache 2.0
├── README.md                   # CNCF project README
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── GOVERNANCE.md               # CNCF governance
├── SECURITY.md
├── packages/
│   ├── envoy/
│   ├── opa/                    # Core policies only
│   ├── control-plane/          # Core features
│   ├── cli/
│   └── web-ui/                 # Basic UI
├── deployments/
├── docs/
├── examples/
└── tests/
```

**Repository 2: giru-ai/giru-enterprise (Private, Proprietary)**
```
giru-enterprise/
├── LICENSE                     # Proprietary
├── README.md                   # Enterprise README
├── opa-policies/
│   ├── compliance/             # SOC2, HIPAA, GDPR
│   └── advanced/               # ML-based policies
├── control-plane-extensions/
│   ├── auth/                   # SSO
│   ├── multi-tenancy/
│   ├── audit/
│   └── analytics/
├── web-ui-enterprise/          # Advanced UI
├── helm/                       # Enterprise Helm charts
└── tests/
```

**Repository 3: giru-ai/giru-common (Public, Apache 2.0)**
```
giru-common/
├── LICENSE                     # Apache 2.0
├── README.md
├── pkg/
│   ├── models/                 # Shared data models
│   ├── protocols/              # Protocol buffers
│   ├── utils/                  # Shared utilities
│   └── contracts/              # API contracts
└── go.mod
```

---

## Migration Plan from Current Structure

### Step 1: Create New Repositories
```bash
# Create open-source repository
mkdir giru
cd giru
git init

# Move core packages
mv ../nidin/packages/core/* packages/

# Clean up enterprise references
# Remove LICENSE-ENTERPRISE
# Update README
# Add CNCF governance docs

# Commit
git add .
git commit -m "Initial CNCF open source release"
```

### Step 2: Create Enterprise Repository
```bash
# Create private enterprise repository
mkdir giru-enterprise
cd giru-enterprise
git init

# Move enterprise packages
mv ../nidin/packages/enterprise/* .

# Update imports to reference open-source repo
find . -type f -name "*.go" -exec sed -i 's/github.com\/nidin/github.com\/giru-ai\/giru/g' {} \;

# Commit
git add .
git commit -m "Initial enterprise release"
```

### Step 3: Update Build Process
```bash
# Open source builds standalone
cd giru
make build

# Enterprise builds on top of open source
cd giru-enterprise
go mod edit -require github.com/giru-ai/giru@latest
make build-enterprise
```

---

## Examples: How Others Do It

### Cilium (CNCF Graduated) + Isovalent
- **Open Source**: `github.com/cilium/cilium` (Apache 2.0)
- **Enterprise**: Private, distributed as `quay.io/isovalent/cilium-ee`
- **Revenue**: ~$100M funding, enterprise subscriptions
- **CNCF Status**: Graduated (highest level)

### Kong (CNCF Incubating) + Kong Enterprise
- **Open Source**: `github.com/Kong/kong` (Apache 2.0)
- **Enterprise**: Private repository, binary distribution
- **Revenue**: $200M+ funding, IPO in 2021
- **CNCF Status**: Was donated, now separate foundation

### Traefik (CNCF Incubating) + Traefik Enterprise
- **Open Source**: `github.com/traefik/traefik` (MIT)
- **Enterprise**: Private, separate product
- **Revenue**: Enterprise subscriptions
- **CNCF Status**: Incubating

---

## Decision Matrix

| Factor | Same Repo | Separate Repos | Plugin Architecture |
|--------|-----------|----------------|---------------------|
| **CNCF Acceptance** | ❌ Problematic | ✅ Clean | ✅ Clean |
| **License Clarity** | ❌ Confusing | ✅ Clear | ✅ Clear |
| **Maintenance** | ✅ Easier | ⚠️ More work | ⚠️ Complex |
| **Community Trust** | ❌ Lower | ✅ Higher | ✅ Higher |
| **Code Sharing** | ✅ Easy | ⚠️ Via imports | ⚠️ Via interfaces |
| **Enterprise Control** | ⚠️ Mixed | ✅ Full | ✅ Full |
| **Examples** | None in CNCF | Kong, Cilium | Grafana, Vault |

**Recommendation: Separate Repositories** ✅

---

## Action Items

### Immediate (Week 1-2)
- [ ] Create `giru-ai/giru` repository (public, Apache 2.0)
- [ ] Create `giru-ai/giru-common` repository (public, Apache 2.0)
- [ ] Create `giru-ai/giru-enterprise` repository (private, proprietary)
- [ ] Migrate code from current monorepo to new structure
- [ ] Update all imports and build scripts
- [ ] Update documentation to reflect new structure

### Short-term (Month 1-2)
- [ ] Add CNCF governance documentation
- [ ] Create CONTRIBUTING.md and CODE_OF_CONDUCT.md
- [ ] Set up CI/CD for both repositories
- [ ] Document adopters and use cases
- [ ] Create examples and tutorials
- [ ] Build community (GitHub stars, adopters)

### Medium-term (Month 3-5)
- [ ] Find CNCF TOC sponsor
- [ ] Prepare CNCF Sandbox application
- [ ] Complete security audit
- [ ] Document production deployments
- [ ] Build enterprise product on separate repo

### Long-term (Month 6+)
- [ ] Submit to CNCF Sandbox
- [ ] Launch enterprise offering
- [ ] Grow community and contributors
- [ ] Plan for Incubation application

---

## Summary

**For CNCF Success: Use Separate Repositories**

✅ **Open Source (CNCF)**: `giru-ai/giru` - Apache 2.0, community-driven  
✅ **Enterprise**: `giru-ai/giru-enterprise` - Proprietary, commercial  
✅ **Common**: `giru-ai/giru-common` - Shared utilities, Apache 2.0  

This is the proven model used by:
- Cilium/Isovalent (CNCF Graduated, ~$100M funding)
- Kong/Kong Enterprise (CNCF Incubating, IPO'd)
- Traefik/Traefik Enterprise (CNCF Incubating)

This structure:
1. Meets CNCF licensing requirements
2. Builds community trust
3. Enables commercial success
4. Provides clear governance
5. Allows both products to thrive independently
