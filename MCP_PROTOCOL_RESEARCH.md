# Model Context Protocol (MCP) - Deep Dive Research

**Date:** 2025-11-14  
**Purpose:** Understanding MCP wire protocol and API contract for gateway design

## Table of Contents

1. [Protocol Overview](#protocol-overview)
2. [Wire Protocol & Message Format](#wire-protocol--message-format)
3. [Transport Mechanisms](#transport-mechanisms)
4. [Lifecycle & Handshake](#lifecycle--handshake)
5. [Core Protocol Messages](#core-protocol-messages)
6. [Authentication & Security](#authentication--security)
7. [Implementation Patterns](#implementation-patterns)
8. [Key Takeaways for Gateway Design](#key-takeaways-for-gateway-design)

---

## Protocol Overview

**What is MCP?**
- Open protocol enabling LLMs to securely access tools and data sources
- Created by Anthropic (David Soria Parra & Justin Spahr-Summers)
- Built on JSON-RPC 2.0 as wire format
- Stateful session protocol focused on context exchange
- Latest specification: 2025-06-18

**Core Capabilities:**
- **Tools** - Callable functions for LLMs to take actions
- **Resources** - Data exposure (files, API responses, database records)
- **Prompts** - Interaction templates
- **Sampling** - LLM inference requests from server to client

**Design Philosophy:**
- Simplicity and extensibility
- Security-first approach
- Transport-agnostic architecture
- Cross-platform interoperability

---

## Wire Protocol & Message Format

### JSON-RPC 2.0 Foundation

All MCP messages use JSON-RPC 2.0 format with three message types:

#### 1. Requests (expect response)
```json
{
  "jsonrpc": "2.0",
  "id": "unique-request-id",
  "method": "tools/call",
  "params": {
    "name": "get_weather",
    "arguments": {
      "location": "San Francisco"
    }
  }
}
```

#### 2. Responses (reply to request)
```json
{
  "jsonrpc": "2.0",
  "id": "unique-request-id",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Temperature: 72°F, Conditions: Partly cloudy"
      }
    ],
    "isError": false
  }
}
```

#### 3. Notifications (one-way, no response)
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/progress",
  "params": {
    "progress": 50,
    "total": 100,
    "progressToken": "task-123"
  }
}
```

### Error Responses

Standard JSON-RPC error codes:

| Code | Meaning | Usage |
|------|---------|-------|
| -32700 | Parse error | Invalid JSON syntax |
| -32600 | Invalid request | Missing required fields |
| -32601 | Method not found | Unimplemented method |
| -32602 | Invalid params | Parameter type mismatch |
| -32603 | Internal error | Server-side failure |

Error response format:
```json
{
  "jsonrpc": "2.0",
  "id": 13,
  "error": {
    "code": -32601,
    "message": "Method not found",
    "data": {
      "method": "unknown/method"
    }
  }
}
```

### Content Types

The protocol supports multiple content block types:

- **TextContent** - Plain text with optional annotations
- **ImageContent** - Base64-encoded with MIME type
- **AudioContent** - Base64-encoded audio data
- **ResourceLink** - Reference to server resources
- **EmbeddedResource** - Inline resource contents

---

## Transport Mechanisms

MCP supports three primary transport mechanisms, each with distinct characteristics:

### 1. STDIO Transport (Local)

**Use Case:** Local CLI tools, desktop integrations

**How it Works:**
- Client spawns MCP server as child process
- Communication via standard input/output streams
- Client writes to server's STDIN
- Server responds on STDOUT
- Logging MUST go to STDERR (never STDOUT)

**Message Format:**
- One JSON-RPC message per line
- Messages MUST NOT contain embedded newlines
- Newline-delimited format

**Critical Implementation Details:**
```python
# Python example - MUST flush stdout
print(json.dumps(message), flush=True)

# NEVER log to stdout
print("Debug info")  # WRONG - corrupts protocol
sys.stderr.write("Debug info\n")  # CORRECT
```

**Pros:**
- Simple process-based isolation
- No network configuration needed
- Works offline
- Easy debugging

**Cons:**
- Local only
- No remote access
- Process lifecycle management required

### 2. SSE (Server-Sent Events) - LEGACY

**Status:** Deprecated - use Streamable HTTP instead

**Architecture:**
- Two separate HTTP endpoints
- SSE for server-to-client messages (HTTP GET)
- HTTP POST for client-to-server messages

**Why Deprecated:**
- Complexity of maintaining two endpoints
- Session management difficulties
- Replaced by unified Streamable HTTP

### 3. Streamable HTTP - MODERN STANDARD

**Use Case:** Web applications, remote servers, cloud deployments

**Architecture:**
- Single HTTP endpoint supporting both POST and GET
- POST for client-to-server communication
- Optional SSE streams for server-to-client messages

**Client-to-Server Flow:**
```
Client -> HTTP POST /mcp
Content-Type: application/json
Body: JSON-RPC request

Server Response:
- Single JSON response (Content-Type: application/json), OR
- SSE stream (Content-Type: text/event-stream) for multiple messages
```

**Session Management:**
- Server assigns session ID during initialization
- Client includes session ID in subsequent requests
- Session binding prevents session hijacking

**Connection Resumability:**
- Event IDs for tracking SSE messages
- `Last-Event-ID` header for resuming connections
- Server can replay missed messages

**Example TypeScript Setup:**
```typescript
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';
import express from 'express';

const app = express();
const transport = new StreamableHTTPServerTransport('/mcp');

app.use('/mcp', transport.router);
app.listen(3000);
```

**Selection Guide:**
- Local CLI tools → STDIO
- Web/remote access → Streamable HTTP
- Legacy compatibility → SSE (not recommended for new projects)

---

## Lifecycle & Handshake

### Connection Lifecycle Phases

1. **Initialization** - Capability negotiation and protocol version agreement
2. **Operation** - Normal protocol communication  
3. **Shutdown** - Graceful termination

### Initialization Handshake (3-Step Process)

#### Step 1: Client Sends Initialize Request

The client MUST initiate with protocol version and capabilities:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-06-18",
    "capabilities": {
      "roots": {
        "listChanged": true
      },
      "sampling": {},
      "elicitation": {}
    },
    "clientInfo": {
      "name": "claude-desktop",
      "version": "1.0.0"
    }
  }
}
```

**Client Capabilities:**
- `roots.listChanged` - Supports root change notifications
- `sampling` - Can execute LLM sampling requests
- `elicitation` - Can handle user input requests
- `experimental` - Vendor-specific features

#### Step 2: Server Responds with Capabilities

Server MUST respond with its protocol version and capabilities:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2025-06-18",
    "capabilities": {
      "resources": {
        "subscribe": true,
        "listChanged": true
      },
      "tools": {
        "listChanged": true
      },
      "prompts": {
        "listChanged": true
      },
      "logging": {}
    },
    "serverInfo": {
      "name": "example-mcp-server",
      "version": "2.1.0"
    }
  }
}
```

**Server Capabilities:**
- `logging` - Sends log messages to client
- `completions` - Provides argument autocompletion
- `prompts.listChanged` - Notifies prompt changes
- `resources.subscribe` - Supports resource subscriptions
- `resources.listChanged` - Notifies resource changes
- `tools.listChanged` - Notifies tool availability changes
- `experimental` - Custom extensions

#### Step 3: Client Confirms Initialization

Client sends notification (no response expected):

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized"
}
```

### Protocol Version Negotiation

- Client sends latest version it supports
- Server responds with same version if supported
- Otherwise, server responds with different supported version
- If no compatible version exists, connection fails

### Post-Initialization Rules

**Before `initialized` notification:**
- Client SHOULD NOT send requests except pings
- Server SHOULD NOT send requests except pings and logging

**After `initialized` notification:**
- Full protocol operations available
- All negotiated capabilities active

---

## Core Protocol Messages

### Client → Server Requests

#### Tools

**List Available Tools:**
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/list"
}
```

Response includes tool definitions:
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "tools": [
      {
        "name": "get_weather",
        "title": "Weather Lookup",
        "description": "Get current weather for a location",
        "inputSchema": {
          "type": "object",
          "properties": {
            "location": {
              "type": "string",
              "description": "City name or coordinates"
            }
          },
          "required": ["location"]
        },
        "outputSchema": {
          "type": "object",
          "properties": {
            "temperature": { "type": "number" },
            "conditions": { "type": "string" }
          }
        },
        "annotations": {
          "readOnly": true,
          "destructive": false
        }
      }
    ]
  }
}
```

**Call Tool:**
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "get_weather",
    "arguments": {
      "location": "San Francisco"
    }
  }
}
```

**Tool Annotations:**
- `readOnly` - Does not modify state
- `destructive` - May delete or modify data
- `idempotent` - Safe to retry
- `openWorld` - May access external resources

#### Resources

**List Resources:**
```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "resources/list"
}
```

**Read Resource:**
```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "resources/read",
  "params": {
    "uri": "file:///config.json"
  }
}
```

**Subscribe to Resource Updates:**
```json
{
  "jsonrpc": "2.0",
  "id": 6,
  "method": "resources/subscribe",
  "params": {
    "uri": "file:///config.json"
  }
}
```

**List Resource Templates:**
```json
{
  "jsonrpc": "2.0",
  "id": 7,
  "method": "resources/templates/list"
}
```

Templates enable dynamic URIs like `users://{userId}/profile`

