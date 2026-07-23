-- ================================================================
--  QA PORTFOLIO — Proyecto 1: OrangeHRM Functional Testing
--  Archivo  : queries.sql
--  Motor    : MySQL (esquema OrangeHRM Open Source 4.x)
--  Autor    : QA Tester Junior
--  Propósito: Consultas SQL que un QA Tester ejecutaría para
--             validar integridad de datos en la capa de base
--             de datos durante y después del ciclo de pruebas.
--
--  IMPORTANTE: Estas queries están escritas sobre el esquema
--  público documentado de OrangeHRM Open Source. En un entorno
--  real con acceso a la BD, se ejecutarían directamente contra
--  la base de datos del entorno QA — nunca contra producción.
--
--  ÍNDICE:
--    § 1  AUTENTICACIÓN          (QA-SQL-001  a  QA-SQL-007)
--    § 2  PIM — EMPLEADOS        (QA-SQL-008  a  QA-SQL-018)
--    § 3  LEAVE — PERMISOS       (QA-SQL-019  a  QA-SQL-027)
--    § 4  INTEGRIDAD DE DATOS    (QA-SQL-028  a  QA-SQL-033)
--    § 5  AUDITORÍA GENERAL      (QA-SQL-034  a  QA-SQL-038)
-- ================================================================


-- ================================================================
-- §1  AUTENTICACIÓN
-- ================================================================

-- QA-SQL-001
-- Objetivo  : Verificar que el usuario Admin existe y está activo.
-- TC        : TC-001 (login con credenciales válidas)
-- Resultado : Debe devolver 1 fila con user_name = 'Admin' y status = 1.
SELECT u.id            AS user_id,
       u.user_name,
       r.name          AS rol,
       u.status        AS activo,
       e.emp_firstname AS nombre,
       e.emp_lastname  AS apellido
FROM   ohrm_user u
JOIN   ohrm_user_role r ON u.user_role_id = r.id
LEFT JOIN hs_hr_employee e ON u.emp_number = e.emp_number
WHERE  u.user_name = 'Admin';


-- QA-SQL-002
-- Objetivo  : Confirmar que la contraseña del Admin NO está vacía ni en texto plano.
-- TC        : TC-001, TC-002
-- Resultado : La columna user_password debe mostrar un hash, no 'admin123'.
SELECT user_name,
       user_password,
       CASE
           WHEN user_password = 'admin123'
               THEN '❌ CRITICO — contraseña guardada en texto plano'
           WHEN user_password IS NULL OR user_password = ''
               THEN '❌ Contraseña vacía'
           ELSE '✅ Contraseña hasheada correctamente'
       END AS estado_seguridad
FROM   ohrm_user
WHERE  user_name = 'Admin';


-- QA-SQL-003
-- Objetivo  : Listar todos los usuarios activos con su rol asignado.
-- TC        : TC-001, TC-022
-- Resultado : Muestra qué usuarios tienen acceso y con qué nivel de privilegio.
SELECT u.id,
       u.user_name,
       r.name    AS rol,
       u.status  AS activo,
       e.emp_firstname,
       e.emp_lastname
FROM   ohrm_user u
JOIN   ohrm_user_role r  ON u.user_role_id = r.id
LEFT JOIN hs_hr_employee e ON u.emp_number = e.emp_number
WHERE  u.status = 1
ORDER  BY r.name, u.user_name;


-- QA-SQL-004
-- Objetivo  : Verificar que el usuario ESS (sam444) existe y tiene el rol correcto.
-- TC        : TC-022 (usuario sin rol Admin no ve el módulo Admin)
-- Resultado : Debe devolver rol = 'ESS', NO 'Admin'.
SELECT u.user_name,
       r.name   AS rol_asignado,
       u.status AS activo,
       CASE
           WHEN r.name = 'Admin' THEN '❌ ERROR — tiene rol Admin, no ESS'
           WHEN r.name = 'ESS'   THEN '✅ Rol ESS correcto'
           ELSE '⚠️  Rol inesperado: ' || r.name
       END AS validacion_rol
FROM   ohrm_user u
JOIN   ohrm_user_role r ON u.user_role_id = r.id
WHERE  u.user_name = 'sam444';


