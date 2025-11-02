USE consultoria;


-- 1.Crea una propuesta comercial para un cliente potencial.

INSERT INTO propuestas (fecha_presentacion, ID_cliente, titulo, 
inversion_requerida, condiciones_comerciales, validez_oferta, estado)
VALUES ('2025-10-30', 3, 'nueva_propuesta', 30000, 'pago unico por adelantado', 2025-12-12, 'en evaluacion')

DROP PROCEDURE IF EXISTS CrearPropuestaComercial
DELIMITER //

CREATE PROCEDURE CrearPropuestaComercial (
    IN p_fecha_presentacion DATE,
    IN p_ID_cliente INT,
    IN p_titulo VARCHAR(150),
    IN p_inversion_requerida DECIMAL(10,2),
    IN p_condiciones_comerciales TEXT,
    IN p_validez_oferta DATE,
    IN p_estado VARCHAR(50)
)
BEGIN
    INSERT INTO propuestas (
        fecha_presentacion, 
        ID_cliente, 
        titulo, 
        inversion_requerida, 
        condiciones_comerciales, 
        validez_oferta, 
        estado
    )
    VALUES (
        p_fecha_presentacion,
        p_ID_cliente,
        p_titulo,
        p_inversion_requerida,
        p_condiciones_comerciales,
        p_validez_oferta,
        p_estado
    );
END //

DELIMITER ;


CALL CrearPropuestaComercial(
    '2025-10-30',
    1,
    'Big Data & BI',
    100000.00,
    'pago único por adelantado',
    '2025-12-12',
    'en evaluacion'
);


-- 2.	IniciarProyectoConsultoria

INSERT INTO proyecto (
    titulo,
    ID_cliente,
    ID_servicio,
    alcance,
    objetivos,
    fecha_inicio,
    duracion_prevista,
    presupuesto_aprobado,
    estado_actual,
    nivel_confidencialidad
)
VALUES (
    'Implementación del Sistema de Gestión Documental',
    3,              -- ID_cliente existente en la tabla Cliente
    2,              -- ID_servicio existente en la tabla servicio
    'Automatización de procesos documentales',
    'Optimizar la gestión y acceso a documentos internos',
    '2025-11-01',   -- fecha de inicio
    90,             -- duración prevista en días
    45000.00,       -- presupuesto aprobado
    'planificado',  -- valor permitido por CHECK
    'medio'         -- valor permitido por CHECK
);

DROP PROCEDURE IF EXISTS IniciarProyectoConsultoria

DELIMITER //

CREATE PROCEDURE IniciarProyectoConsultoria (
 IN p_titulo VARCHAR(150),
 IN p_ID_cliente INT,
 IN p_ID_servicio INT,
 IN p_alcance VARCHAR(50),
 IN p_objetivos VARCHAR(50),
 IN p_fecha_inicio DATE,
 IN p_duracion_prevista INT,
 IN p_presupuesto_aprobado DECIMAL(10,2),
 IN p_estado_actual VARCHAR(50),
 IN p_nivel_confidencialidad VARCHAR(50)
)
BEGIN
INSERT INTO proyecto (
    titulo,
    ID_cliente,
    ID_servicio,
    alcance,
    objetivos,
    fecha_inicio,
    duracion_prevista,
    presupuesto_aprobado,
    estado_actual,
    nivel_confidencialidad
)
VALUES (
    p_titulo,
    p_ID_cliente,
    p_ID_servicio,
    p_alcance,
    p_objetivos,
    p_fecha_inicio,
    p_duracion_prevista,
    p_presupuesto_aprobado,
    p_estado_actual,
    p_nivel_confidencialidad
);
END //

DELIMITER ;

CALL IniciarProyectoConsultoria(
    'Implementación del Sistema de Data Gobernance',
    2,              -- ID_cliente existente en la tabla Cliente
    1,              -- ID_servicio existente en la tabla servicio
    'Automatización de procesos documentales',
    'Optimizar la gestión y acceso a documentos internos',
    '2026-01-01',   -- fecha de inicio
    180,             -- duración prevista en días
    150000.00,       -- presupuesto aprobado
    'planificado',  -- valor permitido por CHECK
    'medio'         -- valor permitido por CHECK
);

-- 3.	RegistrarHorasTrabajadas: 
DROP PROCEDURE IF EXISTS RegistrarHorasTrabajadas
DELIMITER //

