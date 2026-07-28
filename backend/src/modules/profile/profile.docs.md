# User Profile Module

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

## Get Profile

HTTP Method: `GET`

URL: `/api/profile`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Accept: application/json
```

Request body: none

Success response:

```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "user": {
      "id": "uuid",
      "fullName": "Giovanni Rossi",
      "email": "giovanni@example.com",
      "gender": "MALE",
      "profileImage": "/uploads/profile/profileImage-avatar-123.png",
      "bio": "Fashion enthusiast and minimalist wardrobe lover.",
      "phoneNumber": "+1 555-123-4567",
      "dateOfBirth": "1995-05-20T00:00:00.000Z",
      "role": "USER",
      "isEmailVerified": false,
      "createdAt": "2026-07-02T00:00:00.000Z",
      "updatedAt": "2026-07-03T00:00:00.000Z"
    }
  }
}
```

Failure response:

```json
{
  "success": false,
  "message": "Unauthorized request",
  "errors": {}
}
```

## Update Profile

HTTP Method: `PATCH`

URL: `/api/profile`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
Accept: application/json
```

Request body (all fields optional, at least one required):

```json
{
  "fullName": "Giovanni Rossi",
  "bio": "Fashion enthusiast and minimalist wardrobe lover.",
  "gender": "MALE",
  "phoneNumber": "+1 555-123-4567",
  "dateOfBirth": "1995-05-20"
}
```

Validation rules:

- `fullName`: optional, 2-80 characters
- `bio`: optional, up to 500 characters
- `gender`: optional, one of `MALE`, `FEMALE`, `OTHER`, `PREFER_NOT_TO_SAY`
- `phoneNumber`: optional, 7-20 characters, digits/spaces/`+`/`-` only
- `dateOfBirth`: optional, ISO date string, cannot be in the future
- At least one field must be present in the body

Success response:

```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "user": {}
  }
}
```

Failure response:

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "body": "At least one field must be provided to update the profile"
  }
}
```

## Upload Profile Picture

HTTP Method: `POST`

URL: `/api/profile/picture`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Accept: application/json
Content-Type: multipart/form-data
```

Request body: form-data with a single file field named `profileImage`. Images are stored on disk under `backend/uploads/profile/` and served statically from `/uploads/profile/<filename>`; only that path is persisted in PostgreSQL. Any previously stored profile picture file is deleted from disk when a new one is uploaded.

`profileImage` is returned as a **host-relative path** (e.g. `/uploads/profile/profileImage-avatar-123.png`), not a fully-qualified URL. The API server itself is reachable at different hostnames depending on the client (`localhost` from a browser/Postman on the same machine, `10.0.2.2` from the Android emulator, a LAN IP from a physical device), so it cannot bake one absolute host into the value. Clients must resolve it against whichever host they used to reach the API (strip the `/api` prefix from their base URL and prepend it to the path). Google-provided profile images remain absolute `https://` URLs and should be used as-is.

Success response:

```json
{
  "success": true,
  "message": "Profile picture updated successfully",
  "data": {
    "user": {
      "profileImage": "/uploads/profile/profileImage-avatar-123.png"
    }
  }
}
```

Failure response:

```json
{
  "success": false,
  "message": "Please upload an image file",
  "errors": {}
}
```

## Remove Profile Picture

HTTP Method: `DELETE`

URL: `/api/profile/picture`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Accept: application/json
```

Request body: none. Deletes the stored file from disk and sets `profileImage` to `null`.

Success response:

```json
{
  "success": true,
  "message": "Profile picture removed successfully",
  "data": {
    "user": {
      "profileImage": null
    }
  }
}
```

## Change Password

HTTP Method: `PATCH`

URL: `/api/profile/password`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
Accept: application/json
```

Request body:

```json
{
  "currentPassword": "Password123",
  "newPassword": "NewPassword123"
}
```

Validation rules:

- `currentPassword`: required
- `newPassword`: required, 6-72 characters, must differ from `currentPassword`

Changing the password invalidates the stored refresh token hash, so any existing refresh token becomes unusable and the user must log in again on other devices.

Success response:

```json
{
  "success": true,
  "message": "Password changed successfully",
  "data": {}
}
```

Failure response:

```json
{
  "success": false,
  "message": "Current password is incorrect",
  "errors": {
    "currentPassword": "Current password is incorrect"
  }
}
```

## Delete Account