-- QA-SQL-005
-- Objetivo  : Listar todos los roles definidos en el sistema.
-- TC        : TC-022 — referencia de roles disponibles.
-- Resultado : Catálogo completo de roles (Admin, ESS, Supervisor, etc.).
SELECT id,
       name         AS nombre_rol,
       display_name AS nombre_visible,
       is_predefined
FROM   ohrm_user_role
ORDER  BY id;


-- QA-SQL-006
-- Objetivo  : Detectar usuarios con el mismo correo electrónico (correos duplicados).
-- TC        : Buena práctica de auditoría — el sistema debería prevenir esto.
-- Resultado : Si devuelve filas, hay correos duplicados entre usuarios.
SELECT work_email,
       COUNT(*) AS cantidad_usuarios
FROM   hs_hr_employee
WHERE  work_email IS NOT NULL
  AND  work_email <> ''
GROUP  BY work_email
HAVING COUNT(*) > 1
ORDER  BY cantidad_usuarios DESC;


-- QA-SQL-007
-- Objetivo  : Contar usuarios por rol — snapshot general de accesos.
-- TC        : Auditoría transversal de seguridad.
-- Resultado : Cuántos usuarios existen por cada tipo de rol.
SELECT r.name    AS rol,
       COUNT(u.id) AS total_usuarios
FROM   ohrm_user u
JOIN   ohrm_user_role r ON u.user_role_id = r.id
GROUP  BY r.name
ORDER  BY total_usuarios DESC;


-- ================================================================
-- §2  PIM — GESTIÓN DE EMPLEADOS
-- ================================================================

-- QA-SQL-008
-- Objetivo  : Verificar que el empleado creado en TC-010 existe en la BD.
-- TC        : TC-010 (agregar nuevo empleado con datos obligatorios)
-- Resultado : Debe devolver 1 fila con los datos del empleado creado.
--             Reemplazar 'Samuel' / 'Ospina' con el nombre que usaste.
SELECT emp_number,
       emp_firstname,
       emp_lastname,
       employee_id    AS id_empleado,
       work_email,
       emp_mobile
FROM   hs_hr_employee
WHERE  emp_firstname = 'Samuel'
  AND  emp_lastname  = 'Ospina';


-- QA-SQL-009
-- Objetivo  : Buscar empleado por su Employee ID (número visible en la UI).
-- TC        : TC-010 — post-validación de creación (ID generado: 114123).
-- Resultado : Debe devolver el registro del empleado con ese ID.
SELECT emp_number,
       emp_firstname,
       emp_lastname,
       employee_id,
       emp_dob,
       emp_mobile
FROM   hs_hr_employee
WHERE  employee_id = '114123';


-- QA-SQL-010
-- Objetivo  : Confirmar que la edición del campo Mobile persiste en la BD.
-- TC        : TC-012 (editar información personal de un empleado existente)
-- Resultado : El campo emp_mobile debe reflejar el valor actualizado en la prueba.
SELECT emp_firstname,
       emp_lastname,
       emp_mobile     AS telefono_actual,
       CASE
           WHEN emp_mobile IS NULL OR emp_mobile = ''
               THEN '⚠️  Campo vacío — posible fallo de persistencia'
           ELSE '✅ Valor guardado: ' || emp_mobile
       END AS validacion
FROM   hs_hr_employee
WHERE  emp_firstname = 'Samuel'
  AND  emp_lastname  = 'Ospina';


-- QA-SQL-011
-- Objetivo  : BUG-002 — Confirmar que la fecha de nacimiento futura fue guardada.
-- TC        : TC-013 (fecha de nacimiento con fecha futura)
-- Resultado : Si emp_dob > CURDATE(), el bug existe y quedó persistido en BD.
SELECT emp_firstname,
       emp_lastname,
       emp_dob                              AS fecha_nacimiento,
       CURDATE()                            AS fecha_hoy,
       DATEDIFF(emp_dob, CURDATE())         AS dias_en_el_futuro,
       CASE
           WHEN emp_dob > CURDATE()
               THEN '❌ BUG-002 CONFIRMADO — fecha futura persistida en BD'
           WHEN emp_dob IS NULL
               THEN '— Sin fecha de nacimiento registrada'
           WHEN YEAR(emp_dob) < 1900
               THEN '⚠️  Fecha anómala — año anterior a 1900'
           ELSE '✅ Fecha de nacimiento válida'
       END AS estado_bug_002
FROM   hs_hr_employee
WHERE  emp_firstname = 'Samuel'
  AND  emp_lastname  = 'Ospina';


