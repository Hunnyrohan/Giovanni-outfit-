# StyleSense AI

AI-based outfit analysis and smart wardrobe application - a Final Year Project.

Three independently-deployable services:

```
outfit_ai_app/            Flutter app (this directory's root)
outfit_ai_app/backend/    Node.js/Express + PostgreSQL/Prisma API
outfit_ai_app/ai-service/ FastAPI + CatVTON (Virtual Try-On inference)
```

See each service's own README for setup details specific to it:
[`backend/README.md`](backend/README.md), [`ai-service/README.md`](ai-service/README.md).
This root README covers how they fit together, using **Virtual Try-On** as the
worked example since it's the one flow that touches all three.

## Architecture

```
┌─────────────┐        JWT-authenticated REST        ┌──────────────────┐
│   Flutter   │ ───────────────────────────────────► │  Node.js Backend │
│  (Android)  │ ◄─────────────────────────────────── │  (Express/Prisma)│
└─────────────┘        {success, message, data}       └────────┬─────────┘
                                                                 │ multipart POST,
                                                                 │ internal only -
                                                                 │ never reached by Flutter
                                                                 ▼
                                                        ┌──────────────────┐
                                                        │   FastAPI AI     │
                                                        │ Service (CatVTON)│
                                                        └──────────────────┘
```

- Flutter never talks to the AI Service directly - it only knows the Node API.
  Node validates the JWT, checks wardrobe-item ownership, and is the only
  thing that calls the AI Service (`AI_SERVICE_URL`, internal-network only).
- The AI Service has no idea Node or Flutter exist - it's a generic
  provider-based job API (see `ai-service/README.md`'s Clean Architecture
  section). Today's provider is CatVTON; swapping it needs zero changes here.
- Generated images are never duplicated across services unnecessarily: Node
  proxies the AI Service's output through its own JWT-protected endpoint
  (`GET /api/virtual-tryon/:id/image`) rather than copying the file, **except**
  on an explicit "Save to Outfits" action, where Node makes exactly one
  durable copy into its own `uploads/` (matching how every other image in
  the app - wardrobe photos, profile pictures - is stored and served).

## Virtual Try-On flow (end-to-end)

```
Wardrobe screen
  │ tap "Try virtually" on an item
  ▼
Virtual Wear screen (Flutter)
  │ tap the preview → pick a photo (camera/gallery, image_picker)
  │ tap "Generate"
  ▼
POST /api/virtual-tryon  (Node)                    [multipart: wardrobeItemId + personImage]
  │ verifyJWT → check wardrobe item ownership
  │ reads the wardrobe item's own stored image as the garment
  ▼
POST /virtual-tryon  (FastAPI)                     [multipart: person_image + garment_image + garment_type]
  │ creates a job (PENDING), returns immediately
  │ background: MediaPipe mask → CatVTON diffusion inference → save PNG
  ▼
Node persists a VirtualTryOn row (provider="catvton", providerJobId=<FastAPI jobId>)
  │ returns {id, status: PENDING, ...} to Flutter
  ▼
Flutter polls GET /api/virtual-tryon/:id                     [exponential backoff: 2,2,3,5,8,13,21,34,55,60s, 10min cap]
  │ Node polls FastAPI's GET /virtual-tryon/status/:jobId only while non-terminal,
  │ then caches the terminal result in its own DB (no repeated upstream polling once done)
  ▼
status = COMPLETED  →  Flutter navigates to the Result screen
  │ fetches the image via Node's authenticated proxy (Dio, JWT auto-attached)
  ▼
Result screen: Before/After toggle, Save (→ Saved Outfits), Share (native sheet),
                Download (device gallery via `gal`), Delete, Generate Again
```

## Database

Reused the existing `VirtualTryOn` Prisma model (it already existed for a
previously-planned Replicate integration) rather than creating a new table -
only added the two genuinely missing fields:

