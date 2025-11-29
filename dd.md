┌─────────────────────────────────────────────────────────────────┐
│  Step-by-Step Request Flow                                      │
└─────────────────────────────────────────────────────────────────┘

1. CLIENT REQUEST
   ↓
   AI Agent (e.g., Claude, ChatGPT, Custom Agent)
   ↓
   POST https://gateway.giru.ai/mcp/filesystem/tools/read_file
   Headers:
     Authorization: Bearer eyJhbGc...  (JWT or API key)
     Content-Type: application/json
   Body:
     {
       "path": "/home/user/document.txt",
       "encoding": "utf8"
     }

2. ENVOY PROXY (Layer 1 - Entry Point)
   ↓
   - Receives request on port 443 (TLS terminated)
   - Extracts client identity from JWT/API key
   - Parses request: method, path, headers, body
   - Builds authorization context for OPA

3. ENVOY → OPA AUTHORIZATION CHECK (Layer 2)
   ↓
   Envoy sends to OPA External Authorization:
   
   POST http://opa:8181/v1/data/giru/authz/allow
   {
     "input": {
       "client": {
         "id": "client-abc-123",
         "name": "my-ai-agent",
         "tenant_id": "acme-corp"
       },
       "request": {
         "method": "POST",
         "path": "/mcp/filesystem/tools/read_file",
         "headers": {...}
       },
       "mcp_server": "filesystem",
       "tool": "read_file",
       "parameters": {
         "path": "/home/user/document.txt"
       }
     }
   }
   
   OPA evaluates policies:
   ✓ Is client authenticated?
   ✓ Is client allowed to access "filesystem" server?
   ✓ Is client allowed to use "read_file" tool?
   ✓ Is the file path "/home/user/document.txt" allowed?
   ✓ Rate limit check (has quota remaining?)
   ✓ Time-based restrictions (business hours only?)
   
   OPA Response:
   {
     "result": {
       "allowed": true,
       "headers": {
         "X-Giru-Client-ID": "client-abc-123",
         "X-Giru-Tenant-ID": "acme-corp"
       }
     }
   }

4. ENVOY → CONTROL PLANE (Route Resolution)
   ↓
   If OPA allows, Envoy uses xDS configuration to route request
   
   Control Plane previously configured Envoy with:
   - Route: /mcp/filesystem/* → cluster "mcp-filesystem"
   - Cluster "mcp-filesystem" → endpoints [http://mcp-filesystem:8080]
   
   Envoy rewrites path:
   /mcp/filesystem/tools/read_file → /tools/read_file
   
   Forwards to: http://mcp-filesystem:8080/tools/read_file

5. MCP SERVER (Upstream Service)
   ↓
   MCP Filesystem Server receives:
   
   POST /tools/read_file
   Headers:
     X-Giru-Client-ID: client-abc-123
     X-Giru-Tenant-ID: acme-corp
   Body:
     {
       "path": "/home/user/document.txt",
       "encoding": "utf8"
     }
   
   MCP Server executes tool and returns:
   {
     "content": "Hello, this is the file content...",
     "encoding": "utf8",
     "size": 1234
   }

6. RESPONSE FLOW BACK
   ↓
   MCP Server → Envoy → Client
   
   Envoy may:
   - Add response headers (X-Giru-Request-ID, X-Giru-Latency)
   - Emit metrics (Prometheus)
   - Log access (for audit)
   - Apply response transforms

7. CLIENT RECEIVES RESPONSE
   ↓
   200 OK
   {
     "content": "Hello, this is the file content...",
     "encoding": "utf8",
     "size": 1234
   }
