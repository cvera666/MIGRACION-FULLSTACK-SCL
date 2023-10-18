SELECT 
    T1.cod_bodega, 
    COUNT(*) as QUANTITY_SCL,
    SUM(CASE WHEN T1.cod_estado = '1' THEN 1 ELSE 0 END) AS Total_Available,
    SUM(CASE WHEN T1.cod_estado = '4' THEN 1 ELSE 0 END) AS Total_Reserved,
    SUM(CASE WHEN T1.cod_estado = '6' THEN 1 ELSE 0 END) AS Total_InTransit
FROM OPENQUERY(RSCLPAN, '
    SELECT 
        cod_bodega, 
        cod_articulo, 
        cod_estado, 
        tip_stock
    FROM 
        AL_movimientos
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
')
AS T1
INNER JOIN migracion_catalago_vouchers_102023 AS T2 
ON T1.cod_articulo = T2.COD_ARTICULO
GROUP BY 
    T1.cod_bodega;
