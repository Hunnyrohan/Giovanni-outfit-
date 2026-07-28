# Collections Module

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

A collection is a user-curated group of existing wardrobe items (e.g. "Summer Vibes", "Work Capsule"). Adding/removing items from a collection never creates or deletes the underlying `WardrobeItem` — it only adds/removes the join record, so the same wardrobe item can belong to many collections at once.

## Create Collection

HTTP Method: `POST`

URL: `/api/collections`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Accept: application/json
Content-Type: multipart/form-data
```

Request body: form-data.

| Field | Required | Notes |
| --- | --- | --- |
| `name` | yes | 1-80 characters, must be unique per user |
| `description` | no | up to 500 characters |
| `coverImage` | no | image file |

Cover images are stored under `backend/uploads/collections/` and served from `/uploads/collections/<filename>`. Like Wardrobe and Profile, `coverImageUrl` is returned as a **host-relative path** — resolve it against whichever host the client used to reach the API.

Success response:

```json
{
  "success": true,
  "message": "Collection created successfully",
  "data": {
    "collection": {
      "id": "uuid",
      "name": "Summer Vibes",
      "description": "Beach and sunshine outfits",
      "coverImage": "/uploads/collections/coverImage-cover-123.png",
      "coverImageUrl": "/uploads/collections/coverImage-cover-123.png",
      "itemCount": 0,
      "createdAt": "2026-07-04T00:00:00.000Z",
      "updatedAt": "2026-07-04T00:00:00.000Z"
    }
  }
}
```

Failure response (duplicate name for this user):

```json
{
  "success": false,
  "message": "A record with the provided unique value already exists",
  "errors": { "target": ["userId", "name"] }
}
```

## List Collections

HTTP Method: `GET`

URL: `/api/collections`

Query parameters: `page` (default 1), `limit` (default 20, max 100).

Success response:

```json
{
  "success": true,
  "message": "Collections retrieved successfully",
  "data": {
    "collections": [
      { "id": "uuid", "name": "Summer Vibes", "itemCount": 3, "...": "..." }
    ],
    "pagination": { "page": 1, "limit": 20, "total": 1, "totalPages": 1 }
  }
}
```

## Get Collection by Id

HTTP Method: `GET`

URL: `/api/collections/:id`

Returns the collection plus its wardrobe items in their current order.

Success response:

```json
{
  "success": true,
  "message": "Collection retrieved successfully",
  "data": {
    "collection": {
      "id": "uuid",
      "name": "Summer Vibes",
      "itemCount": 2,
      "items": [
        {
          "id": "collection-item-uuid",
          "order": 0,
          "addedAt": "2026-07-04T00:00:00.000Z",
          "wardrobeItem": { "id": "uuid", "name": "Sandals", "imageUrl": "/uploads/wardrobe/...", "...": "..." }
        }
      ],
      "...": "..."
    }
  }
}
```

Failure response (missing, or owned by another user):

```json
{
  "success": false,
  "message": "Collection not found",
  "errors": {}
}
```

## Update Collection

HTTP Method: `PATCH`

URL: `/api/collections/:id`

Request body: form-data, all fields optional (`name`, `description`, `coverImage`). At least one field or a new cover image must be provided. Sending a new `coverImage` deletes the previous cover file from disk.

Success/failure response shapes match Create.

## Delete Collection

HTTP Method: `DELETE`

URL: `/api/collections/:id`

Deletes the collection and its `CollectionItem` join rows only — **the underlying `WardrobeItem` rows are never touched or deleted**. This is verified in `tests/collections-smoke.mjs`: after deleting a collection, a wardrobe item that was in it is fetched again via `GET /wardrobe/:id` and still returns 200.

Success response:

```json
{ "success": true, "message": "Collection deleted successfully", "data": {} }
```

## Add Wardrobe Item to Collection

HTTP Method: `POST`

URL: `/api/collections/:id/items`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
Accept: application/json
```

