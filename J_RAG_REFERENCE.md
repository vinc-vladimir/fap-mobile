# Using j-rag MCP Server for FAP Platform Context

The j-rag MCP server indexes the entire FAP platform codebase — both the backend (`fap-service`) and the existing Angular frontend (`fap-client`). Use it to reference existing code patterns, API contracts, data models, and architecture decisions while building the new Flutter app.

## Project ID

All FAP knowledge is stored under project ID: **`fap`**

## Available Tools

### Search (find relevant code/docs by keyword)
```
jrag-mcp_search projectId: "fap" query: "what you're looking for" topK: 10
```

**Use cases:**
- Find API endpoint implementation: `"auth.service.ts login endpoint"`
- Find backend data model: `"VehicleRegistrationPlate entity"`
- Find UI code pattern: `"login content component html"`
- Find NgRx store pattern: `"login store actions and effects"`
- Find WebAuthn flow: `"webauthn login flow passkey"`
- Find OAuth2 setup: `"google oauth url redirect"`

### Ask (get synthesized answers)
```
jrag-mcp_ask projectId: "fap" question: "your question here"
```

**Examples:**
- "How does the existing fap-client handle WebAuthn passkey login?"
- "What is the complete API contract for account management?"
- "Show all NgRx actions in the login feature store"
- "What backend JPA entities exist for the account domain?"
- "How does the auth interceptor attach JWT tokens?"
- "What error model shape does the backend return?"
- "How is the forgot password flow implemented end-to-end?"

## What's Indexed

### fap-client (Angular 17 + Ionic 8) — 83 documents
- `src/main.ts` — App bootstrap, NgRx registration
- `src/app/app.routes.ts` — All 12 routes with AuthGuard
- `src/app/core/store/index.ts` + `state-name.enum.ts` — Root store
- `src/app/core/interceptors/auth.interceptor.ts` — JWT Bearer interceptor
- `src/app/core/services/rest/authorization/auth.service.ts` — Auth REST calls
- `src/app/core/services/rest/authorization/webauthn-api.service.ts` — WebAuthn HTTP
- `src/app/core/services/rest/authorization/webauthn.models.ts` — WebAuthn types
- `src/app/core/services/rest/authorization/response/login-response.model.ts` — Login response type
- `src/app/core/services/webauthn/webauthn.service.ts` — Browser WebAuthn wrapper
- `src/app/core/services/webauthn/base64url.service.ts` — Base64url encoding
- `src/app/core/services/notification.service.ts` — Toast notifications
- `src/app/core/services/rest/account/account.service.ts` — Account REST calls
- **Login feature (11 files):** Store (actions, reducer, effects, selectors), container, content, model, constants
- **Registration feature (17 files):** Store, containers, content, models, module
- **Forgot Password feature (14 files):** Store, containers, content, model
- **Account feature (12 files):** Store, model, container, content
- **Organization feature (5 files):** Model, container, content
- **Settings feature (2 files):** Content component — passkey registration
- **Home feature (6 files):** Container, content, folder page
- **Environments (2 files):** `environment.ts` (dev), `environment.prod.ts`

### fap-service (Spring Boot 3 + Java) — backend
- `Account.java`, `Organization.java`, `AuthUser.java` — JPA entities
- `VehicleRegistrationPlate.java`, `PaymentCard.java` — Additional entities
- `WebAuthnAuthenticationService.java` — WebAuthn backend logic
- `AuthenticationController.java` — Login/token endpoints
- `AuthConfiguration.java` — Security config
- `AuthConfigProperties.java` — WebAuthn RP config

### Documentation
- `README.md` (fap-client & fap-service) — Project READMEs
- Auth improvement plans (Phases 1-6) — Architecture decisions
- `compose.yml` — Docker Compose with full stack
- Grafana dashboard JSONs

## Query Examples for Common Tasks

### When building the Flutter auth feature:
```
jrag-mcp_ask projectId: "fap" question: "Show the complete login flow in fap-client from button click through JWT storage"
```

### When building WebAuthn passkey support:
```
jrag-mcp_ask projectId: "fap" question: "How does fap-client handle the WebAuthn passkey registration flow in settings?"
```

### When building account/organization forms:
```
jrag-mcp_search projectId: "fap" query: "AccountModel OrganizationModel field names and types"
```

### When understanding error handling:
```
jrag-mcp_search projectId: "fap" query: "ErrorModel interface error handling pattern"
```

## Tips
- Use `topK: 5` for focused queries, `topK: 15` for broad exploration
- Hybrid vector + keyword matching
- Documents tagged with `=== FILE: path ===` are extracted from source files
- Full source content is queryable