#### Prompts

**List Prompts:**
```json
{
  "jsonrpc": "2.0",
  "id": 8,
  "method": "prompts/list"
}
```

**Get Prompt:**
```json
{
  "jsonrpc": "2.0",
  "id": 9,
  "method": "prompts/get",
  "params": {
    "name": "code-review",
    "arguments": {
      "language": "typescript"
    }
  }
}
```

#### Other Operations

**Completion (Autocomplete):**
```json
{
  "jsonrpc": "2.0",
  "id": 10,
  "method": "completion/complete",
  "params": {
    "ref": {
      "type": "argument",
      "name": "location"
    },
    "argument": {
      "name": "location",
      "value": "San"
    }
  }
}
```

**Set Logging Level:**
```json
{
  "jsonrpc": "2.0",
  "id": 11,
  "method": "logging/setLevel",
  "params": {
    "level": "debug"
  }
}
```

**Ping:**
```json
{
  "jsonrpc": "2.0",
  "id": 12,
  "method": "ping"
}
```

### Client → Server Notifications

**Cancelled Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/cancelled",
  "params": {
    "requestId": "request-to-cancel"
  }
}
```

**Progress Update:**
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/progress",
  "params": {
    "progressToken": "task-123",
    "progress": 75,
    "total": 100
  }
}
```