-- QA-SQL-012
-- Objetivo  : Detección masiva de fechas de nacimiento inválidas en toda la BD.
-- TC        : TC-013 — verificar si el problema de BUG-002 afecta a más empleados.
-- Resultado : Lista todos los empleados con fechas de nacimiento sospechosas.
SELECT emp_firstname,
       emp_lastname,
       emp_dob,
       CASE
           WHEN emp_dob > CURDATE()             THEN '❌ Fecha futura (BUG-002)'
           WHEN YEAR(emp_dob) < 1900            THEN '❌ Año < 1900 — dato inválido'
           WHEN emp_dob > DATE_SUB(CURDATE(), INTERVAL 15 YEAR)
               THEN '⚠️  Menor de 15 años — posible error'
           ELSE '✅ Válida'
       END AS estado
FROM   hs_hr_employee
WHERE  emp_dob IS NOT NULL
ORDER  BY emp_dob DESC;


-- QA-SQL-013
-- Objetivo  : Verificar que el empleado eliminado en TC-014 ya NO existe.
-- TC        : TC-014 (eliminar registro de empleado)
-- Resultado : Debe devolver 0 — si devuelve 1, el registro no fue eliminado.
--             Reemplazar con el nombre del empleado de prueba que eliminaste.
SELECT COUNT(*) AS registros_encontrados,
       CASE
           WHEN COUNT(*) = 0 THEN '✅ Eliminación confirmada — registro no existe'
           ELSE '❌ ERROR — el registro todavía existe en la BD'
       END AS resultado
FROM   hs_hr_employee
WHERE  emp_firstname = 'NombreEmpleadoPrueba'
  AND  emp_lastname  = 'ApellidoPrueba';


-- QA-SQL-014
-- Objetivo  : Buscar empleado por nombre parcial (simulación de la búsqueda UI).
-- TC        : TC-008 (buscar empleado por nombre existente)
-- Resultado : Debe devolver los empleados cuyo nombre contiene el texto buscado.
SELECT emp_number,
       emp_firstname,
       emp_lastname,
       employee_id
FROM   hs_hr_employee
WHERE  emp_firstname LIKE '%John%'    -- Reemplazar con el nombre que buscaste en TC-008
   OR  emp_lastname  LIKE '%John%'
ORDER  BY emp_lastname;


-- QA-SQL-015
-- Objetivo  : Confirmar que una búsqueda con nombre inexistente devuelve 0 resultados.
-- TC        : TC-009 (buscar empleado con nombre inexistente)
-- Resultado : Debe devolver 0 — valida que la BD tampoco tiene ese registro.
SELECT COUNT(*) AS resultados,
       CASE
           WHEN COUNT(*) = 0 THEN '✅ Correcto — ningún empleado con ese nombre'
           ELSE '⚠️  Existen registros con ese nombre en BD'
       END AS validacion
FROM   hs_hr_employee
WHERE  emp_firstname LIKE '%XYZ_NoExiste_999%'
   OR  emp_lastname  LIKE '%XYZ_NoExiste_999%';


-- QA-SQL-016
-- Objetivo  : Listar los últimos 10 empleados creados.
-- TC        : TC-010 — auditoría post-creación.
-- Resultado : El empleado recién creado debe aparecer en este listado.
SELECT emp_number,
       emp_firstname,
       emp_lastname,
       employee_id
FROM   hs_hr_employee
ORDER  BY emp_number DESC
LIMIT  10;


-- QA-SQL-017
-- Objetivo  : Detectar empleados con campos obligatorios vacíos (inconsistencias de datos).
-- TC        : TC-011 (validación de campos obligatorios)
-- Resultado : No debería devolver filas si las validaciones del frontend funcionan.
SELECT emp_number,
       emp_firstname,
       emp_lastname,
       CASE
           WHEN emp_firstname IS NULL OR emp_firstname = '' THEN '❌ Sin nombre'
           ELSE '✅'
       END AS estado_nombre,
       CASE
           WHEN emp_lastname IS NULL OR emp_lastname = '' THEN '❌ Sin apellido'
           ELSE '✅'
       END AS estado_apellido
FROM   hs_hr_employee
WHERE  (emp_firstname IS NULL OR emp_firstname = '')
    OR (emp_lastname  IS NULL OR emp_lastname  = '');


