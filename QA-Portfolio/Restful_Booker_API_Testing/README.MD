# 🔵 Proyecto 2 — Restful-Booker API Testing

> Pruebas funcionales de API REST con Postman · 8 endpoints · CRUD completo

---

## 📋 Descripción del Proyecto

**Sistema bajo prueba (SUT):** Restful-Booker — API REST de reservas de hotel diseñada específicamente para práctica de API testing.  
**URL base:** https://restful-booker.herokuapp.com  
**Documentación oficial:** https://restful-booker.herokuapp.com/apidoc/index.html  
**Tipo de pruebas:** API Testing (REST) — validación funcional de endpoints  
**Herramienta principal:** Postman  

---

## 🎯 Objetivo

Validar funcionalmente los 8 endpoints REST de la API Restful-Booker, verificando que cada operación (autenticación, listado, creación, actualización parcial/total y eliminación de reservas) responde con el status code correcto y el body esperado. Identificar comportamientos inesperados documentables como hallazgos.

---

## 📦 Endpoints Probados

| # | Método | Endpoint | Descripción | Status Esperado |
|---|---|---|---|---|
| 1 | `GET` | `/ping` | Health check — verificar que la API está activa | 201 |
| 2 | `POST` | `/auth` | Generar token de autenticación | 200 |
| 3 | `GET` | `/booking` | Listar todas las reservas | 200 |
| 4 | `GET` | `/booking/{id}` | Obtener una reserva por ID | 200 |
| 5 | `POST` | `/booking` | Crear una nueva reserva | 200 |
| 6 | `PUT` | `/booking/{id}` | Actualizar reserva completa | 200 |
| 7 | `PATCH` | `/booking/{id}` | Actualizar reserva parcialmente | 200 |
| 8 | `DELETE` | `/booking/{id}` | Eliminar una reserva | 201 |

---

## 📊 Resultados

| Métrica | Valor |
|---|---|
| Total de endpoints probados | 8 |
| ✅ Pass | 7 |
| ❌ Fail / Hallazgos | 1 |
| Bugs documentados | 1 |

---

## 🐛 Hallazgo Documentado

### BUG-001 — DELETE /booking/{id} devuelve 201 en vez de 204
- **Endpoint:** `DELETE /booking/{id}`
- **Severidad:** Baja (comportamiento funcional correcto, código HTTP incorrecto)
- **Status recibido:** `201 Created`
- **Status esperado:** `204 No Content` (estándar HTTP para eliminaciones exitosas sin cuerpo de respuesta)
- **Descripción:** La eliminación de una reserva se ejecuta correctamente (el registro desaparece al hacer `GET /booking/{id}` posterior), pero el status code devuelto no sigue el estándar HTTP REST. Un cliente que valide estrictamente el código de respuesta interpretaría esta respuesta como un error.

---

## 🔐 Autenticación

La API usa autenticación por **token en Cookie**. El flujo es:

```
POST /auth  →  { "token": "abc123..." }
              ↓
Incluir en headers de PUT, PATCH, DELETE:
Cookie: token=abc123...
```

Las variables de entorno en Postman (`{{token}}` y `{{booking_id}}`) se llenan automáticamente mediante scripts de test al ejecutar las requests en orden.

---

## 📁 Estructura del Proyecto

```
Restful_Booker_API/
├── Postman_Collection.json    # Colección con las 8 requests + tests automáticos
├── API_Report.pdf             # Informe con resultados, evidencia y hallazgos
└── README.md                  # Este archivo
```

---

## 🛠️ Cómo importar y ejecutar la colección

1. Abre **Postman**
2. Click en **Import** → selecciona `Postman_Collection.json`
3. Crea un **Environment** llamado `Restful-Booker ENV` con las variables:
   - `base_url` = `https://restful-booker.herokuapp.com`
   - `token` = *(se llena automático al ejecutar POST /auth)*
   - `booking_id` = *(se llena automático al ejecutar POST /booking)*
4. Ejecuta las requests **en orden** (de 1 a 8) para que las variables se propaguen correctamente
5. Revisa la pestaña **Test Results** de cada request para ver los assertions

---

*← [Volver al portafolio principal](../README.md)*
