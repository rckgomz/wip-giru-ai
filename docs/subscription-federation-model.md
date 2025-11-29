# Subscription-Based Federated Authorization Model

## Problem Statement

**Traditional Model (Bad):**
```
Client → needs to know MCP endpoint
Client → needs MCP authentication credentials
Client → needs to manage multiple MCP connections
Client → tightly coupled to MCP implementations
```

**Subscription Model (Good):**
```
Client → "I want to use tool github__list_repos"
Gateway → Checks subscriptions: "Client has access via Subscription A to MCP-GitHub"
Gateway → Routes request to MCP-GitHub
Gateway → Returns result to client
Client → Never knew about MCP-GitHub
```

## Architecture

### Registration Flow

```
1. Platform Admin registers MCP Server:
   POST /api/v1/mcp-servers
   {
     "name": "github-integration",
     "endpoint": "grpc://github-mcp.internal:50051",
     "tools": [
       {"name": "github__list_repos", ...},
       {"name": "github__create_issue", ...}
     ]
   }

2. Tenant Admin registers Client:
   POST /api/v1/clients
   {
     "name": "sales-agent-001",
     "type": "agent"
   }
   Response: { "id": "client-123", "api_key": "giru_..." }

3. Tenant Admin creates Subscription:
   POST /api/v1/subscriptions
   {
     "client_id": "client-123",
     "mcp_server_id": "mcp-456",
     "scope": {
       "tools": ["github__list_repos", "github__create_issue"]
     },
     "limits": {
       "requests_per_second": 10,
       "max_requests_per_day": 1000
     }
   }
   Response: { "subscription_id": "sub-789", "status": "active" }
```

### Execution Flow

```
4. Client executes tool (doesn't know about MCP):
   POST /api/v1/tools/execute
   Authorization: Bearer giru_client_123_...
   {
     "tool": "github__list_repos",
     "arguments": {
       "owner": "anthropics"
     }
   }

5. Gateway resolution process:
   a) Authenticate client → get client_id
   b) Query: "Which subscriptions does client_id have?"
   c) Query: "Which MCP provides tool 'github__list_repos'?"
   d) Match: subscription_id=sub-789 grants access
   e) Check rate limits on subscription
   f) Route to MCP endpoint via subscription
   g) Return result to client
```

## Database Schema (Simplified)

```sql
-- MCP Servers registered in the platform
CREATE TABLE mcp_servers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    
    -- Connection details (client never sees this)
    endpoint_url VARCHAR(500) NOT NULL,
    protocol VARCHAR(50) NOT NULL DEFAULT 'grpc',
    
    -- Server-to-server authentication
    auth_type VARCHAR(50) NOT NULL, -- 'mtls', 'jwt', 'api_key'
    auth_config JSONB, -- Credentials to authenticate WITH the MCP
    
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, name)
);

-- Tools that MCP servers provide
CREATE TABLE mcp_tools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mcp_server_id UUID NOT NULL REFERENCES mcp_servers(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL, -- e.g., "github__list_repos"
    display_name VARCHAR(255),
    description TEXT,
    input_schema JSONB NOT NULL,
    
    -- Tool metadata
    category VARCHAR(100),
    tags TEXT[],
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(mcp_server_id, name),
    
    -- Global index for tool name lookup
    INDEX idx_tools_name (name)
);

-- Clients that can consume tools
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    client_type VARCHAR(50) NOT NULL, -- 'agent', 'application', 'user'
    
    -- Client authentication (to authenticate TO the gateway)
    api_key_hash VARCHAR(255) NOT NULL,
    
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, name),
    INDEX idx_clients_tenant (tenant_id)
);

-- Subscriptions: Access grants from Client → MCP Server
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- The relationship
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    mcp_server_id UUID NOT NULL REFERENCES mcp_servers(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Scope: Which tools can be accessed
    scope_type VARCHAR(50) NOT NULL DEFAULT 'selective', -- 'all', 'selective'
    scope_tools TEXT[], -- Array of tool names, e.g., ['github__list_repos']
    
    -- Limits
    rate_limit_rps INTEGER, -- Requests per second
    quota_per_day INTEGER, -- Max requests per day
    
    -- Additional constraints
    constraints JSONB, -- { "max_file_size": 10485760, "allowed_regions": ["us-east-1"] }
    
    -- Lifecycle
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    starts_at TIMESTAMP,
    expires_at TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- A client can only have one subscription to an MCP (or named subscriptions)
    UNIQUE(client_id, mcp_server_id, name),
    
    INDEX idx_subscriptions_client (client_id),
    INDEX idx_subscriptions_mcp (mcp_server_id),
    INDEX idx_subscriptions_status (status)
);

-- Subscription usage tracking (for rate limiting, quotas, billing)
CREATE TABLE subscription_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    
    tool_name VARCHAR(255) NOT NULL,
    request_id UUID NOT NULL,
    
    duration_ms INTEGER,
    status_code INTEGER,
    tokens_used INTEGER,
    
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_usage_subscription_time (subscription_id, timestamp DESC),
    INDEX idx_usage_day (subscription_id, DATE(timestamp))
);
```