-- QA-SQL-018
-- Objetivo  : Detectar Employee IDs duplicados (el sistema debe garantizar unicidad).
-- TC        : Auditoría de integridad — complemento de TC-010.
-- Resultado : Si devuelve filas, hay IDs duplicados — defecto grave de integridad.
SELECT employee_id,
       COUNT(*) AS cantidad,
       GROUP_CONCAT(emp_firstname || ' ' || emp_lastname SEPARATOR ', ') AS empleados
FROM   hs_hr_employee
WHERE  employee_id IS NOT NULL
  AND  employee_id <> ''
GROUP  BY employee_id
HAVING COUNT(*) > 1;


-- ================================================================
-- §3  LEAVE — GESTIÓN DE PERMISOS
-- ================================================================

-- QA-SQL-019
-- Objetivo  : Listar todas las solicitudes de permiso registradas en el sistema.
-- TC        : TC-015 a TC-021 — vista general del módulo Leave.
-- Resultado : Si devuelve 0 filas, confirma el impacto de BUG-003 (no se pudo crear).
SELECT lr.id             AS solicitud_id,
       e.emp_firstname   AS nombre,
       e.emp_lastname    AS apellido,
       lt.name           AS tipo_permiso,
       lr.date_applied   AS fecha_solicitud,
       lr.start_date     AS fecha_inicio,
       lr.end_date       AS fecha_fin,
       DATEDIFF(lr.end_date, lr.start_date) + 1 AS dias_solicitados,
       ls.name           AS estado
FROM   ohrm_leave_request lr
JOIN   hs_hr_employee   e  ON lr.emp_number    = e.emp_number
JOIN   ohrm_leave_type  lt ON lr.leave_type_id = lt.id
JOIN   ohrm_leave_status ls ON lr.status       = ls.id
ORDER  BY lr.date_applied DESC;


-- QA-SQL-020
-- Objetivo  : Contar solicitudes por estado (Pending, Approved, Cancelled, Rejected).
-- TC        : TC-015, TC-018 — verificar cambios de estado.
-- Resultado : Distribución de solicitudes por estado actual.
SELECT ls.name        AS estado,
       COUNT(lr.id)   AS total_solicitudes
FROM   ohrm_leave_request lr
JOIN   ohrm_leave_status  ls ON lr.status = ls.id
GROUP  BY ls.name
ORDER  BY total_solicitudes DESC;


-- QA-SQL-021
-- Objetivo  : Verificar solicitudes en estado Pending Approval.
-- TC        : TC-015 (solicitar permiso → estado debe ser Pending Approval).
-- Resultado : Las solicitudes recién creadas deben aparecer aquí.
SELECT lr.id,
       e.emp_firstname,
       e.emp_lastname,
       lt.name       AS tipo_permiso,
       lr.start_date,
       lr.end_date
FROM   ohrm_leave_request lr
JOIN   hs_hr_employee  e  ON lr.emp_number    = e.emp_number
JOIN   ohrm_leave_type lt ON lr.leave_type_id = lt.id
JOIN   ohrm_leave_status ls ON lr.status      = ls.id
WHERE  ls.name = 'Pending Approval'
ORDER  BY lr.date_applied DESC;


-- QA-SQL-022
-- Objetivo  : BUG-003 — Confirmar que no existen solicitudes del empleado Samuel Ospina.
-- TC        : TC-015, TC-016, TC-017 — bloqueados por BUG-003.
-- Resultado : Si devuelve 0, confirma que el formulario Apply Leave no funcionó.
SELECT COUNT(*) AS solicitudes_creadas,
       CASE
           WHEN COUNT(*) = 0
               THEN '✅ Confirmado BUG-003 — no se pudo crear ninguna solicitud'
           ELSE '⚠️  Existen solicitudes — revisar si BUG-003 fue corregido'
       END AS validacion_bug_003
FROM   ohrm_leave_request lr
JOIN   hs_hr_employee e ON lr.emp_number = e.emp_number
WHERE  e.emp_firstname = 'Samuel'
  AND  e.emp_lastname  = 'Ospina';


