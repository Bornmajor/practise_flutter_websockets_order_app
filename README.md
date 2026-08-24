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

Not implemented yet:
- Active WebSocket connection logic (connect/listen/reconnect/send/close).
- Real-time order updates flowing from socket events to UI.
- WebSocket repository/service abstraction and tests.

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

## Configuration

Runtime config lives in:
- `assets/config/config.json`

Keys used:
- `BASE_URL`
- `SOCKET_URL`
- `API_KEY`

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

1. Add a WebSocket service (connect, stream events, reconnect policy).
2. Introduce orders data/domain/presentation layers using socket stream updates.
3. Dispatch socket-driven events into Orders Bloc and reflect live UI updates.
4. Add unit tests for repositories/use cases and bloc tests for state transitions.
5. Add integration tests for config + networking flows.
