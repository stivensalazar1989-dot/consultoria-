USE consultoria;

-- 1.	EVT_VerificarEntregablesPendientes: Verifica entregables próximos a vencer.

SELECT 
titulo,
descripcion,
colaboradores, 
fecha_entrega_planificada,
CURDATE() AS fecha_actual 

FROM entregable;
SELECT * FROM entregable;



-- 1.	V_ProyectosActivos: Muestra los proyectos activos con su estado y avance.

SELECT 
p.ID_proyecto,
p.titulo,
p.estado_actual,
IFNULL(f.id_fase,0) AS id_fase,
IFNULL(f.nombre,'sin iniciar') AS fase,
IFNULL(f.porcentaje_avance,0) AS porcentaje_avance
FROM proyecto AS p
LEFT JOIN fase_proyecto AS f
ON p.ID_proyecto = f.ID_proyecto

CREATE VIEW Vw_ProyectosActivos as
SELECT 
p.ID_proyecto,
p.titulo,
p.estado_actual,
IFNULL(f.id_fase,0) AS id_fase,
IFNULL(f.nombre,'sin iniciar') AS fase,
IFNULL(f.porcentaje_avance,0) AS porcentaje_avance
FROM proyecto AS p
LEFT JOIN fase_proyecto AS f
ON p.ID_proyecto = f.ID_proyecto

SELECT * FROM Vw_ProyectosActivos;


-- 2.	V_AsignacionConsultores: Detalla la asignación de consultores por proyecto.

SELECT 
p.ID_proyecto,
p.titulo AS nombre_proyecto,
pc.ID_consultores,
c.nombres,
c.apellidos,
pc.rol
FROM proyecto_consultores AS pc
INNER JOIN consultores AS c
ON pc.ID_consultores = c.ID 
INNER JOIN proyecto AS p 
ON pc.ID_proyecto = p.ID_proyecto

CREATE VIEW Vw_AsignacionConsultores AS 
SELECT 
p.ID_proyecto,
p.titulo AS nombre_proyecto,
pc.ID_consultores,
c.nombres,
c.apellidos,
pc.rol
FROM proyecto_consultores AS pc
INNER JOIN consultores AS c
ON pc.ID_consultores = c.ID 
INNER JOIN proyecto AS p 
ON pc.ID_proyecto = p.ID_proyecto

SELECT * FROM Vw_AsignacionConsultores;


-- 3.	V_HorasFacturablesMes: Resumen de horas facturables por consultor y mes.
SELECT 
pc.ID_consultores,
c.nombres,
c.apellidos,
pc.rol,
SUM(ht.horas_dedicadas) AS horas_trabajadas
FROM proyecto_consultores AS pc
INNER JOIN consultores AS c
ON pc.ID_consultores = c.ID 
INNER JOIN horas_trabajadas AS ht
ON c.ID = ht.ID_consultor
GROUP BY
 pc.ID_consultores,
c.nombres,
c.apellidos,
pc.rol

CREATE VIEW Vw_HorasFacturablesMes AS 
SELECT 
pc.ID_consultores,
c.nombres,
c.apellidos,
pc.rol,
SUM(ht.horas_dedicadas) AS horas_trabajadas
FROM proyecto_consultores AS pc
INNER JOIN consultores AS c
ON pc.ID_consultores = c.ID 
INNER JOIN horas_trabajadas AS ht
ON c.ID = ht.ID_consultor
GROUP BY
 pc.ID_consultores,
c.nombres,
c.apellidos,
pc.rol

SELECT * FROM Vw_HorasFacturablesMes;


-- 4.	V_EntregablesPendientes: Lista de entregables pendientes por proyecto y responsable.

CREATE VIEW Vw_EntregablesPendientes AS 
SELECT   
p.titulo AS nombre_proyecto,
p.objetivos AS objetivos_proyecto,
p.duracion_prevista,
e.ID_entregable,
e.ID_proyecto,
e.descripcion AS descripcion_entregable,
e.autor_principal AS consultor,
e.estado_revision AS estado_revision,
c.ID AS identificador_consultor,
c.nombres,
c.apellidos
FROM entregable e
INNER JOIN proyecto AS p  
 ON e.ID_proyecto = p.ID_proyecto
INNER JOIN  consultores AS c 
 ON e.autor_principal = c.ID
 

SELECT * FROM  Vw_EntregablesPendientes;


-- 5.	V_RentabilidadProyectos: Análisis de rentabilidad por proyecto y cliente.

CREATE VIEW Vw_RentabilidadProyectos AS 
SELECT 
p.titulo,
AVG(p.presupuesto_aprobado) AS presupuesto,
cl.razon_social,
IFNULL (SUM(ht.horas_dedicadas), 0)  AS horas_trabajadas, 
IFNULL (c.tarifa_horaria, 0) AS tarifa_horaria,
IFNULL (SUM(ht.horas_dedicadas * c.tarifa_horaria), 0) AS valor_facturado,
IFNULL  (p.presupuesto_aprobado - SUM(ht.horas_dedicadas * c.tarifa_horaria),0) AS utilidad ,
IFNULL ((p.presupuesto_aprobado - SUM(ht.horas_dedicadas * c.tarifa_horaria))/AVG(p.presupuesto_aprobado),0) AS rentabilidad 
FROM proyecto_consultores AS pc
INNER JOIN consultores AS c
ON pc.ID_consultores = c.ID 
INNER JOIN horas_trabajadas AS ht
ON c.ID = ht.ID_consultor
RIGHT  JOIN proyecto AS p
 ON ht.ID_proyecto = p.ID_proyecto 
INNER JOIN cliente AS cl
 ON p.ID_cliente = cl.ID
GROUP BY
p.titulo,
cl.razon_social

SELECT * FROM Vw_RentabilidadProyectos;



