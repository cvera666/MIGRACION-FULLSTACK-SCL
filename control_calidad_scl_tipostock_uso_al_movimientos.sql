SELECT 
    T1.cod_bodega, 
    T2.DENOMINATION,
    COUNT(*) as CANTIDAD_SCL,
    T1.TIP_STOCK,
    T1.COD_USO
FROM OPENQUERY(RSCLPAN, '
    SELECT 
        cod_bodega, 
        cod_articulo, 
        cod_estado, 
        tip_stock,
        COD_USO
    FROM 
        AL_MOVIMIENTOS
    WHERE 
        NOM_USUARORA = ''MIGRAPP''
    AND
        COD_ARTICULO IN (
            ''1672'', ''675'', ''668'', ''1119'', ''665'', ''669'', ''666'', ''670'', 
            ''674'', ''1264'', ''671'', ''1118'', ''1673'', ''1674'', ''1675'', 
            ''1676'', ''1677'', ''1678'', ''1679''
        )
    AND 
        cod_estado <> ''22''
    AND
        TIP_STOCK NOT IN (''2'', ''10'')
    AND
        COD_USO <> ''3''
')
AS T1
INNER JOIN migracion_catalago_vouchers_102023 AS T2 
ON T1.cod_articulo = T2.COD_ARTICULO
GROUP BY 
    T1.cod_bodega, 
    T2.DENOMINATION,
    T1.TIP_STOCK,
    T1.COD_USO;