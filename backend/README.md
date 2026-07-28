# StyleSense AI Backend

Production-oriented Express.js backend foundation for the StyleSense AI final year project.

This repository section contains only Module 0: Project Foundation. Authentication and all feature modules are intentionally not exposed yet.

## Stack

- Node.js 22+
- Express.js with ES Modules
- PostgreSQL
- Prisma ORM
- Zod validation
- JWT middleware foundation
- Multer local uploads
- Helmet, CORS, rate limiting
- Morgan request logging
- Swagger OpenAPI documentation

## Folder Structure

```text
backend/
  prisma/
    schema.prisma
    seed.js
  src/
    common/
    config/
    constants/
    database/
    docs/
    middleware/
    modules/
      auth/
      users/
      wardrobe/
      collections/
      saved_outfits/
      outfit_history/
      ai_stylist/
      chat_history/
      virtual_wear/
      recommendations/
      uploads/
      notifications/
    routes/
    utils/
    app.js
    server.js
  tests/
  uploads/
    profile/
    wardrobe/
    outfits/
    virtual/
```

## Installation

```bash
cd backend
npm install
cp .env.example .env
npm run prisma:generate
```

Set `DATABASE_URL` in `.env` to a running PostgreSQL database before starting the API.

## Database

Create and apply the first migration after PostgreSQL is available:

```bash
npm run prisma:migrate -- --name init
npm run db:seed
```

For production deployments:

```bash
npm run prisma:deploy
```

## Startup

Development:

```bash
npm run dev
```

Production:

```bash
npm start
```

Default base URL:

```text
http://localhost:3000/api/v1
```

## Module 0 API

### Health Check

Method: `GET`

Endpoint:

```text
/api/v1/health
```

Headers:

```text
Accept: application/json
```

Success response:

```json
{
  "success": true,
  "message": "StyleSense AI API is healthy",
  "data": {
    "uptime": 12.34,
    "timestamp": "2026-07-02T00:00:00.000Z"
  }
}
```

Failure response:

```json
{
  "success": false,
  "message": "Route /api/v1/missing not found",
  "errors": {}
}
```

## Swagger

Swagger UI:

```text
http://localhost:3000/api-docs
```

OpenAPI JSON:

```text
http://localhost:3000/api-docs.json
```

## Flutter Datasource Example

```dart
class SystemRemoteDatasource {
  SystemRemoteDatasource(this.client);

  final Dio client;

  Future<Map<String, dynamic>> getHealth() async {
    final response = await client.get('/health');
    return response.data as Map<String, dynamic>;
  }
}
```

## Flutter Repository Example

```dart
class SystemRepository {
  SystemRepository(this.datasource);

  final SystemRemoteDatasource datasource;

  Future<bool> isApiHealthy() async {
    final result = await datasource.getHealth();
    return result['success'] == true;
  }
}
```

## Best Practices Used

- Centralized success and error response helpers
- Global 404 and error middleware
- Strict environment validation at startup
- Request validation middleware for Zod schemas
- JWT authentication and role authorization middleware foundation
- Local upload middleware with folder isolation
- Prisma singleton client with graceful shutdown
- Feature-based module folders ready for Clean Architecture
- Swagger generated from route/module annotations
- No feature routes registered before their module is explicitly requested

## Environment Variables

Use `.env.example` as the source of truth. Never commit real secrets.

Required for startup:

- `DATABASE_URL`
- `JWT_ACCESS_SECRET`
- `JWT_REFRESH_SECRET`

AI keys are present but optional until the AI modules are implemented.

## Virtual Try-On module (`src/modules/virtual_wear`)

Calls the FastAPI AI Service (`ai-service/`, CatVTON) to generate a virtual
try-on image for a wardrobe item. See the root [`README.md`](../README.md)
for the full cross-service flow diagram; this section covers just this
module's internals.

- `virtual-wear.routes.js` - all routes JWT-protected, `POST /` and the
  underlying AI Service calls rate-limited (`aiRateLimiter`) since each
  request triggers real GPU inference.
- `virtual-wear.service.js` - validates wardrobe item ownership, forwards
  the person photo + the wardrobe item's own stored image to the AI Service
  via `src/services/ai-service.client.js`, persists a `VirtualTryOn` row,
  and polls the AI Service for status only while the local record is
  non-terminal (a `COMPLETED`/`FAILED` row is never re-polled).
- `GET /:id/image` proxies the generated image from the AI Service rather
  than exposing its host/path or duplicating the file to disk. The one
  deliberate exception is `POST /:id/save`, which makes a single durable
  copy under `uploads/virtual/` when explicitly saving to Saved Outfits -
  matching how every other image in the app (wardrobe, profile) is served,
  since that endpoint isn't JWT-protected the way the try-on proxy is.
- Requires `AI_SERVICE_URL` (see `.env.example`) pointing at a running
  `ai-service/` instance.

Smoke test (needs the AI Service running too, real GPU inference):
```bash
node tests/virtual-tryon-smoke.mjs
```
