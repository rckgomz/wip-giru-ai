# Investor Pitch Deck

*The Compliance-First MCP Gateway for US Regulated Industries*

---

## Slide 1: Title Slide

![Giru.ai Logo]

# **Giru.ai**

### The Compliance-First MCP Gateway for US Regulated Industries

**Turning MCP from Compliance Nightmare to Competitive Advantage**

[Contact: Your Name | your.email@giru.ai | LinkedIn]

---

## Slide 2: The Problem

# **US Enterprises Can't Deploy MCP Safely**

### The Binary Choice Killing Innovation:

- **Option A**: Deploy MCP → Face regulatory violations
- **Option B**: Wait for compliance → Fall behind competitors

### The Cost of Getting It Wrong:

- 🏥 **Healthcare breaches**: $10.93M average (IBM)
- 🏛️ **HIPAA violations**: Up to $2M/year + criminal penalties
- 💳 **PCI-DSS failure**: Lose payment processing ability
- 📊 **SOX violations**: CEO/CFO personal liability (20 years)

> 281 US companies flagged AI as material risk (473% YoY increase - SEC)
> 

---

## Slide 3: The Solution

# **Pre-Configured Compliance Blueprints**

### While Others Build Generic Gateways, We Deliver:

✅ **HIPAA Blueprint**: Deploy Monday, pass OCR audit Friday
✅ **PCI-DSS Package**: Tokenization + audit trails built-in
✅ **SOC2 Automation**: Evidence collection on autopilot
✅ **State Compliance**: 50-state privacy law coverage

### Our Architecture:

- **Foundation**: Envoy + OPA (CNCF graduated projects)
- **Secret Sauce**: Industry-specific policy packages
- **Result**: 6 months → 1 week deployment

---

## Slide 4: Market Opportunity

# **$300M+ Addressable Market**

### US AI Governance Market:

- 🌍 **Total US AI Market**: $120B → $450B by 2030
- 🛡️ **Compliance Software**: $51.8B (11.5% CAGR)
- 🎯 **MCP Gateway TAM**: $300M+ growing rapidly

### Our Target Segments:

| Industry | AI Spend | Compliance Pain |
| --- | --- | --- |
| Healthcare | $46B | $10.93M breach cost |
| Financial Services | $31B | $270M/yr compliance |
| Retail/E-commerce | $12B | PCI-DSS mandatory |

> <10% MCP adoption = 90% greenfield opportunity
> 

---

## Slide 5: Product Demo

# **From Zero to Compliant in Minutes**

```
# One-Click HIPAA Compliance
package hipaa.mcp

deny[msg] {
    input.data.phi_records > clinical_need
    msg := "HIPAA violation: Excessive PHI access"
}

audit_required[entry] {
    input.accesses_phi
    entry := generate_ocr_ready_log()
}

```

### Customer Journey:

1. **Connect** MCP servers (2 min)
2. **Select** compliance framework (10 sec)
3. **Deploy** pre-built policies (1 click)
4. **Generate** audit reports (automated)

**Live Demo Available**

---

## Slide 6: Traction & Validation

# **Market Validation**

### Evidence of Demand:

- ✅ **725 healthcare breaches** in 2023 (133M records)
- ✅ **60% lack adequate AI governance** (McKinsey)
- ✅ **$4.88M average US breach cost** (highest globally)
- ✅ **73% prefer buy vs build** for compliance (Deloitte)

### Current Status (Pre-Seed):

- 🎯 Technical architecture validated
- 💻 MVP development starting Q1 2026
- 🏥 Customer discovery with Texas hospitals
- 📅 HIMSS 2026 showcase targeted (March)
- 🚀 Open-source launch Q2 2026

---

## Slide 7: Competition

# **Why We Win**

| Vendor | Funding | Their Approach | Why We Win |
| --- | --- | --- | --- |
| Obot.ai | $35M | Generic gateway | No compliance blueprints |
| TrueFoundry | $21M | Platform play | Not healthcare focused |
| Lunar.dev | $6M | Generic controls | No US-specific compliance |
| Lasso Security | Unknown | Security monitoring only | No governance features |
| IBM | ∞ | Alpha/Beta status | Not production-ready |

### Our Moats:

1. **Domain Expertise**: Pre-built US compliance policies competitors need months to create
2. **Speed to Value**: 1 week deployment vs 6 months configuration
3. **Trust**: CNCF graduated projects (Envoy + OPA)
4. **Focus**: Healthcare/Finance only, not trying to be everything

> First-mover advantage: 6-12 month window before cloud providers enter
> 

---

## Slide 8: Business Model

# **Managed SaaS + Open Source**

### Pricing Tiers:

