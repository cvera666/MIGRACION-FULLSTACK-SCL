SELECT 
    m.ICCID,
    o.NUM_SERIE,
    o.COD_ARTICULO,
    o.cod_bodega
FROM 
    migracion_simcard_available_16102023 m
JOIN 
(
    SELECT 
        NUM_SERIE, 
        COD_ARTICULO, 
        cod_bodega 
    FROM OPENQUERY(
        RSCLPAN,
        'SELECT NUM_SERIE, COD_ARTICULO, cod_bodega 
         FROM AL_MOVIMIENTOS 
         WHERE COD_ARTICULO <> 1894
		 AND NOM_USUARORA = ''MIGRAPP''
         AND cod_bodega NOT IN (2164, 2208, 2207, 37, 34, 55, 2304, 2209)'
    )
) AS o
ON 
    m.ICCID COLLATE SQL_Latin1_General_CP1_CI_AS = o.NUM_SERIE COLLATE SQL_Latin1_General_CP1_CI_AS