**Roots Changed:**
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/roots/list_changed"
}
```

### Server → Client Requests

**Sampling (LLM Inference):**
```json
{
  "jsonrpc": "2.0",
  "id": 100,
  "method": "sampling/createMessage",
  "params": {
    "messages": [
      {
        "role": "user",
        "content": {
          "type": "text",
          "text": "Analyze this code"
        }
      }
    ],
    "modelPreferences": {
      "hints": [
        { "name": "claude-3-5-sonnet-20241022" }
      ]
    },
    "maxTokens": 1000
  }
}
```

**List Roots (Filesystem):**
```json
{
  "jsonrpc": "2.0",
  "id": 101,
  "method": "roots/list"
}
```

**Elicitation (User Input):**
```json
{
  "jsonrpc": "2.0",
  "id": 102,
  "method": "elicitation/create",
  "params": {
    "prompt": "Enter your API key",
    "fields": [
      {
        "name": "api_key",
        "type": "string",
        "description": "Your service API key",
        "required": true
      }
    ]
  }
}
```

### Server → Client Notifications

**Log Message:**
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/message",
  "params": {
    "level": "info",
    "logger": "mcp-server",
    "data": "Processing request..."
  }
}
```

**Resource List Changed:**
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/resources/list_changed"
}
```

**Resource Updated:**
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/resources/updated",
  "params": {
    "uri": "file:///config.json"
  }
}
```

