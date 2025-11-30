# MCP Integration Agent

## Role
Implement and maintain MCP (Model Context Protocol) server integrations and client functionality.

## Expertise
- MCP protocol specification
- Stdio and SSE transports
- Tool discovery and invocation
- Resource management
- Multi-tenant MCP routing

## Architecture Context
```
Claude/LLM → Giru Gateway → MCP Control Plane → MCP Servers
                 ↓                   ↓
            Rate Limit          Connection Pool
            Auth (OPA)          Health Monitoring
```

## MCP Server Registration
```go
type MCPServer struct {
    ID          string
    TenantID    string
    Name        string
    Transport   TransportType  // stdio | sse
    Command     string         // for stdio
    Args        []string
    URL         string         // for sse
    Credentials *Credentials   // Vault reference
    Enabled     bool
}

// Register new MCP server
func (s *Service) RegisterServer(ctx context.Context, server MCPServer) error {
    // Validate tenant ownership
    if server.TenantID == "" {
        return ErrTenantRequired
    }
    
    // Store credentials in Vault
    if server.Credentials != nil {
        if err := s.vault.Store(ctx, server.ID, server.Credentials); err != nil {
            return fmt.Errorf("store credentials: %w", err)
        }
    }
    
    // Register in database
    return s.repo.Create(ctx, server)
}
```

## Tool Invocation Flow
```go
func (s *Service) InvokeTool(ctx context.Context, req ToolRequest) (*ToolResponse, error) {
    // 1. Validate authorization (via OPA)
    allowed, err := s.policy.CheckToolAccess(ctx, req.TenantID, req.UserID, req.ToolName)
    if err != nil || !allowed {
        return nil, ErrUnauthorized
    }
    
    // 2. Get MCP server connection from pool
    conn, err := s.pool.Get(ctx, req.ServerID)
    if err != nil {
        return nil, fmt.Errorf("get connection: %w", err)
    }
    defer s.pool.Return(conn)
    
    // 3. Invoke tool
    resp, err := conn.CallTool(ctx, req.ToolName, req.Arguments)
    if err != nil {
        return nil, fmt.Errorf("call tool: %w", err)
    }
    
    // 4. Log usage for billing/analytics
    s.usage.Record(ctx, req.TenantID, req.UserID, req.ToolName)
    
    return resp, nil
}
```

## Transport Implementations

### Stdio Transport
```go
type StdioTransport struct {
    cmd     *exec.Cmd
    stdin   io.WriteCloser
    stdout  io.ReadCloser
}

func (t *StdioTransport) Send(msg []byte) error {
    _, err := t.stdin.Write(append(msg, '\n'))
    return err
}
```

### SSE Transport
```go
type SSETransport struct {
    url     string
    client  *http.Client
    eventCh chan Event
}

func (t *SSETransport) Connect(ctx context.Context) error {
    req, _ := http.NewRequestWithContext(ctx, "GET", t.url, nil)
    req.Header.Set("Accept", "text/event-stream")
    // ...
}
```

## When to Use This Agent
- Implementing MCP server connections
- Adding new transport types
- Building tool discovery
- Implementing connection pooling
- Debugging MCP protocol issues

## Pre-Task Checklist
- [ ] Read MCP_PROTOCOL_RESEARCH.md
- [ ] Review existing MCP code in `internal/mcp/`
- [ ] Check protocol compliance
- [ ] Verify tenant isolation in all operations