-- QA-SQL-023
-- Objetivo  : Verificar el saldo de días de permiso disponibles por empleado.
-- TC        : TC-021 (saldo disminuye tras aprobar un permiso).
-- Resultado : Muestra asignado, usado y saldo real por empleado y tipo de permiso.
SELECT e.emp_firstname,
       e.emp_lastname,
       lt.name            AS tipo_permiso,
       le.no_of_days      AS dias_asignados,
       le.days_used       AS dias_usados,
       (le.no_of_days - le.days_used) AS saldo_disponible,
       CASE
           WHEN (le.no_of_days - le.days_used) < 0
               THEN '❌ Saldo negativo — inconsistencia de datos'
           WHEN le.days_used > le.no_of_days
               THEN '❌ Días usados superan el asignado'
           ELSE '✅ Saldo consistente'
       END AS estado
FROM   ohrm_leave_entitlement le
JOIN   hs_hr_employee  e  ON le.emp_number    = e.emp_number
JOIN   ohrm_leave_type lt ON le.leave_type_id = lt.id
ORDER  BY e.emp_lastname, lt.name;


-- QA-SQL-024
-- Objetivo  : Detectar traslape de fechas en solicitudes del mismo empleado.
-- TC        : TC-020 (solicitar permiso en fechas con traslape).
-- Resultado : Si devuelve filas, el sistema permite traslapes — posible bug.
SELECT a.id           AS solicitud_a,
       b.id           AS solicitud_b,
       e.emp_firstname,
       e.emp_lastname,
       a.start_date   AS inicio_a,
       a.end_date     AS fin_a,
       b.start_date   AS inicio_b,
       b.end_date     AS fin_b,
       lt.name        AS tipo_permiso
FROM   ohrm_leave_request a
JOIN   ohrm_leave_request b  ON  a.emp_number    = b.emp_number
                             AND  a.id            < b.id
                             AND  a.start_date   <= b.end_date
                             AND  a.end_date     >= b.start_date
JOIN   hs_hr_employee     e  ON  a.emp_number    = e.emp_number
JOIN   ohrm_leave_type    lt ON  a.leave_type_id = lt.id;


-- QA-SQL-025
-- Objetivo  : Verificar que una solicitud cancelada cambió correctamente de estado.
-- TC        : TC-018 (cancelar solicitud de permiso pendiente).
-- Resultado : La solicitud debe aparecer con estado 'Cancelled'.
SELECT lr.id,
       e.emp_firstname,
       e.emp_lastname,
       ls.name        AS estado_actual,
       lr.start_date,
       lr.end_date,
       CASE
           WHEN ls.name = 'Cancelled' THEN '✅ Cancelación confirmada en BD'
           WHEN ls.name = 'Pending Approval'
               THEN '❌ Sigue en Pending — cancelación no persistió'
           ELSE '⚠️  Estado inesperado: ' || ls.name
       END AS validacion
FROM   ohrm_leave_request lr
JOIN   hs_hr_employee  e  ON lr.emp_number = e.emp_number
JOIN   ohrm_leave_status ls ON lr.status   = ls.id
WHERE  e.emp_firstname = 'Samuel'
  AND  e.emp_lastname  = 'Ospina'
ORDER  BY lr.id DESC
LIMIT  5;


-- QA-SQL-026
-- Objetivo  : Listar todos los tipos de permiso configurados en el sistema.
-- TC        : TC-015, TC-017 — referencia de Leave Types disponibles.
-- Resultado : Catálogo de permisos (Casual, Medical, Annual, etc.).
SELECT id,
       name         AS tipo_permiso,
       operational_country,
       is_active    AS activo
FROM   ohrm_leave_type
WHERE  is_active = 1
ORDER  BY name;


-- QA-SQL-027
-- Objetivo  : Filtrar solicitudes por rango de fechas (simula el filtro de la UI).
-- TC        : TC-019 (consultar listado filtrando por rango de fechas).
-- Resultado : Solo solicitudes cuyas fechas estén dentro del rango indicado.
--             Ajustar las fechas al rango que usaste en tu prueba.
SELECT lr.id,
       e.emp_firstname,
       e.emp_lastname,
       lt.name       AS tipo_permiso,
       lr.start_date,
       lr.end_date,
       ls.name       AS estado
FROM   ohrm_leave_request lr
JOIN   hs_hr_employee  e  ON lr.emp_number    = e.emp_number
JOIN   ohrm_leave_type lt ON lr.leave_type_id = lt.id
JOIN   ohrm_leave_status ls ON lr.status      = ls.id
WHERE  lr.start_date >= '2026-07-01'   -- Reemplazar con tu fecha de inicio del filtro
  AND  lr.end_date   <= '2026-07-31'   -- Reemplazar con tu fecha de fin del filtro