**Tools List Changed:**
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/tools/list_changed"
}
```

**Prompts List Changed:**
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/prompts/list_changed"
}
```

---

## Authentication & Security

### June 2025 Specification Updates

The June 18, 2025 specification introduced major security enhancements:

#### OAuth 2.1 Foundation

- OAuth 2.1 is the recommended authentication mechanism
- MCP servers classified as **OAuth Resource Servers**
- Must implement RFC 8707 (Resource Indicators)

#### Key Security Requirements

**1. Token Validation (MUST):**
- Servers MUST verify all inbound requests
- Servers MUST NOT use sessions alone for authentication
- Tokens MUST be explicitly issued for the MCP server
- No token passthrough - servers must validate token audience

**2. Session Management (MUST):**
- Use cryptographically secure session IDs (UUIDs recommended)
- Avoid predictable or sequential session identifiers
- Sessions should bind to user data from validated tokens
- Session IDs alone are NOT sufficient for authentication

**3. Resource Indicators (MUST for clients):**
```json
{
  "grant_type": "authorization_code",
  "code": "auth_code_here",
  "resource": "https://mcp.example.com"
}
```

By using resource indicators, clients explicitly state the intended audience of the access token, preventing token misuse.

### Authentication Patterns

#### 1. OAuth Flow (Remote Servers)

**GitHub MCP Server Example:**
- Uses OAuth for remote deployments
- Hosted endpoint: `https://api.githubcopilot.com/mcp/`
- Standard OAuth 2.1 authorization code flow

#### 2. Personal Access Tokens (Local Servers)

**Configuration via Environment Variables:**
```bash
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxx...
```

Some clients (like Windsurf) require hardcoded tokens in config:
```json
{
  "mcpServers": {
    "github": {
      "command": "github-mcp-server",
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx..."
      }
    }
  }
}
```

#### 3. No Authentication (STDIO/Local)

For local STDIO servers, authentication may not be required as:
- Process isolation provides security boundary
- Client controls server lifecycle
- No network exposure

### Security Best Practices

**1. Prevent Confused Deputy Attacks:**
- Proxy servers MUST obtain user consent per client
- Validate token audience matches server
- Don't accept arbitrary upstream tokens

**2. Token Storage Security:**
- MCP servers are high-value targets (store multiple service tokens)
- Encrypt tokens at rest
- Use secure key management systems
- Implement token rotation

**3. Request Verification:**
- Validate all JSON-RPC requests
- Enforce input schema validation
- Rate limiting per session/user
- Audit logging for security events

**4. Transport Security:**
- STDIO: Process isolation, no network exposure
- HTTP: MUST use HTTPS (TLS 1.3 recommended)
- Validate certificates, no self-signed in production

**5. Capability-Based Security:**
- Least privilege principle
- Only advertise necessary capabilities
- Implement per-tool authorization
- Resource-level access control

### Attack Vectors & Mitigations

| Attack Vector | Risk | Mitigation |
|---------------|------|------------|
| Confused Deputy | Unauthorized API access | Per-client consent, audience validation |
| Token Passthrough | Bypassed controls, audit failures | Mandate token validation, resource indicators |
| Session Hijacking | Account impersonation | Secure session IDs, user binding, HTTPS |
| Prompt Injection (XPIA) | Data exfiltration, malware | Input sanitization, content security policies |
| Tool Abuse | Destructive operations | Tool annotations, confirmation flows, rate limits |

### Compliance References

- **RFC 6749** - OAuth 2.0 Authorization Framework
- **RFC 8707** - Resource Indicators for OAuth 2.0
- **RFC 9700** - OAuth 2.0 Security Best Current Practice

---

## Implementation Patterns

### TypeScript SDK Patterns

#### Basic Server Setup

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';

// Create server
const server = new McpServer({
  name: 'my-app',
  version: '1.0.0'
});