```prisma
model VirtualTryOn {
  id               String        @id @default(uuid())
  userId           String
  wardrobeItemId   String?       // added: links back to the garment tried on
  personImageUrl   String
  clothingImageUrl String
  resultImageUrl   String?
  provider         String        @default("catvton")  // was "replicate"
  providerJobId    String?
  status           TryOnStatus   @default(PENDING)
  processingTime   Float?        // added: seconds, surfaced from the AI Service
  errorMessage     String?
  createdAt        DateTime      @default(now())
  updatedAt        DateTime      @updatedAt

  user             User          @relation(...)
  wardrobeItem     WardrobeItem? @relation(...)
}
```

"Saving" a result creates a normal `SavedOutfit` + `SavedOutfitItem` row -
no schema changes needed there, it already supported this shape.

## API (Node) - `/api/virtual-tryon`

| Method | Path | Description |
|---|---|---|
| `POST` | `/` | multipart: `wardrobeItemId`, `personImage` → creates a job, `202` |
| `GET` | `/:id` | Poll status; proxies the AI Service only while non-terminal |
| `GET` | `/:id/image` | Streams the generated image (JWT-protected, no raw file paths ever returned) |
| `GET` | `/history` | List the user's try-on jobs, most recent first |
| `POST` | `/:id/save` | Copies the result into Saved Outfits |
| `DELETE` | `/:id` | Deletes the job (best-effort cleanup on the AI Service too) |

Full Swagger docs at `http://localhost:3000/api-docs` once the backend is running.

## Environment variables

New backend variable (see `backend/.env.example`):

```
AI_SERVICE_URL=http://localhost:8000
AI_SERVICE_TIMEOUT_MS=120000
```

AI Service variables (GPU/precision tuning) are documented in full in
[`ai-service/README.md`](ai-service/README.md#configuration) - notably
`MODEL_DEVICE=auto`, `MODEL_PRECISION=fp16`, and `IMAGE_WIDTH`/`IMAGE_HEIGHT`
(384×512 default), tuned and verified on a 4GB VRAM GPU.

## Running everything locally

Three terminals:

```bash
# 1. AI Service (GPU inference)
cd ai-service
.venv\Scripts\activate
uvicorn main:app --host 0.0.0.0 --port 8000

# 2. Node backend
cd backend
npm start

# 3. Flutter app
flutter run
```

Android emulator note: `lib/core/constants/api_constants.dart`'s `baseUrl`
uses `10.0.2.2` (the emulator's alias for the host machine's `localhost`) -
no changes needed for the standard emulator setup.

## Testing

```bash
# AI Service - fast unit tests (mock provider, no GPU/network needed)
cd ai-service && pytest -v

# Backend - smoke tests against a running server
cd backend
node tests/auth-smoke.mjs
node tests/ai-smoke.mjs
node tests/virtual-tryon-smoke.mjs   # full flow: register → wardrobe item →
                                      # create try-on → poll → COMPLETED →
                                      # fetch image → save to outfits →
                                      # history → delete

# Flutter
flutter analyze
```

`virtual-tryon-smoke.mjs` needs both the backend and the AI Service running
(real CatVTON inference, ~15-30s on GPU) - it exercises the entire flow
described above against real services, not mocks.

## Known limitations / next steps

- **Deployment**: everything above is a local dev setup (`localhost`
  services). A real deployment needs the AI Service on GPU-backed
  infrastructure (see `ai-service/README.md`'s hardware notes - it needs a
  real NVIDIA GPU, ideally ≥8GB VRAM for comfortable headroom, though it's
  been verified working on 4GB) reachable from wherever Node is hosted via
  `AI_SERVICE_URL`.
- **Interactive UI verification**: the full flow was verified end-to-end via
  automated smoke tests hitting real, running services (backend + AI Service
  + Postgres), including real CatVTON GPU inference. Manual interactive
  click-through on the emulator was attempted but not completed in this
  environment (ADB touch-tap input doesn't register reliably here - only
  swipe gestures do, a pre-existing environment quirk unrelated to app code).
  `flutter analyze` is clean and the app boots and navigates via swipe
  without runtime errors; a manual pass on a physical device or a
  properly-configured emulator is recommended before considering this
  fully QA'd.
- Mask generation is a deliberate simplification (MediaPipe pose landmarks,
  not precise segmentation) - see `ai-service/README.md` for why, and what
  upgrading it later would involve.