## Critical Functions

### 1. Resolve Tool to Subscription

```sql
-- Find which subscription allows a client to access a tool
CREATE OR REPLACE FUNCTION resolve_tool_subscription(
    p_client_id UUID,
    p_tool_name VARCHAR
) RETURNS TABLE (
    subscription_id UUID,
    mcp_server_id UUID,
    mcp_endpoint VARCHAR,
    mcp_auth_config JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id AS subscription_id,
        s.mcp_server_id,
        m.endpoint_url AS mcp_endpoint,
        m.auth_config AS mcp_auth_config
    FROM subscriptions s
    JOIN mcp_servers m ON s.mcp_server_id = m.id
    JOIN mcp_tools t ON t.mcp_server_id = m.id
    WHERE s.client_id = p_client_id
      AND t.name = p_tool_name
      AND s.status = 'active'
      AND m.status = 'active'
      AND (s.starts_at IS NULL OR s.starts_at <= NOW())
      AND (s.expires_at IS NULL OR s.expires_at > NOW())
      AND (
          -- Full access to all tools
          s.scope_type = 'all'
          -- Or tool is explicitly in scope
          OR (s.scope_type = 'selective' AND p_tool_name = ANY(s.scope_tools))
      )
    LIMIT 1; -- Return first matching subscription
END;
$$ LANGUAGE plpgsql;
```

### 2. Check Rate Limit

```sql
-- Check if subscription has exceeded rate limit
CREATE OR REPLACE FUNCTION check_rate_limit(
    p_subscription_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_limit INTEGER;
    v_current_rate INTEGER;
BEGIN
    -- Get rate limit from subscription
    SELECT rate_limit_rps INTO v_limit
    FROM subscriptions
    WHERE id = p_subscription_id;
    
    -- If no limit set, allow
    IF v_limit IS NULL THEN
        RETURN TRUE;
    END IF;
    
    -- Count requests in last second
    SELECT COUNT(*) INTO v_current_rate
    FROM subscription_usage
    WHERE subscription_id = p_subscription_id
      AND timestamp >= NOW() - INTERVAL '1 second';
    
    RETURN v_current_rate < v_limit;
END;
$$ LANGUAGE plpgsql;
```

### 3. Check Daily Quota

```sql
-- Check if subscription has exceeded daily quota
CREATE OR REPLACE FUNCTION check_daily_quota(
    p_subscription_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_quota INTEGER;
    v_used_today INTEGER;
BEGIN
    -- Get quota from subscription
    SELECT quota_per_day INTO v_quota
    FROM subscriptions
    WHERE id = p_subscription_id;
    
    -- If no quota set, allow
    IF v_quota IS NULL THEN
        RETURN TRUE;
    END IF;
    
    -- Count requests today
    SELECT COUNT(*) INTO v_used_today
    FROM subscription_usage
    WHERE subscription_id = p_subscription_id
      AND DATE(timestamp) = CURRENT_DATE;
    
    RETURN v_used_today < v_quota;
END;
$$ LANGUAGE plpgsql;
```

## Request Flow Implementation

### Step 1: Client Request

```http
POST /api/v1/tools/execute
Authorization: Bearer giru_sk_abc123...
Content-Type: application/json

{
  "tool": "github__list_repos",
  "arguments": {
    "owner": "anthropics"
  }
}
```

### Step 2: Gateway Handler (Go)