| Tier | Monthly Price | Target | Features |
| --- | --- | --- | --- |
| **Community** | Free (OSS) | Developers | Self-hosted, basic features |
| **Starter** | $99/mo | Small teams | 10 servers, 100K req/mo |
| **Professional** | $499/mo | Growing companies | 50 servers, 1M req/mo, SSO |
| **Business** | $1,999/mo | Mid-market | 200 servers, HIPAA/PCI-DSS |
| **Enterprise** | Custom | Hospitals, Banks | Dedicated, 99.99% SLA, 24/7 |

### Deployment Model:

- **Managed SaaS**: We host on AWS/GCP/Azure (multi-cloud Kubernetes)
- **Community Edition**: Self-hosted, free forever (Apache 2.0)

### Unit Economics:

- **CAC**: $5K → **LTV**: $60K (12x ratio)
- **Gross Margin**: 85% (SaaS margins)
- **Payback**: 8 months
- **NRR**: 130%+ (usage expansion)

---

## Slide 9: Go-to-Market

# **Land Healthcare, Expand to Finance**

### Phase 1: Healthcare (Q1-Q3 2026)

- 🏥 **Targets**: 6,090 US hospitals, 300 medical centers
- 📍 **Start Local**: Texas Medical Center, DFW systems
- 🤝 **Channel**: HIMSS partnership, Epic/Cerner marketplace
- 💬 **Message**: "HIPAA-compliant in days, not months"

### Phase 2: Financial Services (Q4 2026+)

- 🏦 **Targets**: 4,500 banks, 2,000 fintechs
- 📈 **Leverage**: SOX compliance for public companies
- 🤝 **Channel**: Big 4 partnerships
- 💬 **Message**: "Fed examination ready"

### Distribution:

- AWS/Azure Marketplace (tap cloud budgets)
- Open-source community (developer-led growth)
- Direct enterprise sales (compliance buyers)

---

## Slide 10: Financial Projections

# **Path to $100M ARR**

| Year | Customers | ARR | Key Milestones |
| --- | --- | --- | --- |
| 2026 | 15 | $180K | MVP, first customers |
| 2027 | 75 | $1.5M | SOC2, scale healthcare |
| 2028 | 250 | $7.5M | Add financial services |
| 2029 | 600 | $24M | Multi-vertical, Series B |
| 2030 | 1,200 | $72M | Market leader |

### Funding Need: **$5M Pre-Seed/Seed Round**

- 🛠️ **60%** Engineering (8 developers)
- 📋 **25%** Compliance certifications
- 📈 **15%** Go-to-market

### Exit Potential:

- Strategic buyers: Datadog, Palo Alto, Splunk
- Comparable exits: HashiCorp ($6.4B), Kong ($2B)

---

## Slide 11: Team

# **Why We'll Win**

### Core Team:

**[Your Name]** - CEO

- [Your relevant experience]
- Fidelity Fintech Innovation
- Domain expertise in regulated industries

**[CTO Name]** - CTO

- [Technical credentials]
- Envoy/OPA experience
- Previous exit/experience

**[Advisor 1]** - Advisor

- [Healthcare/Compliance expertise]

**[Advisor 2]** - Advisor

- [Enterprise sales experience]

### Unfair Advantages:

- 📍 **Location**: Texas (largest medical center globally)
- 🏢 **Network**: Fidelity connections to finance
- 🧠 **Expertise**: Deep regulatory knowledge
- ⚡ **Speed**: Ready to ship in 90 days

---

## Slide 12: The Ask

# **$5M Pre-Seed to Own US MCP Compliance**

### Why Now:

⏰ **Regulatory Deadlines**

- Q1 2026: HIPAA Security Rule updates expected
- Q2 2026: State AI laws expanding (CA, CO, IL)
- Q3 2026: Financial sector AI guidance
- Year-round: SOX compliance for 4,000+ public companies

🚀 **Market Timing**

- MCP only 12 months old (Nov 2024 launch)
- <10% enterprise adoption = massive greenfield
- No dominant player emerged
- 6-12 month window before cloud providers integrate MCP

### Use of Funds:

Build the compliance layer every US enterprise needs

### Next Steps:

1. **Discuss** technical approach
2. **Validate** with your healthcare portfolio
3. **Connect** us with compliance experts

📧 **Contact**: [your.email@giru.ai]

---

## Appendix Slides (If Needed)

### A1: Regulatory Deep Dive

- Federal: HIPAA, PCI-DSS, SOX, FTC
- State: California, New York, Illinois, Colorado, Texas
- Industry: FDA, OCC, FINRA, CMS

### A2: Technical Architecture

- Envoy: 100K+ RPS, <10ms latency
- OPA: Declarative policies, GitOps ready
- Integration: REST API, SDK, CLI

### A3: Customer Quotes

*[Add actual quotes from discovery calls]*

### A4: Financial Model Detail

*[Detailed P&L, cash flow, assumptions]*