// Register a tool
server.registerTool(
  'calculate-bmi',
  {
    title: 'BMI Calculator',
    description: 'Calculate Body Mass Index',
    inputSchema: {
      type: 'object',
      properties: {
        weightKg: { type: 'number' },
        heightM: { type: 'number' }
      },
      required: ['weightKg', 'heightM']
    }
  },
  async ({ weightKg, heightM }) => {
    const bmi = weightKg / (heightM * heightM);
    return {
      content: [
        { 
          type: 'text', 
          text: `BMI: ${bmi.toFixed(2)}` 
        }
      ],
      structuredContent: { bmi }
    };
  }
);

// Register a resource
server.registerResource(
  'config',
  {
    uri: 'app://config',
    name: 'App Configuration',
    description: 'Current application settings'
  },
  async () => {
    return {
      contents: [
        {
          uri: 'app://config',
          mimeType: 'application/json',
          text: JSON.stringify({ version: '1.0' })
        }
      ]
    };
  }
);

// Start HTTP transport
const transport = new StreamableHTTPServerTransport('/mcp');
server.connect(transport);
```

#### STDIO Transport

```typescript
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const transport = new StdioServerTransport();
await server.connect(transport);
```

### Python SDK Patterns

#### FastMCP (High-Level)

```python
from fastmcp import FastMCP

mcp = FastMCP(name="My MCP Server")

# Register tool with decorator
@mcp.tool
def add_numbers(a: int, b: int) -> int:
    """Adds two integer numbers together."""
    return a + b

# Register resource
@mcp.resource("config://app")
def get_config() -> dict:
    """Provides the application's configuration."""
    return {
        "version": "1.0",
        "features": ["tools", "resources"]
    }

# Register prompt
@mcp.prompt
def code_review_prompt(language: str) -> str:
    """Generate code review instructions."""
    return f"Review this {language} code for best practices"

# Progress reporting
@mcp.tool
async def long_task(ctx: Context, items: int) -> str:
    """Long running task with progress."""
    for i in range(items):
        await ctx.report_progress(i, items)
        await asyncio.sleep(0.1)
    return "Complete"

# Run server (defaults to STDIO)
if __name__ == "__main__":
    mcp.run()
```

#### Low-Level Python SDK

```python
from mcp.server import Server
from mcp.server.session import ServerSession
from mcp.types import Tool, CallToolResult, TextContent

server = Server("my-server")

@server.call_tool()
async def handle_call_tool(
    name: str, 
    arguments: dict
) -> CallToolResult:
    if name == "get_weather":
        location = arguments.get("location")
        # Fetch weather...
        return CallToolResult(
            content=[
                TextContent(
                    type="text",
                    text=f"Weather for {location}: 72°F"
                )
            ],
            isError=False
        )
    raise ValueError(f"Unknown tool: {name}")

@server.list_tools()
async def handle_list_tools() -> list[Tool]:
    return [
        Tool(
            name="get_weather",
            description="Get current weather",
            inputSchema={
                "type": "object",
                "properties": {
                    "location": {"type": "string"}
                },
                "required": ["location"]
            }
        )
    ]
```

### Go Implementation Pattern

```go
package main

import (
    "github.com/mark3labs/mcp-go/mcp"
    "github.com/mark3labs/mcp-go/server"
)

func main() {
    s := server.NewMCPServer(
        "example-server",
        "1.0.0",
    )

    // Register tool
    tool := mcp.NewTool("get_weather",
        mcp.WithDescription("Get weather for location"),
        mcp.WithString("location", 
            mcp.Required(),
            mcp.Description("City name"),
        ),
    )
    
    s.AddTool(tool, handleWeather)
    
    // Serve via STDIO
    s.ServeStdio()
}

func handleWeather(args map[string]interface{}) (*mcp.CallToolResult, error) {
    location := args["location"].(string)
    
    return mcp.NewToolResult(
        mcp.NewTextContent(fmt.Sprintf("Weather for %s: 72°F", location)),
    ), nil
}
```

### Common Implementation Patterns

#### 1. Two-Step Tool Invocation

Clients always:
1. Call `tools/list` to discover available tools
2. Validate parameters against schema
3. Call `tools/call` with validated arguments

This prevents runtime errors and enables UX features like autocomplete.

#### 2. URI-Based Resources

Resources use scheme-qualified URIs:
- `file://` - Filesystem resources
- `db://` - Database records
- `api://` - External API responses
- Custom schemes for domain-specific resources

