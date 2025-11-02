USE consultoria;

-- 1.	TR_ActualizarDisponibilidadConsultores: Actualiza la disponibilidad de consultores 

SELECT  
pc.ID_consultores,
c.nombres,
c.apellidos,
pc.rol,
100 - SUM(pc.dedication) AS disponibilidad 
FROM proyecto_consultores AS pc
INNER JOIN consultores AS c
ON pc.ID_consultores = c.ID 
GROUP BY 
pc.ID_consultores,
c.nombres,
c.apellidos,
pc.rol

DROP TABLE IF EXISTS disponibilidad_consultores;
CREATE TABLE disponibilidad_consultores(
ID_consultores INT,
nombres VARCHAR(50),
apellidos VARCHAR(100),
rol VARCHAR(50),
disponibilidad DECIMAL (5,2)
);

DROP PROCEDURE IF EXISTS Sp_ActualizarDisponibilidadConsultores;
DELIMITER //

CREATE PROCEDURE Sp_ActualizarDisponibilidadConsultores()
BEGIN
    -- Primero actualiza los que ya existen
    UPDATE disponibilidad_consultores dc
    JOIN (
        SELECT  
            pc.ID_consultores,
            100 - SUM(pc.dedication) AS nueva_disponibilidad
        FROM proyecto_consultores AS pc
        INNER JOIN consultores AS c
            ON pc.ID_consultores = c.ID 
        GROUP BY 
            pc.ID_consultores
    ) AS calc
    ON dc.ID_proyecto = calc.ID_proyecto
    SET dc.disponibilidad = calc.nueva_disponibilidad;

    -- Luego inserta los nuevos que aún no existen
    INSERT INTO disponibilidad_consultores (
        ID_consultores,
        nombres,
        apellidos,
        rol,
        disponibilidad
    )
    SELECT  
        pc.ID_consultores,
        c.nombres,
        c.apellidos,
        pc.rol,
        100 - SUM(pc.dedication) AS disponibilidad
    FROM proyecto_consultores AS pc
    INNER JOIN consultores AS c
        ON pc.ID_consultores = c.ID 

    WHERE NOT EXISTS (
        SELECT 1 
        FROM disponibilidad_consultores d
        WHERE d.ID_consultores = pc.ID_consultores
    )
    GROUP BY 
        pc.ID_consultores,
        c.nombres,
        c.apellidos,
        pc.rol;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS AsignarConsultorAProyecto;
DELIMITER //

CREATE PROCEDURE AsignarConsultorAProyecto(
    IN p_ID_proyecto INT,
    IN p_ID_consultores INT,
    IN p_rol VARCHAR(50),
    IN p_dedicacion DECIMAL(5,2),
    IN p_fecha_asignacion DATE
)
BEGIN
    -- Verificar existencia del proyecto
    IF NOT EXISTS (SELECT 1 FROM proyecto WHERE ID_proyecto = p_ID_proyecto) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El proyecto especificado no existe.';
    END IF;

    -- Verificar existencia del consultor
    IF NOT EXISTS (SELECT 1 FROM Consultores WHERE ID = p_ID_consultores) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El consultor especificado no existe.';
    END IF;

    -- Validar rol permitido
    IF p_rol NOT IN ('lider', 'analista', 'especialista', 'asesor') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El rol especificado no es válido.';
    END IF;

    -- Verificar que no exista ya la asignación
    IF EXISTS (
        SELECT 1 FROM proyecto_consultores
        WHERE ID_proyecto = p_ID_proyecto
          AND ID_consultores = p_ID_consultores
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Este consultor ya está asignado a este proyecto.';
    END IF;

    -- Insertar la asignación
    INSERT INTO proyecto_consultores (
        ID_proyecto,
        ID_consultores,
        rol,
        dedication,
        fecha_asignacion
    )
    VALUES (
        p_ID_proyecto,
        p_ID_consultores,
        p_rol,
        p_dedicacion,
        COALESCE(p_fecha_asignacion, CURRENT_DATE)
    );
END //

DELIMITER ;

DROP TRIGGER trg_AfterInsert_ProyectoConsultores;

DELIMITER //

CREATE TRIGGER trg_AfterInsert_ProyectoConsultores
AFTER INSERT ON proyecto_consultores
FOR EACH ROW
BEGIN
    -- Llamar al procedimiento que actualiza la disponibilidad del consultor
    CALL Sp_ActualizarDisponibilidadConsultores();
END //

DELIMITER ;

SELECT * FROM proyecto_consultores

-- 2.	TR_CalcularAvanceProyecto: Recalcula el avance de un proyecto según actividades completadas.
-- 3.	TR_VerificarCumplimientoHitos: Verifica el cumplimiento de hitos programados.
-- 4.	TR_ActualizarEstadisticasRentabilidad: Actualiza estadísticas de rentabilidad por proyecto.