```go
// packages/core/control-plane/internal/handlers/tools.go
package handlers

import (
    "context"
    "github.com/gofiber/fiber/v2"
)

type ToolHandler struct {
    db        *db.DB
    opa       *OPAClient
    mcpClient *MCPClient
}

func (h *ToolHandler) ExecuteTool(c *fiber.Ctx) error {
    ctx := c.UserContext()
    
    // 1. Extract client_id (set by auth middleware)
    clientID := c.Locals("client_id").(string)
    
    // 2. Parse request
    var req struct {
        Tool      string                 `json:"tool"`
        Arguments map[string]interface{} `json:"arguments"`
    }
    if err := c.BodyParser(&req); err != nil {
        return fiber.ErrBadRequest
    }
    
    // 3. Resolve: Which subscription allows this client to access this tool?
    resolution, err := h.db.Queries.ResolveToolSubscription(ctx, db.ResolveToolSubscriptionParams{
        ClientID: clientID,
        ToolName: req.Tool,
    })
    if err != nil {
        return fiber.NewError(fiber.StatusForbidden, 
            "No active subscription found for tool: " + req.Tool)
    }
    
    // 4. Check rate limit
    if !h.checkRateLimit(ctx, resolution.SubscriptionID) {
        return fiber.NewError(fiber.StatusTooManyRequests, 
            "Rate limit exceeded for subscription")
    }
    
    // 5. Check daily quota
    if !h.checkDailyQuota(ctx, resolution.SubscriptionID) {
        return fiber.NewError(fiber.StatusTooManyRequests, 
            "Daily quota exceeded for subscription")
    }
    
    // 6. Check OPA policies (additional constraints)
    allowed, err := h.opa.Evaluate(ctx, map[string]interface{}{
        "action": "execute_tool",
        "client": map[string]interface{}{
            "id":        clientID,
            "tenant_id": c.Locals("tenant_id"),
        },
        "subscription": map[string]interface{}{
            "id": resolution.SubscriptionID,
        },
        "tool": map[string]interface{}{
            "name": req.Tool,
        },
        "arguments": req.Arguments,
    })
    
    if err != nil || !allowed {
        return fiber.NewError(fiber.StatusForbidden, 
            "Policy denied execution")
    }
    
    // 7. Execute tool on the MCP server
    // Client never knows about the MCP endpoint - gateway handles it
    result, metadata, err := h.mcpClient.CallTool(ctx, &MCPRequest{
        Endpoint:      resolution.MCPEndpoint,
        AuthConfig:    resolution.MCPAuthConfig, // Gateway authenticates to MCP
        ToolName:      req.Tool,
        Arguments:     req.Arguments,
        
        // Pass context for audit trail
        ExecutionContext: &ExecutionContext{
            ClientID:       clientID,
            SubscriptionID: resolution.SubscriptionID,
            RequestID:      c.Locals("request_id").(string),
        },
    })
    
    if err != nil {
        // Record failed attempt
        h.recordUsage(ctx, resolution.SubscriptionID, req.Tool, 
            c.Locals("request_id").(string), 0, 500, 0)
        return fiber.NewError(fiber.StatusBadGateway, "Tool execution failed")
    }
    
    // 8. Record usage for rate limiting, quotas, billing
    h.recordUsage(ctx, resolution.SubscriptionID, req.Tool,
        c.Locals("request_id").(string), 
        int(metadata.Duration.Milliseconds()),
        200,
        metadata.TokensUsed,
    )
    
    // 9. Return result to client
    return c.JSON(fiber.Map{
        "result": result,
        "metadata": fiber.Map{
            "duration_ms": metadata.Duration.Milliseconds(),
            "tokens_used": metadata.TokensUsed,
        },
    })
}

func (h *ToolHandler) checkRateLimit(ctx context.Context, subID string) bool {
    var allowed bool
    err := h.db.Pool.QueryRow(ctx, "SELECT check_rate_limit($1)", subID).Scan(&allowed)
    return err == nil && allowed
}

func (h *ToolHandler) checkDailyQuota(ctx context.Context, subID string) bool {
    var allowed bool
    err := h.db.Pool.QueryRow(ctx, "SELECT check_daily_quota($1)", subID).Scan(&allowed)
    return err == nil && allowed
}

func (h *ToolHandler) recordUsage(ctx context.Context, subID, toolName, reqID string, 
    duration, status, tokens int) {
    h.db.Queries.RecordSubscriptionUsage(ctx, db.RecordSubscriptionUsageParams{
        SubscriptionID: subID,
        ToolName:       toolName,
        RequestID:      reqID,
        DurationMs:     int32(duration),
        StatusCode:     int32(status),
        TokensUsed:     int32(tokens),
    })
}
```

