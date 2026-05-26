# SIMCORE Frontend

Frontend Flutter de **SIMCORE**: Simulador de Empresas para la Enseñanza Universitaria.

SIMCORE es una plataforma universitaria de simulación empresarial cuyo objetivo es formar criterio empresarial mediante decisiones, consecuencias, trazabilidad y análisis. No es una aplicación administrativa común ni una colección de pantallas decorativas. Cada vista debe ayudar al estudiante o docente a entender, justificar y defender decisiones dentro de una empresa simulada.

---

## 1. Objetivo del frontend

El frontend de SIMCORE tiene tres responsabilidades principales:

1. Convertir la lógica del backend en una experiencia clara para estudiantes y docentes.
2. Mostrar el flujo de simulación empresarial de forma integrada.
3. Evitar que una pantalla parezca terminada si todavía depende de datos demo o lógica no integrada.

El avance del frontend no se mide por cantidad de pantallas, sino por integración real, claridad pedagógica y capacidad de mostrar consecuencias entre módulos.

---

## 2. Stack técnico

- Flutter
- Dart
- Riverpod
- Dio
- Flutter Secure Storage
- GoRouter
- Backend Java / Spring Boot
- API protegida con Bearer Token

---

## 3. Módulos oficiales de SIMCORE

El frontend debe respetar los cinco módulos definidos por el backend y por la visión del producto:

1. **Mercado**
2. **Inversión y Financiamiento**
3. **Estructuras Organizativas**
4. **Contabilidad**
5. **Análisis General**

No deben crearse módulos visuales independientes fuera de esta estructura sin justificación funcional y contrato real con backend.

---

## 4. Requisitos previos

Antes de ejecutar el proyecto, instalar:

- Flutter SDK
- Dart SDK
- Chrome para ejecución web
- Git
- Backend local de SIMCORE, si se usará `APP_ENV=local`

Verificar instalación:

```bash
flutter --version
dart --version
git --version