#### 3. Progress Tracking

For long-running operations:

```python
@mcp.tool
async def process_large_file(ctx: Context, filepath: str) -> str:
    total = get_file_size(filepath)
    processed = 0
    
    for chunk in read_chunks(filepath):
        process_chunk(chunk)
        processed += len(chunk)
        await ctx.report_progress(processed, total)
    
    return "Processing complete"
```

#### 4. Error Handling

Always distinguish business errors from protocol errors:

```typescript
// Business error (isError: true in result)
return {
  content: [
    { type: 'text', text: 'File not found: config.json' }
  ],
  isError: true
};

// Protocol error (throw exception)
throw new Error("Invalid tool name");
```

#### 5. Structured Output

Return both human-readable and machine-readable content:

```typescript
return {
  content: [
    { type: 'text', text: 'BMI: 24.5 (Normal weight)' }
  ],
  structuredContent: {
    bmi: 24.5,
    category: 'normal',
    range: { min: 18.5, max: 24.9 }
  }
};
```

---

## Key Takeaways for Gateway Design

### 1. Protocol Translation Requirements

**Gateway MUST handle:**
- JSON-RPC 2.0 message routing (requests, responses, notifications)
- Session management (initialize handshake, session IDs)
- Capability negotiation (client ↔ gateway ↔ server)
- Transport translation (e.g., HTTP → STDIO, HTTP → HTTP)
- Error code mapping and propagation

### 2. Transport Layer Considerations

**For Multi-Server Gateway:**

```
Client (HTTP/SSE) ←→ Gateway ←→ Multiple Servers (STDIO/HTTP)
```

**Gateway Responsibilities:**
- Maintain persistent connections to STDIO servers (process management)
- Pool HTTP connections to remote servers
- Multiplex client requests to appropriate backend
- Aggregate capabilities from multiple servers
- Route based on tool/resource namespaces

### 3. Authentication Strategy

**Gateway Authentication Models:**

#### Model A: Gateway as OAuth Proxy
```
Client → OAuth → Gateway → Token validation → Backend servers
```

- Gateway validates client tokens
- Gateway obtains backend tokens per user
- Gateway injects auth into backend requests
- **Requires:** Token storage, per-backend auth config

#### Model B: Pass-Through Authentication
```
Client → OAuth → Gateway (routing only) → Backend (validates)
```

- Gateway routes without validation
- Each backend validates tokens independently
- **Requires:** Resource indicators (RFC 8707)
- **Risk:** Confused deputy if not properly scoped

#### Recommendation for Giru Gateway
Use **Model A** with:
- OAuth 2.1 for client authentication
- Resource indicators for token scoping
- Per-backend credential management
- Session binding to prevent hijacking

### 4. Capability Aggregation

**Multi-Server Scenario:**

```javascript
// Server A capabilities
{
  "tools": { "listChanged": true },
  "resources": {}
}

// Server B capabilities
{
  "resources": { "subscribe": true },
  "prompts": {}
}

// Gateway aggregated capabilities
{
  "tools": { "listChanged": true },
  "resources": { "subscribe": true },
  "prompts": {}
}
```

**Implementation Strategy:**
- Merge capabilities using logical OR
- Track which backend provides each capability
- Route change notifications from any backend to all clients
- Handle capability versioning conflicts

### 5. Request Routing

**Namespace-Based Routing:**

```typescript
interface Route {
  pattern: RegExp;
  backend: string;
  transform?: (req: any) => any;
}

const routes: Route[] = [
  {
    pattern: /^github\/.+/,
    backend: 'github-mcp-server'
  },
  {
    pattern: /^filesystem\/.+/,
    backend: 'filesystem-mcp-server'
  },
  {
    pattern: /^tools\/(list|call)$/,
    backend: 'aggregate'  // Query all backends
  }
];
```