Request body:

```json
{ "wardrobeItemId": "uuid" }
```

The wardrobe item must belong to the requesting user (checked via the same ownership pattern the Wardrobe module uses) — a wardrobe item owned by someone else, or that doesn't exist, returns 404, same as a missing collection. New items are appended to the end of the collection's order.

Success response: the full collection detail (same shape as Get Collection by Id), status 201.

Failure response (already added):

```json
{
  "success": false,
  "message": "This wardrobe item is already in the collection",
  "errors": {}
}
```

## Reorder Collection Items

HTTP Method: `PATCH`

URL: `/api/collections/:id/items/reorder`

Request body:

```json
{ "orderedWardrobeItemIds": ["uuid-3", "uuid-1", "uuid-2"] }
```

The array must contain exactly the wardrobe item ids currently in the collection (no more, no fewer, no duplicates) in the desired new order — the item at index 0 becomes `order: 0`, and so on.

Failure response (set doesn't match):

```json
{
  "success": false,
  "message": "orderedWardrobeItemIds must include exactly the wardrobe items currently in the collection, with no duplicates",
  "errors": {}
}
```

## Remove Wardrobe Item from Collection

HTTP Method: `DELETE`

URL: `/api/collections/:id/items/:wardrobeItemId`

Removes the join record only; the wardrobe item itself is untouched and remains in the user's wardrobe.

Success response: the full collection detail, status 200.

## Flutter Integration

### Endpoint summary

| Action | Method | Path |
| --- | --- | --- |
| Create collection | POST | `/collections` |
| List collections | GET | `/collections` |
| Get one collection | GET | `/collections/:id` |
| Update collection | PATCH | `/collections/:id` |
| Delete collection | DELETE | `/collections/:id` |
| Add item to collection | POST | `/collections/:id/items` |
| Reorder items | PATCH | `/collections/:id/items/reorder` |
| Remove item from collection | DELETE | `/collections/:id/items/:wardrobeItemId` |

### Mapping onto the Flutter Collections UI

- The `lib/features/wardrobe/` feature already has an "Add collection" flow (`add_collection_screen.dart`, reached from `my_wardrobe_screen.dart`'s floating "Add collection" button) and a `profile_collection_section.dart` grid on the style-profile screen — both currently read mock data from `wardrobe_local_datasource.dart`, not the backend.
- Add a `CollectionsRemoteDataSource` (mirroring `wardrobe`'s remote datasource pattern once it exists, or `auth_remote_datasource.dart` for the general shape) with `getCollections()`, `getCollection(id)`, `createCollection(name, description, {File? cover})`, `updateCollection(id, {...})`, `deleteCollection(id)`, `addItem(collectionId, wardrobeItemId)`, `removeItem(collectionId, wardrobeItemId)`, `reorderItems(collectionId, List<String> orderedIds)`.
- `add_collection_screen.dart`'s grid of selectable wardrobe items maps onto `POST /collections/:id/items` per selected item (create the collection first via `POST /collections`, then add each selected wardrobe item).
- Resolve `coverImageUrl` the same way already documented for Profile and Wardrobe: it's host-relative, so prepend the app's resolved media base URL before passing it to `CachedNetworkImage`/`Image.network`.

## Testing Instructions

1. Run the API with `npm run dev` (or `npm start`).
2. Import `src/modules/collections/collections.postman_collection.json` into Postman.
3. Run `01 Register` or `02 Login` from the Authentication collection, and `01 Add Wardrobe Item` from the Wardrobe collection at least twice, to have real wardrobe item ids to add.
4. Run Create Collection, then Add Item (paste a real wardrobe item id), List, Get One, Reorder, Remove Item, Update, and Delete in order.
5. Alternatively, run the automated smoke test: `node tests/collections-smoke.mjs` (requires `DATABASE_URL` to point at a reachable PostgreSQL instance). It also verifies that deleting a collection does not delete its wardrobe items.