HTTP Method: `DELETE`

URL: `/api/profile`

Headers:

```text
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
Accept: application/json
```

Request body:

```json
{
  "password": "NewPassword123"
}
```

This performs a **hard delete** of the user record. Justification: every related table (`WardrobeItem`, `Collection`, `SavedOutfit`, `OutfitHistory`, `Chat`, `VirtualTryOn`, `Recommendation`, `Notification`, `UserPreference`) already declares `onDelete: Cascade` on its foreign key to `User`, so the schema is designed around hard deletes cleaning up all owned data in one transaction. Introducing a soft-delete flag instead would require adding a `deletedAt` filter to every existing and future query that reads a `User` — including the Authentication module's login/refresh/Google-login lookups, which this task is not allowed to modify — creating a real risk of deleted accounts still being able to authenticate. A hard delete keeps the deletion boundary in one place and matches the cascade behavior already modeled in `prisma/schema.prisma`. The stored profile picture file (if any) is also removed from disk.

Success response:

```json
{
  "success": true,
  "message": "Account deleted successfully",
  "data": {}
}
```

Failure response:

```json
{
  "success": false,
  "message": "Password is incorrect",
  "errors": {
    "password": "Password is incorrect"
  }
}
```

## Flutter Integration

All endpoints require the stored access token:

```dart
final token = await tokenStorage.getAccessToken();
final response = await dio.get(
  '/profile',
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
```

If a request returns `401`, follow the same refresh flow used elsewhere in the app: call `/auth/refresh`, store the new tokens, and retry the original request once.

### Mapping onto the existing Flutter data layer

- The response `data.user` object matches the shape already returned by `/auth/register`, `/auth/login`, and `/auth/me`, including the `name`/`fullName` and `profilePicture`/`profileImage` aliases the app's `UserModel.fromJson` (`lib/features/auth/data/models/user_model.dart`) already reads. `UserEntity`/`UserModel` currently only carry `id`, `name`, `email`, `profilePicture` — extend those classes only when the UI needs to display `bio`, `phoneNumber`, or `dateOfBirth`.
- **Implemented**: `POST /profile/picture` is wired up end-to-end. `AuthRemoteDataSource.uploadProfilePicture(File)` (`lib/features/auth/data/datasources/auth_remote_datasource.dart`) sends the file as `FormData` under the field name `profileImage`; `AuthRepositoryImpl.updateProfilePicture` caches the returned user and `AuthProvider.updateProfilePicture` updates `currentUser` and notifies listeners. `ProfileAvatarSection` (`lib/features/profile/presentation/widgets/profile_avatar_section.dart`) calls it via `image_picker` when the edit icon is tapped, and now renders `currentUser.name`/`email`/`profilePicture` instead of hardcoded values.
- `updateProfile`, `removeProfilePicture`, `changePassword`, and `deleteAccount` are **not yet wired up** in Flutter — only the read path (`GET /profile` via the existing `/auth/profile` alias) and the picture upload were connected. Follow the same pattern (repository method → use case → provider method) to add them when the corresponding UI screens are built.
- **Relative image URLs**: since `profileImage` is host-relative (see above), any widget rendering it must resolve the path against the same host the app used to reach the API, not treat it as a ready-to-use URL. Add a small helper (e.g. on `ApiConstants`) that strips the `/api` suffix from `baseUrl` and prepends it to non-`http` `profileImage` values before passing them to `CachedNetworkImage`/`Image.network`.

### Endpoint summary

| Action | Method | Path |
| --- | --- | --- |
| Get profile | GET | `/profile` |
| Update profile | PATCH | `/profile` |
| Upload profile picture | POST | `/profile/picture` |
| Remove profile picture | DELETE | `/profile/picture` |
| Change password | PATCH | `/profile/password` |
| Delete account | DELETE | `/profile` |

## Testing Instructions

1. Run the API with `npm run dev` (or `npm start`).
2. Import `src/modules/profile/profile.postman_collection.json` into Postman.
3. Run `01 Register` or `02 Login` from the Authentication collection and copy `data.tokens.accessToken` into this collection's `accessToken` variable.
4. Run Get Profile, Update Profile, Upload/Remove Profile Picture, Change Password, then Delete Account in order.
5. Alternatively, run the automated smoke test: `node tests/profile-smoke.mjs` (requires `DATABASE_URL` to point at a reachable PostgreSQL instance).
