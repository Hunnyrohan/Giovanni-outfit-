# Saved Outfits Module

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

A saved outfit is a named combination of existing wardrobe items (e.g. "Weekend Casual", "Date Night"). Adding/removing items from a saved outfit never creates or deletes the underlying `WardrobeItem` — it only adds/removes the `SavedOutfitItem` join record, so the same wardrobe item can belong to many saved outfits at once. A saved outfit must always contain at least one wardrobe item.

## Create Saved Outfit

HTTP Method: `POST`

URL: `/api/saved-outfits`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Accept: application/json
Content-Type: multipart/form-data
```

Request body: form-data.

| Field | Required | Notes |
| --- | --- | --- |
| `name` | yes | 1-80 characters |
| `notes` | no | up to 500 characters |
| `occasion` | no | one of `CASUAL`, `FORMAL`, `BUSINESS`, `PARTY`, `SPORTS`, `TRAVEL`, `DATE`, `FESTIVAL`, `OTHER` |
| `season` | no | one of `SPRING`, `SUMMER`, `AUTUMN`, `WINTER`, `ALL_SEASON` |
| `wardrobeItemIds` | yes | at least one wardrobe item id; send as repeated form fields, a JSON array string, or a comma-separated string |
| `coverImage` | no | image file |

Every id in `wardrobeItemIds` must belong to the requesting user — an id that doesn't exist, or belongs to someone else, returns 404. Cover images are stored under `backend/uploads/outfits/` and served from `/uploads/outfits/<filename>`. Like Wardrobe and Collections, `coverImageUrl` is returned as a **host-relative path** — resolve it against whichever host the client used to reach the API.

Success response:

```json
{
  "success": true,
  "message": "Saved outfit created successfully",
  "data": {
    "savedOutfit": {
      "id": "uuid",
      "name": "Weekend Casual",
      "notes": "Comfy weekend look",
      "occasion": "CASUAL",
      "season": "AUTUMN",
      "coverImage": "/uploads/outfits/coverImage-cover-123.png",
      "coverImageUrl": "/uploads/outfits/coverImage-cover-123.png",
      "isFavorite": false,
      "itemCount": 2,
      "items": [
        {
          "id": "saved-outfit-item-uuid",
          "addedAt": "2026-07-04T00:00:00.000Z",
          "wardrobeItem": { "id": "uuid", "name": "Denim Jacket", "imageUrl": "/uploads/wardrobe/...", "...": "..." }
        }
      ],
      "createdAt": "2026-07-04T00:00:00.000Z",
      "updatedAt": "2026-07-04T00:00:00.000Z"
    }
  }
}
```

Failure response (missing/foreign wardrobe item id):

```json
{
  "success": false,
  "message": "Wardrobe item not found: <id>",
  "errors": {}
}
```

## List Saved Outfits

HTTP Method: `GET`

URL: `/api/saved-outfits`

Query parameters: `page` (default 1), `limit` (default 20, max 100), `occasion`, `season`, `search` (matches against name, case-insensitive), `favorite` (`true`/`false`).

Success response:

```json
{
  "success": true,
  "message": "Saved outfits retrieved successfully",
  "data": {
    "savedOutfits": [
      { "id": "uuid", "name": "Weekend Casual", "itemCount": 2, "isFavorite": false, "...": "..." }
    ],
    "pagination": { "page": 1, "limit": 20, "total": 1, "totalPages": 1 }
  }
}
```

## Get Saved Outfit by Id

HTTP Method: `GET`

URL: `/api/saved-outfits/:id`

Returns the saved outfit plus the full wardrobe item details for every item it contains.

Failure response (missing, or owned by another user):

```json
{
  "success": false,
  "message": "Saved outfit not found",
  "errors": {}
}
```

## Update Saved Outfit

HTTP Method: `PATCH`

URL: `/api/saved-outfits/:id`

Request body: form-data, all fields optional: `name`, `notes`, `occasion`, `season`, `coverImage`, `addWardrobeItemIds`, `removeWardrobeItemIds` (same accepted formats as `wardrobeItemIds` on Create). At least one field, item change, or a new cover image must be provided. Sending a new `coverImage` deletes the previous cover file from disk. `addWardrobeItemIds` and `removeWardrobeItemIds` can be sent together in the same request (removals and additions are both validated against the resulting item set before anything is written, so a request that would leave the saved outfit with zero items is rejected with no partial changes applied).

Success/failure response shapes match Create.

Failure response (would leave zero items):

```json
{
  "success": false,
  "message": "A saved outfit must contain at least one wardrobe item",
  "errors": {}
}
```

## Delete Saved Outfit

HTTP Method: `DELETE`

URL: `/api/saved-outfits/:id`

Deletes the saved outfit and its `SavedOutfitItem` join rows only — **the underlying `WardrobeItem` rows are never touched or deleted**. This is verified in `tests/saved-outfits-smoke.mjs`: after deleting a saved outfit, a wardrobe item that was in it is fetched again via `GET /wardrobe/:id` and still returns 200.

Success response:

```json
{ "success": true, "message": "Saved outfit deleted successfully", "data": {} }
```

## Mark/Unmark Favorite

HTTP Method: `PATCH`

URL: `/api/saved-outfits/:id/favorite`

Request body:

```json
{ "isFavorite": true }
```

Success response: the saved outfit summary, status 200.

## Duplicate Saved Outfit

HTTP Method: `POST`

URL: `/api/saved-outfits/:id/duplicate`

Creates a new saved outfit with the same name (suffixed with " (copy)"), notes, occasion, season, cover image, and wardrobe item links as the original. The original is left unchanged.

Success response: the new saved outfit detail, status 201.

## Flutter Integration

### Endpoint summary

| Action | Method | Path |
| --- | --- | --- |
| Create saved outfit | POST | `/saved-outfits` |
| List saved outfits | GET | `/saved-outfits` |
| Get one saved outfit | GET | `/saved-outfits/:id` |
| Update saved outfit | PATCH | `/saved-outfits/:id` |
| Delete saved outfit | DELETE | `/saved-outfits/:id` |
| Mark/unmark favorite | PATCH | `/saved-outfits/:id/favorite` |
| Duplicate saved outfit | POST | `/saved-outfits/:id/duplicate` |

### Mapping onto the Flutter Saved Outfits UI

- `lib/features/wardrobe/presentation/screens/saved_outfits_screen.dart` currently renders `wardrobeProvider.filteredSavedOutfits`, sourced from mock data in `wardrobe_local_datasource.dart` via `WardrobeProvider.fetchSavedOutfits()` — this is the screen to wire up once a `SavedOutfitsRemoteDataSource` exists.
- Add a `SavedOutfitsRemoteDataSource` (mirroring the Wardrobe/Collections remote datasource shape once they exist) with `getSavedOutfits({page, limit, occasion, season, search, favorite})`, `getSavedOutfit(id)`, `createSavedOutfit(name, wardrobeItemIds, {notes, occasion, season, File? coverImage})`, `updateSavedOutfit(id, {...})`, `deleteSavedOutfit(id)`, `setFavorite(id, bool)`, `duplicateSavedOutfit(id)`.
- The screen's `onFavoriteTap` callback (currently `wardrobeProvider.toggleFavorite(item.id)`) maps onto `PATCH /saved-outfits/:id/favorite`.
- The screen's floating "Add collection" button currently pushes `/add-collection` — once Saved Outfits creation is wired to the backend, that flow's "create" step should call `POST /saved-outfits` with the selected wardrobe item ids.
- Resolve `coverImageUrl` the same way already documented for Profile, Wardrobe, and Collections: it's host-relative, so prepend the app's resolved media base URL before passing it to `CachedNetworkImage`/`Image.network`.

## Testing Instructions

1. Run the API with `npm run dev` (or `npm start`).
2. Import `src/modules/saved_outfits/saved-outfits.postman_collection.json` into Postman.
3. Run `01 Register` or `02 Login` from the Authentication collection, and `01 Add Wardrobe Item` from the Wardrobe collection at least twice, to have real wardrobe item ids to add.
4. Run Create Saved Outfit, List, Get One, Update, Set Favorite, Duplicate, and Delete in order.
5. Alternatively, run the automated smoke test: `node tests/saved-outfits-smoke.mjs` (requires `DATABASE_URL` to point at a reachable PostgreSQL instance). It also verifies that deleting a saved outfit does not delete its wardrobe items, and that an update which would remove all remaining items is rejected.
