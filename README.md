# Practise Flutter WebSockets Order App

A Flutter practice project for an order-style app using clean architecture, dependency injection, and Bloc state management.

Main goal: demonstrate real-time features with WebSockets and support API-driven UI flows.

## Backend Dependency

This mobile app depends on a separate Express.js server for:
- REST API endpoints (for example, menu data)
- WebSocket events (real-time order updates)

The app is not fully functional without that backend service running and reachable on the configured host/port.

When publishing this project to GitHub, include:
- Express.js server repository: https://github.com/Bornmajor/food-express-ws.git
- backend setup instructions (install, env vars, start command)
- API/WebSocket contract notes used by this Flutter app

## Project Status (Verified)

Implemented now:
- App startup with config loading from assets via `AppConfig.loadFromAsset()`.
- Dependency injection via `get_it` service locator.
- HTTP client setup with `dio` and request/response logging in debug mode.
- Menu feature wired end-to-end with:
  - Data source
  - Repository
  - Use case
  - Bloc
  - UI state rendering (loading, loaded, error)
- Routing with `go_router` and bottom-navigation shell between Menu and Orders pages.
- WebSocket order-status updates wired end-to-end:
  - One connection using `SOCKET_URL`
  - Per-order subscriptions after fetch and order creation
  - `STATUS_UPDATE` events merged into the matching order in `OrderBloc`
  - Automatic reconnect after three seconds with re-subscription
  - Socket cleanup when `OrderBloc` closes
- Automated unit tests for WebSocket parsing, reconnect behavior, repository delegation, and Bloc state transitions.
- GitHub Actions Android release workflow with runtime config generation and signed APK publishing.

## Current Architecture

Layered structure currently used for Menu feature:
- `data`: remote data source + repository implementation
- `domain`: entities + repository contracts + use cases
- `presentation`: bloc/events/states + screens/widgets

Core modules:
- `core/config`: app configuration loading
- `core/network`: Dio client configuration
- `core/di`: dependency registration
- `core/error`: failure mapping and error handling

## How Real-Time Order Status Updates Work

1. `OrderScreen` sends `FetchOrdersEvent` when it opens.
2. `OrderBloc._fetchOrders` loads all existing orders from `GET /api/admin/orders`.
3. For every returned order, the Bloc calls `subscribeToOrderUseCase(order.orderId)`.
4. The socket data source sends this subscription message to the backend:

   ```json
   {
     "action": "subscribe",
     "order_id": "ORD-1234"
   }
   ```

5. When an admin changes an order status, the backend sends a `STATUS_UPDATE` WebSocket message containing the complete updated order.
6. `OrderSocketDataSource` parses `message['order']` into `OrderItemModel`.
7. `WatchOrderUpdatesUseCase` forwards the update through the repository to `OrderBloc`.
8. `_listenToOrderUpdates` dispatches `OrderStatusUpdatedEvent`.
9. Bloc invokes `_onStatusUpdated`, replaces the matching item in `state.listOrderItems` by `orderId`, and emits a new `OrderLoadedState`.
10. `BlocBuilder` in `OrderScreen` rebuilds `ListOrdersWidget`; `OrderItemWidget` displays the new `orderItem.status`.

The Bloc owns the displayed order list. `StreamBuilder` is unnecessary because the WebSocket stream is consumed by the Bloc, while `BlocBuilder` renders the resulting state.

When the Bloc closes, it cancels `_orderUpdatesSubscription` and closes the WebSocket. If the connection drops before that, the socket data source reconnects after three seconds and re-subscribes to each tracked order ID.

## Testing

Run all tests locally:

```powershell
flutter test
```

Current automated coverage includes:

- `OrderSocketDataSource`: `STATUS_UPDATE` parsing, ignored `CONNECTED` messages, malformed payload errors, subscription frames, reconnect re-subscription, and cleanup.
- `OrderRepositoryImpl`: forwarding socket updates, mapping socket errors to `Failure`, and socket delegation.
- `OrderBloc`: order replacement by ID, unknown update handling, fetched and newly created order subscriptions, socket failure handling, stream cancellation, and socket cleanup.

The end-to-end test against the separate Express backend remains a future addition.

## Configuration

Runtime config lives in:
- `assets/config/config.json`

Keys used:
- `BASE_URL`
- `SOCKET_URL`
- `API_KEY`

`config.json` is ignored by Git. Copy `assets/config/config.example.json` for local development and enter your local values. Do not use a laptop LAN address such as `192.168.x.x` for a released APK; use a publicly reachable HTTPS/WSS backend instead.

## GitHub Actions APK Releases

The workflow in `.github/workflows/release-android.yml` runs when a `v*` tag is pushed, or manually from the GitHub Actions tab. It creates `config.json` and the Android signing files only inside the GitHub Actions runner, runs `flutter analyze` and `flutter test`, builds split APKs, uploads them as workflow artifacts, and attaches them to a GitHub release for tag runs.

Add these values in GitHub under **Settings > Secrets and variables > Actions > Secrets**:

- `BASE_URL`: Public API address, for example `https://api.example.com/api`.
- `SOCKET_URL`: Public WebSocket address, for example `wss://api.example.com`.
- `API_KEY`: Client API key. APK contents can be extracted, so enforce API authorization on the backend and do not store a privileged secret here.
- `ANDROID_KEYSTORE_BASE64`: Base64-encoded Android release keystore file.
- `ANDROID_KEYSTORE_PASSWORD`: Keystore password.
- `ANDROID_KEY_ALIAS`: Keystore key alias.
- `ANDROID_KEY_PASSWORD`: Key password.

Create a keystore once and keep a secure backup. This key is required for future updates to the same Android application:

```powershell
keytool -genkeypair -v -keystore android\app\release.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
[Convert]::ToBase64String([IO.File]::ReadAllBytes('android\app\release.jks')) | Set-Clipboard
```

Paste the clipboard value into `ANDROID_KEYSTORE_BASE64`, then delete the local `release.jks` or keep it in a secure location outside the repository. Create a release by pushing a version tag:

```powershell
git tag v1.0.0
git push origin v1.0.0
```

## Running on Android Real Device

If your backend runs on your laptop, do **not** use `localhost` in config.
Use your machine LAN IP instead, for example:

- `BASE_URL`: `http://192.168.x.x:3000/api`
- `SOCKET_URL`: `ws://192.168.x.x:3000`

Requirements:
- Phone and laptop on the same Wi-Fi network.
- Backend server listening on the configured port.
- Firewall allows incoming connections to backend port.

## API Notes

Menu API parser expects:
- Wrapper object with `data` array.
- Item fields: `id`, `name`, `price`, `image_url`.

Important mapping detail:
- Model uses `image_url` from response (snake_case).
- Using `imageUrl` (camelCase) against current API payload causes null/type errors.

## Dependencies

Main packages currently in use:
- `go_router`
- `get_it`
- `dio`
- `equatable`
- `dartz`
- `bloc_concurrency`
- `flutter_bloc`

## Next Recommended Steps

1. Add an end-to-end test against the Express REST and WebSocket backend.
2. Deploy the backend behind public HTTPS/WSS endpoints for release builds.
3. Configure GitHub repository secrets and publish the first signed version tag.