CREATE PROCEDURE RegistrarHorasTrabajadas (
    IN p_ID_consultor INT,
    IN p_ID_proyecto INT,
    IN p_ID_fase INT,
    IN p_fecha DATE,
    IN p_actividad_realizada VARCHAR(200),
    IN p_horas_dedicadas DECIMAL(6,2),
    IN p_lugar_trabajo VARCHAR(50),
    IN p_descripcion_detallada VARCHAR(200),
    IN p_resultados_obtenidos VARCHAR(200),
    IN p_dificultades VARCHAR(150),
    IN p_horas_facturables DECIMAL(6,2)
)
BEGIN
    -- Verificar existencia del consultor
    IF NOT EXISTS (SELECT 1 FROM Consultores WHERE ID = p_ID_consultor) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El consultor especificado no existe.';
    END IF;

    -- Verificar existencia del proyecto
    IF NOT EXISTS (SELECT 1 FROM proyecto WHERE ID_proyecto = p_ID_proyecto) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El proyecto especificado no existe.';
    END IF;

    -- Verificar existencia de la fase
    IF NOT EXISTS (SELECT 1 FROM fase_proyecto WHERE id_fase = p_ID_fase) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: La fase especificada no existe.';
    END IF;

    -- Insertar registro de horas
    INSERT INTO Horas_trabajadas (
        ID_consultor, 
        ID_proyecto, 
        ID_fase, 
        fecha, 
        actividad_realizada, 
        horas_dedicadas, 
        lugar_trabajo, 
        descripcion_detallada, 
        resultados_obtenidos, 
        dificultades, 
        horas_facturables
    ) 
    VALUES (
        p_ID_consultor,
        p_ID_proyecto,
        p_ID_fase,
        COALESCE(p_fecha, CURRENT_DATE),
        p_actividad_realizada,
        p_horas_dedicadas,
        p_lugar_trabajo,
        p_descripcion_detallada,
        p_resultados_obtenidos,
        p_dificultades,
        p_horas_facturables
    );

END //

DELIMITER ;


CALL RegistrarHorasTrabajadas(
    2,              -- ID_consultor existente
    3,              -- ID_proyecto existente
    4,              -- ID_fase existente
    '2025-10-30',   -- Fecha
    'Análisis de requerimientos del cliente',
    6.5,            -- Horas dedicadas
    'cliente',      -- Lugar de trabajo
    'Revisión de documentación y entrevistas con el cliente',
    'Identificación de requerimientos críticos',
    'Demora en la entrega de información',
    6.5             -- Horas facturables
);

-- hice una insercion de datos para los views
CALL RegistrarHorasTrabajadas(
    1,              -- ID_consultor (existente)
    3,              -- ID_proyecto (existente)
    4,              -- ID_fase (existente)
    '2025-10-29',   -- Fecha
    'Desarrollo del módulo de autenticación',
    8.00,           -- Horas dedicadas
    'oficina',      -- Lugar de trabajo
    'Implementación de login seguro con validaciones y hashing de contraseñas',
    'Módulo funcional y probado en entorno local',
    'Problemas iniciales con la librería de autenticación',
    8.00            -- Horas facturables
);


CALL RegistrarHorasTrabajadas(
    2,              -- ID_consultor
    3,              -- ID_proyecto
    4,              -- ID_fase
    '2025-10-30',   -- Fecha
    'Reunión de seguimiento semanal con el cliente',
    2.50,           -- Horas dedicadas
    'cliente',      -- Lugar de trabajo
    'Presentación de avances y discusión sobre cambios en requerimientos',
    'Cliente aprobó el avance y solicitó ajustes menores',
    'Dificultades para coordinar horarios con el cliente',
    2.50            -- Horas facturables
);

CALL RegistrarHorasTrabajadas(
    3,              -- ID_consultor
    3,              -- ID_proyecto
    4,              -- ID_fase
    '2025-10-31',   -- Fecha
    'Ejecución de pruebas de integración del sistema',
    5.75,           -- Horas dedicadas
    'remoto',       -- Lugar de trabajo
    'Validación de interoperabilidad entre módulos de gestión documental y usuarios',
    'Se detectaron errores menores en sincronización de datos',
    'Inestabilidad temporal del entorno de pruebas',
    5.50            -- Horas facturables
);

-- hice una insercion de datos para los views

-- 4.	GestionarEntregables: Gestiona el ciclo de vida de entregables por proyecto.



