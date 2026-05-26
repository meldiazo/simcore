# SIMCORE FrontEnd — Validación HU-FE-01

## Backend validado

Base URL:

https://simcore-production.up.railway.app

## Endpoints verificados

- POST /api/v1/iam/auth/login
- GET /api/v1/iam/auth/me
- POST /api/v1/iam/auth/refresh
- GET /actuator/health
- GET /v3/api-docs

## Resultado de login

Estado: OK

Campos recibidos:

- accessToken: recibido
- refreshToken: recibido
- tokenType: recibido
- expiresIn: recibido / no recibido

## Resultado de /auth/me

Campos recibidos:

- id:
- username:
- tenantId:
- roles:


## Estado final HU-FE-01

Estado: CERRADA 

## HU-FE-02 — Centralizar clientes API con Bearer real

Estado: CERRADA

Validaciones realizadas:

- Se creó `lib/core/network/api_client_providers.dart`.
- Se centralizaron los clientes:
  - `publicIamApiClientProvider`
  - `iamApiClientProvider`
  - `simulationApiClientProvider`
- Se eliminó `simcoreApiClientProvider`.
- Ya no se instancia `ApiClient(...)` dentro de `lib/features`.
- `auth` usa `iamApiClientProvider`.
- `register` usa `iamApiClientProvider`.
- `stratova/simulation` usa `simulationApiClientProvider`.
- Se comprobó en Chrome DevTools que la llamada:
  `GET /api/v1/simulation/companies/1/modules`
  envía header `Authorization: Bearer`.
- El endpoint respondió `500 Internal Server Error`, pero la HU-FE-02 queda validada porque el token Bearer sí viaja correctamente. El 500 queda registrado como problema de datos/backend o `companyId` de prueba.

Observación de seguridad:

- No guardar tokens reales en el repositorio.
- No compartir tokens completos en documentación ni chats.