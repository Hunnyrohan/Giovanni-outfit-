# Wardrobe Module

Base URL for local Android emulator:

```text
http://10.0.2.2:3000/api
```

Base URL for local browser/Postman:

```text
http://localhost:3000/api
```

All routes below are protected and require the header:

```text
Authorization: Bearer ACCESS_TOKEN
```

Array fields (`colors`, `occasion`, `tags`) accept either a JSON-encoded array string (`["CASUAL","PARTY"]`) or a comma-separated string (`CASUAL,PARTY`) in multipart form fields, since HTML form fields are always plain strings. Enum fields (`category`, `season`, `occasion`) are case-insensitive on input and are always returned upper-cased.

## Add Wardrobe Item

HTTP Method: `POST`

URL: `/api/wardrobe`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Accept: application/json
Content-Type: multipart/form-data
```

Request body: form-data.

| Field | Required | Notes |
| --- | --- | --- |
| `name` | yes | 1-120 characters |
| `category` | yes | one of `TOP`, `BOTTOM`, `DRESS`, `OUTERWEAR`, `SHOES`, `ACCESSORY`, `BAG`, `OTHER` |
| `image` | yes | the item photo file |
| `description` | no | up to 1000 characters |
| `subCategory` | no | free text, e.g. `coat`, `sneakers` |
| `primaryColor` | no | free text |
| `colors` | no | comma-separated or JSON array |
| `brand` | no | free text |
| `size` | no | free text |
| `material` | no | free text |
| `season` | no | one of `SPRING`, `SUMMER`, `AUTUMN`, `WINTER`, `ALL_SEASON` (default `ALL_SEASON`) |
| `occasion` | no | comma-separated or JSON array of `CASUAL`, `FORMAL`, `BUSINESS`, `PARTY`, `SPORTS`, `TRAVEL`, `DATE`, `FESTIVAL`, `OTHER` |
| `tags` | no | comma-separated or JSON array of free-form tags |

Images are stored on disk under `backend/uploads/wardrobe/` and served statically from `/uploads/wardrobe/<filename>`. Like the Profile module, `imageUrl` is returned as a **host-relative path** — resolve it against whichever host the client used to reach the API (strip `/api` from the base URL and prepend it), since the API server has no single absolute hostname that works for every client (browser vs. Android emulator vs. physical device).

Success response:

```json
{
  "success": true,
  "message": "Wardrobe item added successfully",
  "data": {
    "item": {
      "id": "uuid",
      "name": "Beige Trench Coat",
      "description": "Long trench coat for autumn",
      "notes": "Long trench coat for autumn",
      "imageUrl": "/uploads/wardrobe/image-coat-123.png",
      "category": "OUTERWEAR",
      "subCategory": "coat",
      "primaryColor": "beige",
      "colors": ["beige", "tan"],
      "brand": "Zara",
      "size": "M",
      "material": "cotton",
      "season": "AUTUMN",
      "occasion": ["CASUAL", "TRAVEL"],
      "tags": ["coat", "autumn"],
      "isFavorite": false,
      "isArchived": false,
      "createdAt": "2026-07-04T00:00:00.000Z",
      "updatedAt": "2026-07-04T00:00:00.000Z"
    }
  }
}
```

Failure response:

```json
{
  "success": false,
  "message": "Please upload an image for the wardrobe item",
  "errors": {}
}
```

## List Wardrobe Items

HTTP Method: `GET`

URL: `/api/wardrobe`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Accept: application/json
```

Query parameters (all optional):

| Param | Notes |
| --- | --- |
| `page` | default `1` |
| `limit` | default `20`, max `100` |
| `category` | filter by exact category |
| `season` | filter by exact season |
| `occasion` | filter to items that include this occasion |
| `color` | matches `primaryColor` (case-insensitive) or the `colors` list |
| `search` | matches `name` (case-insensitive contains) or the `tags` list |
| `favorite` | `true`/`false` — only favorited/non-favorited items |
| `includeArchived` | `true`/`false` — include archived items (excluded by default) |

Success response:

```json
{
  "success": true,
  "message": "Wardrobe items retrieved successfully",
  "data": {
    "items": [ { "id": "uuid", "name": "Beige Trench Coat", "...": "..." } ],
    "pagination": { "page": 1, "limit": 20, "total": 2, "totalPages": 1 }
  }
}
```

## Get Wardrobe Stats

HTTP Method: `GET`

URL: `/api/wardrobe/stats`

Success response:

```json
{
  "success": true,
  "message": "Wardrobe stats retrieved successfully",
  "data": {
    "stats": {
      "totalItems": 12,
      "favoriteItems": 3,
      "itemsByCategory": { "TOP": 5, "BOTTOM": 4, "OUTERWEAR": 3 }
    }
  }
}
```