### Step 3: MCP Client (Gateway → MCP Communication)

```go
// packages/core/control-plane/internal/mcp/client.go
package mcp

import (
    "context"
    "crypto/tls"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials"
)

type MCPClient struct {
    // Connection pool to MCP servers
    connections map[string]*grpc.ClientConn
}

type MCPRequest struct {
    Endpoint         string
    AuthConfig       map[string]interface{} // How gateway authenticates to MCP
    ToolName         string
    Arguments        map[string]interface{}
    ExecutionContext *ExecutionContext
}

type ExecutionContext struct {
    ClientID       string
    SubscriptionID string
    RequestID      string
}

func (c *MCPClient) CallTool(ctx context.Context, req *MCPRequest) (*ToolResult, *Metadata, error) {
    // 1. Get or create connection to MCP server
    conn, err := c.getConnection(req.Endpoint, req.AuthConfig)
    if err != nil {
        return nil, nil, err
    }
    
    // 2. Create MCP protocol client
    client := NewMCPProtocolClient(conn)
    
    // 3. Call tool with execution context
    // The MCP server receives WHO is calling (via ExecutionContext)
    result, err := client.CallTool(ctx, &CallToolRequest{
        Name:      req.ToolName,
        Arguments: req.Arguments,
        Metadata: map[string]string{
            "x-giru-client-id":       req.ExecutionContext.ClientID,
            "x-giru-subscription-id": req.ExecutionContext.SubscriptionID,
            "x-giru-request-id":      req.ExecutionContext.RequestID,
        },
    })
    
    if err != nil {
        return nil, nil, err
    }
    
    // 4. Return result and metadata
    return result.Content, &Metadata{
        Duration:   result.Duration,
        TokensUsed: result.TokensUsed,
    }, nil
}

func (c *MCPClient) getConnection(endpoint string, authConfig map[string]interface{}) (*grpc.ClientConn, error) {
    // Check connection pool
    if conn, exists := c.connections[endpoint]; exists {
        return conn, nil
    }
    
    // Create new connection with authentication
    var opts []grpc.DialOption
    
    // Add authentication based on config
    switch authConfig["type"] {
    case "mtls":
        cert, _ := tls.LoadX509KeyPair(
            authConfig["cert_path"].(string),
            authConfig["key_path"].(string),
        )
        opts = append(opts, grpc.WithTransportCredentials(
            credentials.NewTLS(&tls.Config{Certificates: []tls.Certificate{cert}}),
        ))
    case "jwt":
        opts = append(opts, grpc.WithPerRPCCredentials(&JWTAuth{
            Token: authConfig["token"].(string),
        }))
    }
    
    conn, err := grpc.Dial(endpoint, opts...)
    if err != nil {
        return nil, err
    }
    
    c.connections[endpoint] = conn
    return conn, nil
}
```

## OPA Policies for Subscriptions

```rego
# deployments/opa/policies/subscriptions.rego
package giru.subscriptions

import future.keywords.if
import future.keywords.in

# Default deny
default allow = false

# Allow tool execution if subscription is valid
allow if {
    # Basic checks
    input.action == "execute_tool"
    subscription_valid
    
    # Additional constraint checks
    parameter_constraints_met
}

# Check subscription validity
subscription_valid if {
    subscription := input.subscription
    
    # Subscription must be active
    subscription.status == "active"
    
    # Temporal validity
    now := time.now_ns()
    subscription.starts_at <= now
    subscription.expires_at >= now
}

# Check parameter constraints (e.g., file size limits)
parameter_constraints_met if {
    subscription := data.subscriptions[input.subscription.id]
    constraints := subscription.constraints
    args := input.arguments
    
    # Example: File size constraint
    constraints.max_file_size
    args.file_size <= constraints.max_file_size
}

# Example: PII filtering
parameter_constraints_met if {
    subscription := data.subscriptions[input.subscription.id]
    
    # If subscription requires PII filtering
    subscription.constraints.filter_pii == true
    
    # Check that request doesn't contain PII
    not contains_pii(input.arguments)
}

contains_pii(args) if {
    # Simple PII check (real implementation would be more sophisticated)
    regex.match(`\d{3}-\d{2}-\d{4}`, args.text) # SSN pattern
}
```