**Tool Namespacing:**
- Prefix tool names with server identifier
- Example: `github/create_issue`, `slack/send_message`
- Maintain routing table: tool name → backend server
- Handle `tools/list` by aggregating all backends

### 6. State Management

**Gateway State Requirements:**

```typescript
interface GatewayState {
  // Client sessions
  clientSessions: Map<string, {
    sessionId: string;
    capabilities: ClientCapabilities;
    userId: string;
    connectedBackends: Set<string>;
  }>;
  
  // Backend connections
  backendConnections: Map<string, {
    type: 'stdio' | 'http';
    process?: ChildProcess;
    httpClient?: HTTPClient;
    capabilities: ServerCapabilities;
    tools: Tool[];
    resources: Resource[];
  }>;
  
  // Request tracking
  pendingRequests: Map<string, {
    clientRequestId: string;
    backendRequestId: string;
    backend: string;
    timestamp: number;
  }>;
}
```

### 7. Error Handling Strategy

**Error Propagation Rules:**

1. **Backend Protocol Errors** → Propagate to client as-is
2. **Backend Business Errors** (`isError: true`) → Pass through
3. **Gateway Errors** (routing, backend unavailable) → Return JSON-RPC error:

```json
{
  "jsonrpc": "2.0",
  "id": 123,
  "error": {
    "code": -32603,
    "message": "Backend server unavailable",
    "data": {
      "backend": "github-mcp-server",
      "reason": "Connection timeout"
    }
  }
}
```

### 8. Notification Handling

**Multi-Server Notification Broadcasting:**

```typescript
// Backend sends notification
{
  "jsonrpc": "2.0",
  "method": "notifications/tools/list_changed"
}

// Gateway broadcasts to all relevant clients
for (const client of getClientsForBackend('github-mcp-server')) {
  client.send({
    "jsonrpc": "2.0",
    "method": "notifications/tools/list_changed"
  });
}
```

### 9. Performance Considerations

**Optimization Strategies:**

