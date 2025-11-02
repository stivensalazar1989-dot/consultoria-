USE consultoria;

-- 1.	EVT_VerificarEntregablesPendientes: Verifica entregables próximos a vencer.

DELIMITER //

CREATE EVENT IF NOT EXISTS EV_VerificarEntregablesPendientes
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO

BEGIN
    -- Crear tabla de alertas si no existe
    CREATE TABLE IF NOT EXISTS entregables_alerta (
        ID INT NOT NULL AUTO_INCREMENT,
        ID_entregable INT NOT NULL,
        ID_proyecto INT NOT NULL,
        nombre_proyecto VARCHAR(150),
        descripcion_entregable VARCHAR(200),
        consultor VARCHAR(100),
        estado_revision VARCHAR(50),
        fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (ID)
    );

    -- Eliminar alertas anteriores del mismo día
    DELETE FROM entregables_alerta
    WHERE DATE(fecha_registro) = CURDATE();

    -- Insertar los entregables que están pendientes o en revisión
    INSERT INTO entregables_alerta (
        ID_entregable,
        ID_proyecto,
        nombre_proyecto,
        descripcion_entregable,
        consultor,
        estado_revision
    )
    SELECT 
        e.ID_entregable,
        p.ID_proyecto,
        p.titulo AS nombre_proyecto,
        e.descripcion AS descripcion_entregable,
        CONCAT(c.nombres, ' ', c.apellidos) AS consultor,
        e.estado_revision
    FROM entregable AS e
    INNER JOIN proyecto AS p ON e.ID_proyecto = p.ID_proyecto
    INNER JOIN consultores AS c ON e.autor_principal = c.ID
    WHERE e.estado_revision IN ('pendiente', 'en revisión');
END //

DELIMITER ;


SELECT * FROM entregables_alerta;