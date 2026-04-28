# products_task

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

## Local Products REST API (no webservice needed)

This repo includes a tiny local API server you can run to get **ready endpoints** for products CRUD.

### Run the API

From the repo root:

```bash
dart run tool/products_api_server.dart
```

The server runs on `http://localhost:3001` (or set `PORT=xxxx`).

### Using it from a mobile app

- **Android emulator**: use base URL `http://10.0.2.2:3001`
- **iOS simulator**: use base URL `http://localhost:3001`
- **Real phone**: run the API on your PC and use `http://<YOUR_PC_LAN_IP>:3001`

You can override the app base URL with:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3001
```

## Free hosting (for real devices) – Render

If you want a base URL that works on any real device without being on your local network, you can deploy the API for free.

- **What to deploy**: the Node/Express API in `server/` (Render runs Node for you)
- **Config included**: `render.yaml` + `server/Dockerfile`

### Steps

1. Push this repo to GitHub.
2. Create a new Render service from this repo (it will detect `render.yaml`).
3. After deploy, you’ll get a public URL like:
   - `https://products-task-api-xxxx.onrender.com`

### Use it in the app

Run:

```bash
flutter run --dart-define=API_BASE_URL=https://products-task-api-xxxx.onrender.com
```

### Endpoints

- **Health**
  - `GET /health`

- **Products**
  - `GET /products` (optional query: `?q=searchText`)
  - `GET /products/:id`
  - `POST /products`
  - `PUT /products/:id`
  - `PATCH /products/:id`
  - `DELETE /products/:id`

### Product JSON shape

```json
{
  "id": 1,
  "imageUrl": "https://...",
  "name": "Mechanical Keyboard",
  "type": "Accessory",
  "price": 79.99
}
```
