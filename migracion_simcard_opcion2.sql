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
FROM migracion_simcard_available_16102023 m1
LEFT JOIN migracion_mapeo_06102023 m2 ON m1.BODEGA = m2.DESCRIPCION_FS
LEFT JOIN (
    SELECT cod_bodega, SUM(QUANTITY_SCL) AS QUANTITY_SCL
    FROM OPENQUERY(RSCLPAN,
       'SELECT 
            cod_bodega, 
            COUNT(*) as QUANTITY_SCL
        FROM 
            AL_MOVIMIENTOS
        WHERE 
            NOM_USUARORA = ''MIGRAPP''
        AND 
            TIP_STOCK IN (''2'', ''10'')
        AND 
            COD_ARTICULO IN (''1894'',''1654'') 
        GROUP BY 
            cod_bodega'
    )
    GROUP BY cod_bodega
) AS oq ON m2.COD_BODEGA_SCL = oq.cod_bodega
WHERE m1.BODEGA IN ('Bodega: SIDRA SKY SOLUTIONS CHIRIQUI', 
                    'Bodega: SKY SOLUTIONS DARIEN', 
                    'MULTISERVICIOS C&C', 
                    'SKY SOLUTIONS CHORRERA', 
                    'SKY SOLUTIONS COLÓN', 
                    'SKY SOLUTIONS PANAMA', 
                    'SONIC BIRD', 
                    'Bodega: COMMERCIAL SIM, S.A.')
AND m1.PROPIETARIO IN ('Telefónica') 
AND m1.status_sim in ('Available', 'In Transit', 'Reserved', 'Blocked') 
GROUP BY m1.BODEGA, m2.DESCRIPCION_SCL, m2.COD_BODEGA_SCL, oq.QUANTITY_SCL
ORDER BY TOTAL_FULLSTACK DESC