ORDER  BY lr.start_date;


-- ================================================================
-- §4  INTEGRIDAD DE DATOS
-- ================================================================

-- QA-SQL-028
-- Objetivo  : Detectar empleados activos sin usuario del sistema asociado.
-- TC        : Auditoría de integridad — todo empleado debería poder iniciar sesión.
-- Resultado : Si devuelve filas, hay empleados sin acceso — posible inconsistencia.
SELECT e.emp_number,
       e.emp_firstname,
       e.emp_lastname,
       e.employee_id,
       '❌ Sin usuario en el sistema' AS problema
FROM   hs_hr_employee e
LEFT   JOIN ohrm_user u ON e.emp_number = u.emp_number
WHERE  u.id IS NULL
  AND  e.termination_id IS NULL       -- Solo empleados activos (no terminados)
ORDER  BY e.emp_lastname;


-- QA-SQL-029
-- Objetivo  : Verificar que los usuarios del sistema tienen un empleado asociado.
-- TC        : Auditoría de integridad inversa a QA-SQL-028.
-- Resultado : Si devuelve filas, hay usuarios "huérfanos" sin perfil de empleado.
SELECT u.id,
       u.user_name,
       r.name AS rol,
       '⚠️  Usuario sin empleado asociado' AS observacion
FROM   ohrm_user u
JOIN   ohrm_user_role r ON u.user_role_id = r.id
LEFT   JOIN hs_hr_employee e ON u.emp_number = e.emp_number
WHERE  e.emp_number IS NULL
  AND  u.user_name  <> 'Admin';      -- El Admin puede no tener perfil de empleado


-- QA-SQL-030
-- Objetivo  : Detectar solicitudes de permiso con fecha de fin anterior a fecha de inicio.
-- TC        : TC-016 — si el sistema permite guardar esto, es un bug de validación.
-- Resultado : Si devuelve filas, el sistema no valida el rango de fechas en BD.
SELECT lr.id,
       e.emp_firstname,
       e.emp_lastname,
       lr.start_date,
       lr.end_date,
       DATEDIFF(lr.start_date, lr.end_date) AS dias_inversion,
       '❌ Fecha fin anterior a fecha inicio — dato inválido' AS problema
FROM   ohrm_leave_request lr
JOIN   hs_hr_employee e ON lr.emp_number = e.emp_number
WHERE  lr.end_date < lr.start_date;


-- QA-SQL-031
-- Objetivo  : Verificar que no existen empleados con nombre o apellido duplicado exacto.
-- TC        : TC-010 — un portafolio puede tener creado varias veces al mismo empleado.
-- Resultado : Lista los duplicados para limpiarlos antes de cerrar el ciclo.
SELECT emp_firstname,
       emp_lastname,
       COUNT(*)       AS cantidad,
       GROUP_CONCAT(employee_id SEPARATOR ', ') AS ids_empleado
FROM   hs_hr_employee
GROUP  BY emp_firstname, emp_lastname
HAVING COUNT(*) > 1
ORDER  BY cantidad DESC;


-- QA-SQL-032
-- Objetivo  : Verificar coherencia de saldos: días usados no deben superar asignados.
-- TC        : TC-021 — detectar inconsistencias de saldo en el módulo Leave.
-- Resultado : Si devuelve filas, hay un problema de cálculo en los saldos.
SELECT e.emp_firstname,
       e.emp_lastname,
       lt.name           AS tipo_permiso,
       le.no_of_days     AS asignados,
       le.days_used      AS usados,
       (le.days_used - le.no_of_days) AS exceso,
       '❌ Días usados superan el saldo asignado' AS problema
FROM   ohrm_leave_entitlement le
JOIN   hs_hr_employee  e  ON le.emp_number    = e.emp_number
JOIN   ohrm_leave_type lt ON le.leave_type_id = lt.id
WHERE  le.days_used > le.no_of_days;


-- QA-SQL-033
-- Objetivo  : Detectar usuarios con el mismo nombre de usuario (duplicados de login).
-- TC        : Auditoría de seguridad de autenticación.
-- Resultado : Si devuelve filas, hay usernames duplicados — bug de integridad.
SELECT user_name,
       COUNT(*) AS cantidad,
       '❌ Username duplicado — posible problema de registro' AS problema