SELECT 
p.titulo AS nombre_proyecto,
p.fecha_inicio,
IFNULL(f.nombre,'sin fase') AS nombre_fase,
IFNULL(f.descripcion,'sin descripcion') AS descripcion_fase,
f.fecha_inicio_planificada,
f.fecha_inicio_real,
f.fecha_fin_planificada,
f.fecha_fin_real,
IFNULL(e.titulo,'sin titulo') AS  titulo_entregable,
IFNULL(e.descripcion,'sin descripcion') AS  descripcion_entregable,
e.fecha_entrega_planificada,
e.fecha_entrega_real
FROM proyecto AS p
LEFT JOIN fase_proyecto AS f
ON p.ID_proyecto = f.ID_proyecto 
LEFT JOIN entregable AS e 
ON f.id_fase = e.ID_fases


DROP PROCEDURE IF EXISTS GestionarEntregables

DELIMITER //

CREATE PROCEDURE GestionarEntregables(
)
BEGIN
SELECT 
	p.titulo AS nombre_proyecto,
	p.fecha_inicio,
	IFNULL(f.nombre,'sin fase') AS nombre_fase,
	IFNULL(f.descripcion,'sin descripcion') AS descripcion_fase,
	f.fecha_inicio_planificada,
	f.fecha_inicio_real,
	f.fecha_fin_planificada,
	f.fecha_fin_real,
	IFNULL(e.titulo,'sin titulo') AS  titulo_entregable,
	IFNULL(e.descripcion,'sin descripcion') AS  descripcion_entregable,
	e.fecha_entrega_planificada,
	e.fecha_entrega_real
FROM proyecto AS p
LEFT JOIN fase_proyecto AS f
	ON p.ID_proyecto = f.ID_proyecto 
LEFT JOIN entregable AS e 
	ON f.id_fase = e.ID_fases;
END //
DELIMITER ;

CALL GestionarEntregables();


-- 5.	GenerarFacturacionProyecto: Genera la facturación para un proyecto según avance

SELECT
p.ID_proyecto,
p.titulo,
p.ID_cliente,
c.ID AS id_cliente,
c.razon_social AS nombre_cliente,
cl.descripcion AS cliente_tipo,
f.ID_factura,
f.ID_factura,
f.fecha,
f.periodo_facturado,
f.condiciones_pago,
f.estado,
fl.cantidad,
fl.subtotal,
SUM(fl.cantidad)  AS cantidad_total,
SUM(fl.subtotal) AS total_factura
FROM proyecto AS p 
INNER JOIN cliente AS c
ON p.ID_cliente = c.ID
INNER JOIN factura AS f 
ON c.ID = f.ID_cliente AND p.ID_proyecto = f.ID_proyecto
INNER JOIN factura_linea AS fl
ON f.ID_factura = fl.ID_factura 
LEFT JOIN cliente_tipo AS cl
ON c.ID = cl.ID
GROUP BY 
p.ID_proyecto,
p.titulo,
p.ID_cliente,
c.ID,
c.razon_social,
cl.descripcion ,
f.ID_factura,
f.ID_factura,
f.fecha,
f.periodo_facturado,
f.condiciones_pago,
f.estado,
fl.cantidad,
fl.subtotal

DROP PROCEDURE IF EXISTS GenerarFacturacionProyecto

DELIMITER //

CREATE PROCEDURE GenerarFacturacionProyecto(
)
BEGIN
 SELECT
 p.ID_proyecto,
 p.titulo,
 p.ID_cliente,
 c.ID AS id_cliente,
 c.razon_social AS nombre_cliente,
 cl.descripcion AS cliente_tipo,
 f.ID_factura,
 f.ID_factura,
 f.fecha,
 f.periodo_facturado,
 f.condiciones_pago,
 f.estado,
 fl.cantidad,
 fl.subtotal,
 SUM(fl.cantidad)  AS cantidad_total,
 SUM(fl.subtotal) AS total_factura
FROM proyecto AS p 
INNER JOIN cliente AS c
 ON p.ID_cliente = c.ID
INNER JOIN factura AS f 
 ON c.ID = f.ID_cliente AND p.ID_proyecto = f.ID_proyecto
INNER JOIN factura_linea AS fl
 ON f.ID_factura = fl.ID_factura 
LEFT JOIN cliente_tipo AS cl
 ON c.ID = cl.ID
GROUP BY 
p.ID_proyecto,
p.titulo,
p.ID_cliente,
c.ID,
c.razon_social,
cl.descripcion ,
f.ID_factura,
f.ID_factura,
f.fecha,
f.periodo_facturado,
f.condiciones_pago,
f.estado,
fl.cantidad,
fl.subtotal;
END //

DELIMITER ;

CALL GenerarFacturacionProyecto();