## Get Wardrobe Item by Id

HTTP Method: `GET`

URL: `/api/wardrobe/:id`

Success response:

```json
{
  "success": true,
  "message": "Wardrobe item retrieved successfully",
  "data": { "item": { "id": "uuid", "...": "..." } }
}
```

Failure response (missing, or owned by another user):

```json
{
  "success": false,
  "message": "Wardrobe item not found",
  "errors": {}
}
```

## Update Wardrobe Item

HTTP Method: `PATCH`

URL: `/api/wardrobe/:id`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Accept: application/json
Content-Type: multipart/form-data
```

Request body: form-data. All fields are optional (same fields as Add, minus `image` requirement), plus `isArchived` (`true`/`false`). At least one field or a new `image` file must be provided. Sending a new `image` deletes the previous image file from disk.

Success response: same shape as Add.

Failure response:

```json
{
  "success": false,
  "message": "At least one field or an image must be provided to update the wardrobe item",
  "errors": {}
}
```

## Mark/Unmark Favorite

HTTP Method: `PATCH`

URL: `/api/wardrobe/:id/favorite`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
Accept: application/json
```

Request body:

```json
{ "isFavorite": true }
```

Success response: same shape as Add, with `isFavorite` updated.

## Delete Wardrobe Item

HTTP Method: `DELETE`

URL: `/api/wardrobe/:id`

This performs a **hard delete**. Justification: `CollectionItem` and `SavedOutfitItem` already declare `onDelete: Cascade` on their `wardrobeItem` foreign key in `prisma/schema.prisma`, so removing a `WardrobeItem` automatically and atomically removes any collection/saved-outfit links that reference it at the database level — no manual cleanup step is needed in the service, and there is no orphaned-reference risk. The item's image file is also removed from disk.

Success response:

```json
{
  "success": true,
  "message": "Wardrobe item deleted successfully",
  "data": {}
}
```

## Flutter Integration

### Endpoint summary

| Action | Method | Path |
| --- | --- | --- |
| Add item | POST | `/wardrobe` |
| List items | GET | `/wardrobe` |
| Get stats | GET | `/wardrobe/stats` |
| Get one item | GET | `/wardrobe/:id` |
| Update item | PATCH | `/wardrobe/:id` |
| Toggle favorite | PATCH | `/wardrobe/:id/favorite` |
| Delete item | DELETE | `/wardrobe/:id` |

### Mapping onto the Flutter Smart Wardrobe screens

- The current `lib/features/wardrobe/` feature (`my_wardrobe_screen.dart`, `capture_screen.dart`, `product_details_screen.dart`, `wardrobe_provider.dart`) reads entirely from a local/mock datasource (`wardrobe_local_datasource.dart`) — none of it calls the backend yet. Wiring it up (not done here, per scope) would look like:
- Add a `WardrobeRemoteDataSource` (mirroring `lib/features/auth/data/datasources/auth_remote_datasource.dart`) with methods `getItems(filters)`, `getItem(id)`, `addItem(fields, File image)`, `updateItem(id, fields, {File? image})`, `setFavorite(id, bool)`, `deleteItem(id)`, `getStats()`.
- `addItem`/`updateItem` should build `dio.FormData` with `MultipartFile.fromFile(image.path, filename: ...)` under the field name `image`, matching the Multer field name here, plus the other fields as plain string form fields (join array fields with commas, e.g. `tags.join(',')`).
- The `capture_screen.dart` "Confirm to add to collection" flow (photo already taken) maps naturally onto `POST /wardrobe` with the captured file as `image`.
- `product_details_screen.dart`'s favorite heart icon maps onto `PATCH /wardrobe/:id/favorite`.
- Resolve `imageUrl` the same way already documented for the Profile module: it is host-relative, so prepend the app's own resolved media base URL (see `ApiConstants.resolveMediaUrl` if already added on the Flutter side) rather than using it as-is.

## Testing Instructions

1. Run the API with `npm run dev` (or `npm start`).
2. Import `src/modules/wardrobe/wardrobe.postman_collection.json` into Postman.
3. Run `01 Register` or `02 Login` from the Authentication collection and copy `data.tokens.accessToken` into this collection's `accessToken` variable.
4. Run Add Item (attach any image file to the `image` form field), then List, Get One, Update, Toggle Favorite, Stats, and Delete in order.
5. Alternatively, run the automated smoke test: `node tests/wardrobe-smoke.mjs` (requires `DATABASE_URL` to point at a reachable PostgreSQL instance).
