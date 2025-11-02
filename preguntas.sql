USE consultoria;
SELECT * FROM cliente_tipo;
SELECT * FROM especialidad;
SELECT * FROM sector_actividad;
SELECT * FROM idioma;
SELECT * FROM servicio_categoria;
SELECT * FROM entregable_tipo;
SELECT * FROM conocimiento_tipo;
SELECT * FROM consultores;
SELECT * FROM proyecto;
SELECT * FROM proyecto_consultores;
SELECT * FROM consultores_especialidad;
SELECT * FROM consultores_idioma;
SELECT * FROM servicio;
SELECT * FROM cliente;
SELECT * FROM fase_proyecto;
SELECT * FROM propuestas;
SELECT * FROM propuesta_servicio;
SELECT * FROM entregable;
SELECT * FROM horas_trabajadas;
SELECT * FROM factura;
SELECT * FROM factura_linea;
SELECT * FROM conocimiento;





-- 1.¿cuales son todas las actividades de un proyecto especifico?
SELECT 
   p.titulo AS Proyecto,
    f.nombre AS Fase,
    c.nombres AS Consultor,
    c.apellidos AS Apellidos,
    h.fecha AS Fecha_Actividad,
    h.actividad_realizada AS Actividad,
    h.descripcion_detallada AS Descripcion,
    h.horas_dedicadas AS Horas,
    h.lugar_trabajo AS Lugar,
    h.resultados_obtenidos AS Resultados,
    h.dificultades AS Dificultades
    FROM Horas_trabajadas h
INNER JOIN proyecto p 
ON h.ID_proyecto = p.ID_proyecto
INNER JOIN fase_proyecto f 
ON h.ID_fase = f.id_fase
INNER JOIN Consultores c 
ON h.ID_consultor = c.ID
WHERE p.ID_proyecto
ORDER BY h.fecha;

-- 2. ¿que proyectos tienen presupuesto menor a 50000?
SELECT 
    ID_proyecto,
    titulo,
    presupuesto_aprobado,
    estado_actual,
    nivel_confidencialidad
FROM proyecto
WHERE presupuesto_aprobado < 50000;


-- 3. ¿cuales son los consultorres de especialidad finanzas con disponibilidad completa?

SELECT 
    c.ID,
    c.nombres,
    c.apellidos,
    e.nombre_especialidad,
    c.disponibilidad
FROM Consultores c
INNER JOIN Consultores_especialidad ce ON c.ID = ce.ID
INNER JOIN Especialidad e ON ce.especialidad_id = e.ID
WHERE e.nombre_especialidad = 'finanzas'
  AND c.disponibilidad = 'disponible';
  
-- 4.¿que proyectos estan en fase final o de planificacion?

SELECT 
    p.ID_proyecto,
    p.titulo,
    p.estado_actual,
    f.nombre AS fase,
    f.porcentaje_avance
FROM proyecto p
INNER  JOIN fase_proyecto f ON p.ID_proyecto = f.ID_proyecto
WHERE p.estado_actual IN ('fase final', 'planificado');

-- 5.cuales son las propuestas comerciales presentadas en el primer trimestre de 2024?

SELECT 
    ID_propuestas,
    titulo,
    ID_cliente,
    fecha_presentacion,
    inversion_requerida,
    estado
FROM propuestas
WHERE fecha_presentacion BETWEEN '2024-01-01' AND '2024-03-31';

-- 6.¿que entregables son de tipo informe, presentacion o modelo?

SELECT 
    e.ID_entregable,
    e.titulo,
    t.descripcion AS tipo_entregable,
    e.fecha_entrega_real,
    e.estado_revision
FROM Entregable e
INNER  JOIN entregable_tipo t ON e.tipo_id = t.ID_tipo
WHERE t.descripcion IN ('informe', 'presentacion', 'modelo');

-- 7.cuales son los conocimientos coon descripciones que contienen "estrategia digital" o "transformacion" ?

SELECT 
    ID_conocimiento,
    titulo,
    industria_relacionada,
    descripcion,
    fecha_creacion,
    nivel_acceso,
    potencial_reutilizacion
FROM conocimiento
WHERE descripcion LIKE '%estrategia%'
   OR descripcion LIKE '%digital%';

-- 8. ¿que fases tienen fecha planificada de finalizacion pasada sin fecha real de finalizacion?

SELECT 
    f.id_fase,
    f.nombre,
    f.descripcion,
    f.fecha_fin_planificada,
    f.fecha_fin_real,
    p.titulo AS proyecto
FROM fase_proyecto f
INNER  JOIN proyecto p ON f.ID_proyecto = p.ID_proyecto
WHERE f.fecha_fin_planificada < CURRENT_DATE
  AND (f.fecha_fin_real IS NULL OR f.fecha_fin_real = '0000-00-00');
  
-- 9.¿cuales son los consultores ordenados por nivel descendente y tarifa horaria descendente?

SELECT 
    ID,
    nombres,
    apellidos,
    nivel_firma,
    tarifa_horaria,
    disponibilidad
FROM Consultores
ORDER BY 
    FIELD(nivel_firma, 'socio', 'gerente', 'senior', 'junior'),
    tarifa_horaria DESC;

-- 10.¿cuales son las horas facturadas por consultor y proyecto, con su importe facturable?

SELECT 
    c.ID AS ID_consultor,
    CONCAT(c.nombres, ' ', c.apellidos) AS consultor,
    p.ID_proyecto,
    p.titulo AS proyecto,
    SUM(h.horas_facturables) AS total_horas_facturadas,
    SUM(h.horas_facturables * c.tarifa_horaria) AS importe_facturable
FROM Horas_trabajadas h
INNER JOIN Consultores c ON h.ID_consultor = c.ID
INNER  JOIN proyecto p ON h.ID_proyecto = p.ID_proyecto
GROUP BY c.ID, p.ID_proyecto
ORDER BY importe_facturable DESC;