FROM   ohrm_user
GROUP  BY user_name
HAVING COUNT(*) > 1;


-- ================================================================
-- §5  AUDITORÍA GENERAL (SNAPSHOT DEL SISTEMA)
-- ================================================================

-- QA-SQL-034
-- Objetivo  : Resumen ejecutivo del estado actual de la base de datos.
-- TC        : Todos — snapshot general antes y después del ciclo de pruebas.
-- Resultado : Una sola consulta que muestra el tamaño de las tablas principales.
SELECT 'Empleados totales'           AS tabla, COUNT(*) AS total FROM hs_hr_employee
UNION ALL
SELECT 'Usuarios activos',                      COUNT(*) FROM ohrm_user WHERE status = 1
UNION ALL
SELECT 'Roles del sistema',                     COUNT(*) FROM ohrm_user_role
UNION ALL
SELECT 'Solicitudes de permiso (Leave)',         COUNT(*) FROM ohrm_leave_request
UNION ALL
SELECT 'Tipos de permiso activos',              COUNT(*) FROM ohrm_leave_type WHERE is_active = 1
UNION ALL
SELECT 'Entitlements (saldos asignados)',        COUNT(*) FROM ohrm_leave_entitlement;


-- QA-SQL-035
-- Objetivo  : Ver las últimas acciones registradas en el log de auditoría.
-- TC        : Auditoría post-ejecución — confirmar qué acciones quedaron registradas.
-- Resultado : Historial de cambios ordenado del más reciente al más antiguo.
SELECT al.id,
       u.user_name     AS usuario,
       al.action,
       al.detail,
       al.created_at   AS fecha_hora
FROM   ohrm_audit_log al
LEFT   JOIN ohrm_user u ON al.user_id = u.id
ORDER  BY al.created_at DESC
LIMIT  20;


-- QA-SQL-036
-- Objetivo  : Verificar los módulos y permisos configurados para el rol ESS.
-- TC        : TC-022 — confirmar que el rol ESS no tiene acceso a módulo Admin.
-- Resultado : El módulo 'Admin' NO debe aparecer en los permisos de rol ESS.
SELECT ur.name            AS rol,
       s.module_name      AS modulo,
       s.action_string    AS accion,
       'admin'            AS buscar_esto
FROM   ohrm_user_role ur
JOIN   ohrm_data_group_permission dgp ON ur.id = dgp.user_role_id
JOIN   ohrm_screen                s   ON dgp.data_group_id = s.module_name
WHERE  ur.name = 'ESS'
  AND  s.module_name LIKE '%admin%';
-- Resultado esperado: 0 filas (ESS no tiene acceso a Admin)


-- QA-SQL-037
-- Objetivo  : Comparar el total de empleados antes y después de TC-014 (eliminación).
-- TC        : TC-014 (eliminar empleado) y TC-010 (crear empleado).
-- Instrucción: Ejecutar ANTES y DESPUÉS de la prueba y comparar el resultado.
SELECT COUNT(*) AS total_empleados_actuales,
       NOW()    AS momento_consulta
FROM   hs_hr_employee;


-- QA-SQL-038
-- Objetivo  : Resumen de bugs detectados y las tablas/campos afectados.
-- TC        : Todos los fallidos — documentación cruzada bugs ↔ BD.
-- Resultado : Vista consolidada de qué datos en BD corresponden a cada bug.
SELECT 'BUG-001' AS bug_id,
       'ohrm_user'  AS tabla_afectada,
       'user_name'  AS campo_afectado,
       'Error 504 al intentar reset de contraseña — tabla de tokens de recuperación posiblemente no escribe' AS descripcion,
       'TC-005'     AS test_case
UNION ALL
SELECT 'BUG-002',
       'hs_hr_employee',
       'emp_dob',
       'Campo emp_dob acepta fechas futuras sin restricción CHECK en la BD',
       'TC-013'
UNION ALL
SELECT 'BUG-003',
       'ohrm_leave_request',
       'N/A — no se pudo insertar ningún registro',
       'El formulario Apply Leave no renderiza — ningún registro creado en ohrm_leave_request',
       'TC-015, TC-016, TC-017';
-- ================================================================
-- FIN DEL ARCHIVO — queries.sql
-- Total de consultas: 38
-- ================================================================
