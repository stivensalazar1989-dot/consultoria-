USE consultoria;

DROP FUNCTION IF EXISTS FN_CalcularDisponibilidadConsultor;
DELIMITER //

-- 1.	FN_CalcularDisponibilidadConsultor: Calcula la disponibilidad de un consultor para un periodo.
CREATE FUNCTION FN_CalcularDisponibilidadConsultor(p_ID_consultor INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_disponibilidad DECIMAL(5,2);

    -- Calcular la disponibilidad del consultor
    SELECT 100 - IFNULL(SUM(pc.dedication), 0)
    INTO v_disponibilidad
    FROM proyecto_consultores AS pc
    INNER JOIN consultores AS c
        ON pc.ID_consultores = c.ID
    WHERE pc.ID_consultores = p_ID_consultor;

    -- Asegurar que no devuelva valores negativos o mayores a 100
    IF v_disponibilidad < 0 THEN
        SET v_disponibilidad = 0;
    ELSEIF v_disponibilidad > 100 THEN
        SET v_disponibilidad = 100;
    END IF;

    RETURN v_disponibilidad;
END //

DELIMITER ;


SELECT FN_CalcularDisponibilidadConsultor(3) AS Disponibilidad;

-- 3.FN_CalcularValorProyecto: Calcula el valor total de un proyecto según servicios y horas.

DROP FUNCTION IF EXISTS FN_CalcularValorProyecto;
DELIMITER //

CREATE FUNCTION FN_CalcularValorProyecto(p_ID_proyecto INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_valor_facturado DECIMAL(12,2);

    
    SELECT 
        IFNULL(SUM(ht.horas_dedicadas * c.tarifa_horaria), 0)
    INTO v_valor_facturado
    FROM horas_trabajadas AS ht
    INNER JOIN consultores AS c 
        ON ht.ID_consultor = c.ID
    INNER JOIN proyecto AS p
        ON ht.ID_proyecto = p.ID_proyecto
    WHERE p.ID_proyecto = p_ID_proyecto;

    RETURN v_valor_facturado;
END //

DELIMITER ;

SELECT FN_CalcularValorProyecto(3) AS ValorTotalProyecto;



