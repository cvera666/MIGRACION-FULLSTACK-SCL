SELECT 
    m1.BODEGA, 
    m2.DESCRIPCION_SCL,
    m2.COD_BODEGA_SCL,
    COUNT(m1.ICCID) as TOTAL_FULLSTACK,
    oq.QUANTITY_SCL,
    COUNT(m1.ICCID) - ISNULL(oq.QUANTITY_SCL, 0) AS DIF_QTY,
    CASE 
        WHEN COUNT(m1.ICCID) = 0 THEN 0
        ELSE (ISNULL(oq.QUANTITY_SCL, 0) * 100.0) / COUNT(m1.ICCID)
    END AS PORCENTAJE_DIF
FROM migracion_simcard_available_09102023 m1
LEFT JOIN migracion_mapeo_06102023 m2 ON m1.BODEGA = m2.DESCRIPCION_FS
LEFT JOIN (
    SELECT cod_bodega, QUANTITY_SCL
    FROM OPENQUERY(RAOPRO_OLD,
       'SELECT 
            cod_bodega, 
            cod_articulo, 
            cod_estado, 
            tip_stock,
            COUNT(*) as QUANTITY_SCL
        FROM 
            AL_MOVIMIENTOS_MIGRACION 
        WHERE 
            NOM_USUARORA = ''MIGRAPP''
        AND 
            TIP_STOCK IN (''2'', ''10'')
        AND 
            COD_ARTICULO IN (''1906'', ''1654'')
        GROUP BY 
            cod_bodega, 
            cod_articulo, 
            cod_estado, 
            tip_stock
        '
    )
) AS oq ON m2.COD_BODEGA_SCL = oq.cod_bodega
WHERE m1.BODEGA IN ('Bodega: SIDRA SKY SOLUTIONS CHIRIQUI', 
                    'Bodega: SKY SOLUTIONS DARIEN', 
                    'MULTISERVICIOS C&C', 
                    'SKY SOLUTIONS CHORRERA', 
                    'SKY SOLUTIONS COLÓN', 
                    'SKY SOLUTIONS PANAMA', 
                    'SONIC BIRD', 
                    'Bodega: COMMERCIAL SIM, S.A.')
GROUP BY m1.BODEGA, m2.DESCRIPCION_SCL, m2.COD_BODEGA_SCL, oq.QUANTITY_SCL
ORDER BY TOTAL_FULLSTACK DESC;
