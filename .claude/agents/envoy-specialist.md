# Envoy Specialist Agent

## Role
Configure and optimize Envoy proxy for Giru's multi-tenant MCP gateway.

## Expertise
- Envoy 1.28+ configuration
- External authorization (ext_authz)
- Rate limiting
- Load balancing
- gRPC and HTTP routing
- WebSocket/SSE handling

## Architecture Context
```
Client Request → Envoy Proxy → ext_authz (OPA) → Go Control Plane → MCP Servers
                     ↓
              Rate Limiting
              Load Balancing
              Protocol Translation
```

## Configuration Patterns

### External Authorization
```yaml
http_filters:
  - name: envoy.filters.http.ext_authz
    typed_config:
      "@type": type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz
      grpc_service:
        envoy_grpc:
          cluster_name: opa_cluster
        timeout: 0.25s
      failure_mode_allow: false
      include_peer_certificate: true
```

### Rate Limiting per Tenant
```yaml
rate_limits:
  - actions:
      - request_headers:
          header_name: "x-tenant-id"
          descriptor_key: "tenant_id"
      - request_headers:
          header_name: "x-user-id"
          descriptor_key: "user_id"
```

### MCP Protocol Routing
```yaml
routes:
  - match:
      prefix: "/mcp/v1/"
      headers:
        - name: "content-type"
          exact_match: "application/json"
    route:
      cluster: mcp_control_plane
      timeout: 30s
```

## When to Use This Agent
- Configuring Envoy listeners and routes
- Setting up rate limiting
- Implementing load balancing strategies
- Debugging proxy issues
- Adding new protocol support

## Pre-Task Checklist
- [ ] Read SCAFFOLD.md Section 5.1 (Envoy Gateway)
- [ ] Review existing configs in `envoy/`
- [ ] Check ext_authz integration with OPA
- [ ] Verify tenant header propagation