1. **Connection Pooling:**
   - Reuse HTTP connections to remote servers
   - Keep STDIO processes alive (don't spawn per request)

2. **Caching:**
   - Cache `tools/list` responses (invalidate on `list_changed`)
   - Cache `resources/list` similarly
   - TTL-based cache for stable resources

3. **Parallel Requests:**
   - Aggregate `tools/list` from all backends in parallel
   - Use Promise.all() for concurrent operations

4. **Backpressure:**
   - Implement rate limiting per client
   - Queue management for STDIO backends
   - Circuit breakers for failing backends

### 10. Testing Requirements

**Gateway Testing Strategy:**

1. **Protocol Compliance:**
   - Test JSON-RPC 2.0 message format
   - Verify initialization handshake
   - Test all error codes

2. **Transport Layer:**
   - STDIO process management (spawn, kill, restart)
   - HTTP connection handling
   - SSE stream management

3. **Multi-Backend Scenarios:**
   - Capability aggregation
   - Request routing
   - Notification broadcasting
   - Backend failure handling

4. **Security:**
   - Token validation
   - Session management
   - Authorization enforcement
   - Input sanitization

### 11. Recommended Architecture

```
┌─────────────────────────────────────────────────┐
│              Client Applications                 │
│  (Claude Desktop, VS Code, Custom Apps)         │
└────────────────┬────────────────────────────────┘
                 │ HTTP/SSE (Streamable HTTP)
                 │
┌────────────────▼────────────────────────────────┐
│           Giru MCP Gateway                       │
│  ┌──────────────────────────────────────────┐  │
│  │  API Layer (HTTP/SSE Server)              │  │
│  ├──────────────────────────────────────────┤  │
│  │  Authentication & Authorization           │  │
│  │  - OAuth 2.1 validation                   │  │
│  │  - Session management                     │  │
│  │  - Resource indicators (RFC 8707)         │  │
│  ├──────────────────────────────────────────┤  │
│  │  Protocol Handler                         │  │
│  │  - JSON-RPC routing                       │  │
│  │  - Capability negotiation                 │  │
│  │  - Request/response mapping               │  │
│  ├──────────────────────────────────────────┤  │
│  │  Backend Manager                          │  │
│  │  - STDIO process pool                     │  │
│  │  - HTTP connection pool                   │  │
│  │  - Health checking                        │  │
│  │  - Load balancing                         │  │
│  ├──────────────────────────────────────────┤  │
│  │  Router                                   │  │
│  │  - Tool/resource → backend mapping        │  │
│  │  - Namespace management                   │  │
│  │  - Aggregation logic                      │  │
│  └──────────────────────────────────────────┘  │
└───────┬─────────────┬─────────────┬────────────┘
        │ STDIO       │ HTTP        │ HTTP
        │             │             │
   ┌────▼────┐   ┌───▼────┐   ┌───▼────┐
   │ GitHub  │   │ Slack  │   │ Custom │
   │   MCP   │   │  MCP   │   │  MCP   │
   │ Server  │   │ Server │   │ Server │
   └─────────┘   └────────┘   └────────┘
```

---

## References

### Official Documentation
- **Specification:** https://modelcontextprotocol.io/specification
- **Main Site:** https://modelcontextprotocol.io
- **GitHub Org:** https://github.com/modelcontextprotocol

### SDKs
- **TypeScript:** https://github.com/modelcontextprotocol/typescript-sdk
- **Python:** https://github.com/modelcontextprotocol/python-sdk
- **Server Implementations:** https://github.com/modelcontextprotocol/servers

### Security Standards
- **OAuth 2.1:** https://oauth.net/2.1/
- **RFC 8707 - Resource Indicators:** https://www.rfc-editor.org/rfc/rfc8707
- **RFC 9700 - OAuth Security BCP:** https://www.rfc-editor.org/rfc/rfc9700

### Example Implementations
- **GitHub MCP Server:** https://github.com/github/github-mcp-server
- **Microsoft MCP Beginners:** https://github.com/microsoft/mcp-for-beginners
- **FastMCP (Python):** https://github.com/jlowin/fastmcp
- **FastMCP (TypeScript):** https://github.com/punkpeye/fastmcp

---

## Appendix: Complete Message Reference

### Method Names Summary

**Client → Server:**
- `initialize` - Start handshake
- `ping` - Connectivity check
- `tools/list` - List available tools
- `tools/call` - Execute tool
- `resources/list` - List resources
- `resources/templates/list` - List resource templates
- `resources/read` - Read resource
- `resources/subscribe` - Subscribe to updates
- `resources/unsubscribe` - Unsubscribe
- `prompts/list` - List prompts
- `prompts/get` - Get specific prompt
- `completion/complete` - Autocomplete request
- `logging/setLevel` - Set log level

**Server → Client:**
- `sampling/createMessage` - Request LLM inference
- `roots/list` - Request filesystem roots
- `elicitation/create` - Request user input

**Notifications (bidirectional):**
- `notifications/initialized` - Client confirms init
- `notifications/cancelled` - Cancel request
- `notifications/progress` - Progress update
- `notifications/message` - Log message
- `notifications/resources/list_changed` - Resource list changed
- `notifications/resources/updated` - Specific resource changed
- `notifications/tools/list_changed` - Tool list changed
- `notifications/prompts/list_changed` - Prompt list changed
- `notifications/roots/list_changed` - Roots changed

### Schema Validation

All parameters validate against JSON Schema. Common patterns:

**String parameter:**
```json
{
  "type": "string",
  "description": "User-friendly description",
  "minLength": 1,
  "maxLength": 100,
  "pattern": "^[a-z_]+$"
}
```

**Enum parameter:**
```json
{
  "type": "string",
  "enum": ["debug", "info", "warning", "error"],
  "description": "Log level"
}
```

**Object parameter:**
```json
{
  "type": "object",
  "properties": {
    "name": { "type": "string" },
    "age": { "type": "number", "minimum": 0 }
  },
  "required": ["name"],
  "additionalProperties": false
}
```

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-14  
**Research Conducted By:** Claude (Anthropic)  
**For Project:** Giru AI - MCP Gateway Design