## Management APIs

### Create Subscription

```http
POST /api/v1/subscriptions
Authorization: Bearer <tenant_admin_token>

{
  "client_id": "client-abc-123",
  "mcp_server_id": "mcp-def-456",
  "name": "sales-agent-github-access",
  "scope_type": "selective",
  "scope_tools": [
    "github__list_repos",
    "github__create_issue"
  ],
  "rate_limit_rps": 10,
  "quota_per_day": 1000,
  "constraints": {
    "max_file_size": 10485760,
    "filter_pii": true
  },
  "expires_at": "2025-12-31T23:59:59Z"
}

Response 201:
{
  "id": "sub-xyz-789",
  "status": "active",
  "created_at": "2025-01-15T10:00:00Z"
}
```

### List Client's Subscriptions

```http
GET /api/v1/clients/{client_id}/subscriptions
Authorization: Bearer <tenant_admin_token>

Response 200:
{
  "subscriptions": [
    {
      "id": "sub-xyz-789",
      "mcp_server": {
        "id": "mcp-def-456",
        "name": "github-integration",
        "display_name": "GitHub MCP"
      },
      "scope_tools": [
        "github__list_repos",
        "github__create_issue"
      ],
      "limits": {
        "rate_limit_rps": 10,
        "quota_per_day": 1000
      },
      "usage_today": 234,
      "status": "active"
    }
  ]
}
```

### Get Available Tools (for a Client)

```http
GET /api/v1/clients/{client_id}/available-tools
Authorization: Bearer <client_api_key>

Response 200:
{
  "tools": [
    {
      "name": "github__list_repos",
      "display_name": "List GitHub Repositories",
      "description": "Retrieve list of repositories for a user/org",
      "category": "data",
      "input_schema": {...},
      "provided_by": {
        "mcp_server": "github-integration",
        "subscription": "sub-xyz-789"
      }
    },
    {
      "name": "slack__send_message",
      "display_name": "Send Slack Message",
      "provided_by": {
        "mcp_server": "slack-integration",
        "subscription": "sub-aaa-111"
      }
    }
  ]
}
```

## Key Benefits of This Model

### 1. **Zero Client Configuration**
```
Client never needs to know:
- MCP endpoints
- MCP authentication
- MCP protocols
- MCP availability

Client only knows: tool names
```

### 2. **Centralized Access Control**
```
All authorization in one place:
- Subscriptions define access
- Rate limits enforced centrally
- Quotas tracked centrally
- Audit trail complete
```

### 3. **Dynamic Routing**
```
MCP servers can be:
- Replaced without client changes
- Load balanced
- Failed over
- Scaled independently
```

### 4. **Multi-Tenancy Native**
```
Tenant A's Client → Can only access Tenant A's MCPs (unless cross-tenant enabled)
Subscriptions enforce tenant boundaries
```

### 5. **Enterprise Features**
```
- Usage-based billing (per subscription)
- Chargeback (which client/department used what)
- Approval workflows (before subscription activation)
- SLA tracking (per MCP server)
```

## Enterprise vs Open Core

**Open Core (Community):**
- ✅ Basic subscriptions (client → MCP, same tenant)
- ✅ Tool-level scoping
- ✅ Rate limiting & quotas
- ✅ Manual subscription creation

**Enterprise:**
- 💰 Cross-tenant subscriptions
- 💰 Approval workflows (manager approval before activation)
- 💰 Usage-based billing & cost allocation
- 💰 Subscription templates (pre-configured bundles)
- 💰 Advanced analytics (ROI, optimization recommendations)
- 💰 SLA guarantees (response time commitments)

## Summary

This subscription model creates a **true federated system** where:

1. **Clients are decoupled from MCPs** - they only know tool names
2. **Gateway is the orchestrator** - handles routing, auth, rate limiting
3. **Subscriptions are access grants** - define WHO can access WHAT with WHICH limits
4. **Multi-client support is native** - one client can have many subscriptions

This is **exactly what makes Giru valuable** - it's not just a proxy, it's an intelligent orchestration layer that federates access to tools across the AI agent ecosystem.

Should I now update the database schema and create the migration files for this corrected model?