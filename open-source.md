I'll search for information on how companies manage open-source projects with proprietary enterprise features.Let me search more specifically for how companies handle open-source with proprietary enterprise features.Now let me search for practical implementation details about repository structure.Let me search for more specific information about monorepo vs separate repository approaches for open core.Let me search for specific examples of how companies structure their repositories.Based on my research, I can now provide you with comprehensive guidance on managing an open-source project with proprietary enterprise features. Let me explain the common approaches and practical implementation strategies.

## Managing Open Source with Enterprise Features on GitHub

There are several established approaches used by successful companies. Here's what I found:

### **1. The "Open Core" Business Model**

This is the most common approach for your situation. The open-core model involves offering a "core" or feature-limited version of software as free and open-source, while offering paid versions or add-ons as proprietary software.

### **2. Repository Structure Options**

You have three main architectural approaches:

#### **Option A: Single Repository (Monorepo)** - Most Common
This is what companies like Elastic and GitLab use:

Elastic's repository uses per-file licensing headers, with source code covered by multiple licenses including AGPL, SSPL, and Elastic License 2.0, with the specific license noted in each file's header. Elastic also designates certain folders (like "x-pack") as containing Commercial Software under proprietary licenses.

**How it works:**
- All code (open source + enterprise) lives in one repository
- Use directory structure to separate features (e.g., `/core` vs `/enterprise`)
- License files at the directory or file level control what's open vs proprietary
- Build system compiles different editions from the same codebase

**Pros:**
- Easier development workflow
- Shared code between editions
- Single CI/CD pipeline
- Community can see (but not use without license) enterprise code

**Cons:**
- Enterprise code is visible (source-available but not open source)
- More complex licensing management

#### **Option B: Separate Repositories**
- Public repo: Open source core
- Private repo: Enterprise features
- Use Git submodules or similar to combine during build

**Pros:**
- Clear separation
- Enterprise code truly private
- Simpler licensing per repo

**Cons:**
- More complex workflow requiring submodules, with separate commits for public and internal changes
- Harder to share code between editions
- More overhead maintaining two repos

#### **Option C: Plugin Architecture**
Define extension points in the open source version and implement internal features as plugins that are inserted at runtime or during the internal build process.

### **3. Feature Segmentation Strategy**

The "Buyer-Based Open Core" framework determines which features are open source versus proprietary based on who cares most about them - features appealing to individual contributors are open source and free, while features appealing to management or executives are proprietary.

**Think of it like a wedding cake analogy**: The base layers (core functionality) that everyone enjoys are open source. The decorative top tier (enterprise features like SSO, advanced security, compliance tools, management dashboards) that organizations specifically need is proprietary.

For your MCP gateway, this might mean:
- **Open Source**: Basic gateway functionality, routing, protocol support, basic observability
- **Enterprise**: Advanced security features, enterprise SSO/SAML, centralized management console, audit logging, SLA guarantees, premium support

### **4. Practical Implementation (Recommended Approach)**

**Single Repository with License-Based Gating:**

```
/your-mcp-gateway/
├── LICENSE-CORE (Apache 2.0 or MIT)
├── LICENSE-ENTERPRISE (Proprietary)
├── README.md
├── /packages/
│   ├── /core/ (open source)
│   │   ├── LICENSE -> ../../LICENSE-CORE
│   │   └── ... core features
│   └── /enterprise/ (proprietary)
│       ├── LICENSE -> ../../LICENSE-ENTERPRISE
│       └── ... enterprise features
├── /build/
│   ├── build-community.ts
│   └── build-enterprise.ts
```

**License checking in code:**
```typescript
// Runtime license validation
class LicenseManager {
  isEnterpriseFeatureEnabled(feature: string): boolean {
    // Check license key/file
    // Return true only if valid enterprise license
  }
}

// Feature gating
if (licenseManager.isEnterpriseFeatureEnabled('advanced-security')) {
  // Enable enterprise feature
}
```

### **5. Legal Protection**

Use a Contributor License Agreement (CLA) where contributors either assign copyright to your company or grant you an unlimited, non-exclusive license to use contributions, allowing you to include them in both open and proprietary versions.

### **6. Communication Strategy**

Be transparent about the open core approach, actively working to grow participation and not saying no by default to having paid features potentially contributed to the open source project. Document clearly what's open vs. enterprise.

### **My Recommendation for Your MCP Gateway**

1. **Use a single repository** (monorepo) - it's the industry standard for this model
2. **Structure by feature domains** with clear `/core` and `/enterprise` directories
3. **License files per directory** - MIT/Apache for core, proprietary for enterprise
4. **Build separate distributions** - community edition and enterprise edition from same source
5. **Runtime license checking** - enterprise features check for valid license keys
6. **Be transparent** - document what's in each edition clearly

This approach works backward from your end goal (as you prefer in planning): Your end goal is a sustainable business, which requires enterprise revenue, which requires protected enterprise features, which is best achieved through a single-repo open-core model with clear licensing boundaries.

Would you like me to elaborate on any of these approaches or discuss the specific features you're planning for your MCP gateway?
