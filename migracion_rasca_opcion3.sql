SELECT 
    m.CURRENT_OWNER,
    mm.COD_BODEGA_FS,
    mm.COD_BODEGA_SCL,
    m.WAREHOUSE_LOCATION,
    mm.DESCRIPCION_SCL,
    m.DENOMINATION,
    SUM(m.QUANTITY) AS TOTAL_QUANTITY,
    SUM(m.DENOMINATION * m.QUANTITY) AS VALOR_TOTAL,
    oq.QUANTITY_SCL,
    SUM(oq.QUANTITY_SCL * m.DENOMINATION) AS VALOR_TOTAL_SCL,
    SUM((m.DENOMINATION * m.QUANTITY) - (oq.QUANTITY_SCL * m.DENOMINATION)) AS DIF_VALOR,
    SUM(m.QUANTITY) - SUM(oq.QUANTITY_SCL) AS DIF_QTY,
    CASE 
        WHEN SUM(m.QUANTITY) IS NULL OR oq.QUANTITY_SCL IS NULL OR (SUM(m.QUANTITY) - oq.QUANTITY_SCL) IS NULL THEN 0
        ELSE CASE 
                WHEN SUM(m.QUANTITY) = 0 THEN 1 
                ELSE 1 - ((SUM(m.QUANTITY) - oq.QUANTITY_SCL)*1.0/SUM(m.QUANTITY))
             END
    END as resultado,
    mm.COMENTARIO_LOGISTICA_DES_BODEGA
FROM migracion_all_batches_09102023 m
JOIN migracion_mapeo_06102023 mm ON m.WAREHOUSE_LOCATION = mm.DESCRIPCION_FS
LEFT JOIN (
    SELECT 
        T1.cod_bodega,
        T2.DENOMINATION,
        COUNT(*) as QUANTITY_SCL
    FROM OPENQUERY(RAOPRO_OLD, '
        SELECT 
            cod_bodega, 
            cod_articulo, 
            cod_estado, 
            tip_stock
        FROM 
            AL_MOVIMIENTOS_MIGRACION 
        WHERE 
            NOM_USUARORA = ''MIGRAPP''
        AND 
            TIP_STOCK IN (''2'', ''10'')
        AND 
            COD_ARTICULO IN (
                ''1672'', ''675'', ''668'', ''1119'', ''665'', ''669'', ''666'', ''670'', 
                ''674'', ''1264'', ''671'', ''1118'', ''1673'', ''1674'', ''1675'', 
                ''1676'', ''1677'', ''1678'', ''1679''
            )
        AND 
            cod_estado <> ''22''
    ') AS T1
    INNER JOIN migracion_catalago_vouchers_102023 AS T2 
    ON T1.cod_articulo = T2.COD_ARTICULO
    GROUP BY 
        T1.cod_bodega, 
        T2.DENOMINATION
) AS oq ON mm.COD_BODEGA_SCL = oq.cod_bodega AND m.DENOMINATION = oq.DENOMINATION
WHERE m.LOGICAL_STATUS_VALUE IN ('available', 'in transit', 'reserved')
AND m.current_owner IN ('Telefónica')
GROUP BY 
    m.CURRENT_OWNER,
    m.WAREHOUSE_LOCATION,
    mm.COD_BODEGA_FS,
    mm.COD_BODEGA_SCL,
    mm.DESCRIPCION_SCL,
    mm.COMENTARIO_LOGISTICA_DES_BODEGA,
    m.DENOMINATION,
    oq.QUANTITY_SCL;
