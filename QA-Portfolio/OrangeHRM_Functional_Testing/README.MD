# 🟠 Proyecto 1 — OrangeHRM Functional Testing

> Pruebas funcionales manuales sobre un sistema HRMS real · Ciclo 01

---

## 📋 Descripción del Proyecto

**Sistema bajo prueba (SUT):** OrangeHRM Open Source — software de gestión de recursos humanos ampliamente usado en la industria.  
**URL:** https://opensource-demo.orangehrmlive.com  
**Credenciales demo:** `Admin / admin123`  
**Tipo de pruebas:** Funcional manual, exploratoria, compatibilidad básica  
**Ciclo:** Ciclo 01 — Módulos de Autenticación, PIM y Leave  

---

## 🎯 Objetivo

Validar funcionalmente los flujos críticos del sistema OrangeHRM — autenticación, gestión de empleados (PIM) y gestión de permisos (Leave) — verificando que el sistema opera conforme al comportamiento esperado de un HRMS estándar e identificando defectos antes del cierre del ciclo.

---

## 📦 Alcance

### ✅ Incluido
- Autenticación: login válido/inválido, campos vacíos, recuperar contraseña, logout
- PIM: búsqueda, alta, edición y eliminación de empleados
- Leave: solicitud de permisos, validaciones de fecha, cancelación, control de roles

### ❌ Excluido
- Módulos Recruitment, Performance, Payroll, Time & Attendance
- Pruebas de carga, estrés o seguridad ofensiva
- Integraciones con sistemas externos

---

## 📊 Resultados del Ciclo

| Métrica | Valor |
|---|---|
| Total de casos diseñados | 22 |
| Casos ejecutados | 18 |
| ✅ Pass | 13 |
| ❌ Fail | 5 |
| ⚠️ Bloqueados | 4 |
| Tasa de aprobación | 72% |
| Cobertura funcional estimada | 78% |
| Bugs encontrados | 3 |

### Resultados por módulo

| Módulo | TCs | Pass | Fail | Bloqueado | % Aprobación |
|---|---|---|---|---|---|
| Autenticación | 7 | 6 | 1 | 0 | 86% |
| PIM | 7 | 6 | 1 | 0 | 86% |
| Leave | 8 | 1 | 3 | 4 | 25% |

---

## 🐛 Bugs Encontrados

### BUG-001 — Error 504 Gateway Timeout al recuperar contraseña
- **Módulo:** Autenticación
- **Severidad:** Alta
- **Estado:** Abierto
- **TC relacionado:** TC-005
- **Descripción:** Al solicitar la recuperación de contraseña con el usuario `Admin`, el servidor procesa la solicitud ~1 minuto y devuelve un Error 504 Gateway Timeout sin completar el flujo.

---

### BUG-002 — Sistema acepta fecha de nacimiento futura sin validación
- **Módulo:** PIM — Personal Details
- **Severidad:** Media
- **Estado:** Abierto
- **TC relacionado:** TC-013
- **Descripción:** El campo `Date of Birth` permite guardar fechas futuras sin ningún mensaje de error, mostrando `Successfully Updated` con un valor inválido persistido en base de datos.

---

### BUG-003 — Formulario Apply Leave no renderiza sus campos
- **Módulo:** Leave
- **Severidad:** Alta
- **Estado:** Abierto
- **TC relacionados:** TC-015, TC-016, TC-017 (+ TC-018 a TC-021 bloqueados)
- **Descripción:** Al navegar a Leave > Apply, la sección aparece vacía sin mostrar los campos esperados (Leave Type, From Date, To Date, botón Apply), bloqueando completamente el flujo de solicitud de permisos.

---

## 📁 Estructura del Proyecto

```
OrangeHRM_Functional_Testing/
├── Test_Plan/
│   └── Test_Plan.pdf              # Objetivo, alcance, riesgos, cronograma
├── Test_Cases/
│   └── Test_Cases.xlsx            # 22 casos con pasos, resultado esperado y real
├── Coverage_Matrix/
│   └── Coverage_Matrix.xlsx       # Trazabilidad + resumen por módulo + gráfico
├── Bug_Reports/
│   ├── Jira_Exports/              # Issues exportados desde Jira
│   └── Screenshots/               # Evidencia por módulo
│       ├── Login/
│       ├── PIM/
│       └── Leave/
├── SQL/
│   └── queries.sql                # 16 queries de validación de datos en backend
├── Test_Summary_Report/
│   └── Final_Report.pdf           # Cierre del ciclo con métricas y conclusiones
└── README.md                      # Este archivo
```

---

## 🛠️ Herramientas

| Herramienta | Uso |
|---|---|
| Chrome + DevTools | Ejecución y captura de evidencia |
| Jira | Reporte y seguimiento de bugs |
| Excel | Test Cases y Coverage Matrix |
| SQL (MySQL) | Validación de integridad en base de datos |

---

## 💡 Aprendizajes clave de este proyecto

- Un entorno de demo público compartido introduce riesgos reales (datos modificados por otros usuarios, reinicios periódicos) — documenté esto en el Test Plan como riesgo explícito.
- BUG-003 demostró la importancia de documentar el **impacto en cadena**: un solo bug bloqueó 4 casos adicionales. La justificación de los casos "No ejecutados" es tan importante como los que sí se ejecutaron.
- BUG-002 (fecha de nacimiento futura) es un ejemplo de defecto que pasa desapercibido en pruebas del camino feliz — solo aparece cuando pruebas casos negativos y de límite.
- La query `QA-SQL-007` del archivo `queries.sql` demuestra cómo verificar a nivel de base de datos un defecto que el frontend "acepta sin quejarse".

---

*← [Volver al portafolio principal](../README.md)*
