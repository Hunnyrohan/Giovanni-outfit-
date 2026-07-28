# Authentication Module

Base URL for local Android emulator:

```text
http://10.0.2.2:3000/api
```

Base URL for local browser/Postman:

```text
http://localhost:3000/api
```

## Register User

HTTP Method: `POST`

URL: `/api/auth/register`

Headers:

```text
Content-Type: application/json
Accept: application/json
```

Request body:

```json
{
  "fullName": "Giovanni Rossi",
  "email": "giovanni@example.com",
  "password": "Password123",
  "gender": "MALE",
  "profileImage": "https://example.com/avatar.png"
}
```

Validation rules:

- `fullName`: required, 2-80 characters
- `email`: required, valid email, normalized to lowercase
- `password`: required, 8-72 characters, at least one uppercase letter, one lowercase letter, and one number
- `gender`: optional, one of `MALE`, `FEMALE`, `OTHER`, `PREFER_NOT_TO_SAY`
- `profileImage`: optional valid URL

Success response:

```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "uuid",
      "fullName": "Giovanni Rossi",
      "email": "giovanni@example.com",
      "gender": "MALE",
      "profileImage": "https://example.com/avatar.png",
      "role": "USER",
      "isEmailVerified": false,
      "createdAt": "2026-07-02T00:00:00.000Z",
      "updatedAt": "2026-07-02T00:00:00.000Z"
    },
    "tokens": {
      "accessToken": "jwt",
      "refreshToken": "jwt",
      "tokenType": "Bearer"
    }
  }
}
```

Failure response:

```json
{
  "success": false,
  "message": "An account with this email already exists",
  "errors": {
    "email": "Email is already registered"
  }
}
```

## Login User

HTTP Method: `POST`

URL: `/api/auth/login`

Headers:

```text
Content-Type: application/json
Accept: application/json
```

Request body:

```json
{
  "email": "giovanni@example.com",
  "password": "Password123"
}
```

Validation rules:

- `email`: required, valid email
- `password`: required

Success response:

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {},
    "tokens": {
      "accessToken": "jwt",
      "refreshToken": "jwt",
      "tokenType": "Bearer"
    }
  }
}
```

Failure response:

```json
{
  "success": false,
  "message": "Invalid email or password",
  "errors": {}
}
```

## Refresh Access Token

HTTP Method: `POST`

URL: `/api/auth/refresh`

Headers:

```text
Content-Type: application/json
Accept: application/json
```

Request body:

```json
{
  "refreshToken": "jwt"
}
```

The backend also accepts the `refreshToken` HTTP-only cookie set by register/login.

Success response:

```json
{
  "success": true,
  "message": "Access token refreshed successfully",
  "data": {
    "user": {},
    "tokens": {
      "accessToken": "new-jwt",
      "refreshToken": "new-jwt",
      "tokenType": "Bearer"
    }
  }
}
```

Failure response:

```json
{
  "success": false,
  "message": "Invalid or expired refresh token",
  "errors": {}
}
```

## Google Login

HTTP Method: `POST`

URL: `/api/auth/google`

Headers:

```text
Content-Type: application/json
Accept: application/json
```

Request body:

```json
{
  "idToken": "GOOGLE_ID_TOKEN_FROM_FLUTTER"
}
```

`googleIdToken` is also accepted as an alias.

Validation rules:

- `idToken`: required Google ID token issued for the OAuth client configured in `GOOGLE_CLIENT_ID`

Success response:

```json
{
  "success": true,
  "message": "Google login successful",
  "data": {
    "user": {},
    "tokens": {
      "accessToken": "jwt",
      "refreshToken": "jwt",
      "tokenType": "Bearer"
    }
  },
  "token": "jwt",
  "user": {}
}
```

Failure response:

```json
{
  "success": false,
  "message": "Invalid Google ID token",
  "errors": {}
}
```

Flutter request example:

```dart
final googleUser = await GoogleSignIn().signIn();
final googleAuth = await googleUser?.authentication;

final response = await dio.post(
  '/auth/google',
  data: {'idToken': googleAuth?.idToken},
);
```

Backend requirement:

```env
GOOGLE_CLIENT_ID=your-google-oauth-client-id.apps.googleusercontent.com
```

## Logout

HTTP Method: `POST`

URL: `/api/auth/logout`

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
  "message": "Logout successful",
  "data": {}
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

## Get Current User

HTTP Method: `GET`

URL: `/api/auth/me`

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
  "message": "Current user retrieved successfully",
  "data": {
    "user": {}
  }
}
```

Failure response:

```json
{
  "success": false,
  "message": "Invalid access token",
  "errors": {}
}
```

## Flutter Integration

Store the `accessToken` in secure storage and attach it to private requests:

```dart
final token = await tokenStorage.getAccessToken();
final response = await dio.get(
  '/auth/me',
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
```

Store the `refreshToken` in secure storage as well. When the API returns `401`, call `/auth/refresh`, replace both tokens, and retry the original request once.

Recommended storage:

- `flutter_secure_storage` for access and refresh tokens
- Do not store tokens in shared preferences
- Clear both tokens after logout

Error handling:

```dart
try {
  final response = await dio.post('/auth/login', data: body);
  final data = response.data['data'];
  await tokenStorage.saveTokens(
    accessToken: data['tokens']['accessToken'],
    refreshToken: data['tokens']['refreshToken'],
  );
} on DioException catch (error) {
  final message = error.response?.data['message'] ?? 'Authentication failed';
  throw AuthException(message);
}
```

## Testing Instructions

1. Run the API with `npm start`.
2. Import `src/modules/auth/auth.postman_collection.json` into Postman.
3. Run Register.
4. Run Login if the account already exists.
5. Copy `data.tokens.accessToken` into the collection variable `accessToken`.
6. Copy `data.tokens.refreshToken` into the collection variable `refreshToken`.
7. Run Me, Refresh, and Logout.
