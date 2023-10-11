
CREATE TABLE #TempTable1 (
    CURRENT_OWNER NVARCHAR(100),
    COD_BODEGA_FS NVARCHAR(50),
    COD_BODEGA_SCL NVARCHAR(50),
    WAREHOUSE_LOCATION NVARCHAR(100),
    DESCRIPCION_SCL NVARCHAR(100),
    DENOMINATION INT,
    TOTAL_QUANTITY INT
);

INSERT INTO #TempTable1
SELECT 
    m.CURRENT_OWNER,
    mm.COD_BODEGA_FS,
    mm.COD_BODEGA_SCL,
    m.WAREHOUSE_LOCATION,
    mm.DESCRIPCION_SCL,
    m.DENOMINATION,
    SUM(m.QUANTITY) AS TOTAL_QUANTITY
FROM migracion_all_batches_09102023 m
JOIN migracion_mapeo_06102023 mm ON m.WAREHOUSE_LOCATION = mm.DESCRIPCION_FS
WHERE m.LOGICAL_STATUS_VALUE IN ('available', 'in transit', 'reserved')
AND m.current_owner IN ('Telefónica')
GROUP BY 
    m.CURRENT_OWNER,
    m.WAREHOUSE_LOCATION,
    mm.COD_BODEGA_FS,
    mm.COD_BODEGA_SCL,
    mm.DESCRIPCION_SCL,
    m.DENOMINATION;


CREATE TABLE #TempTable2 (
    cod_bodega NVARCHAR(50),
    DENOMINATION INT,
    QUANTITY_SCL INT
);

INSERT INTO #TempTable2
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
')
AS T1
INNER JOIN migracion_catalago_vouchers_102023 AS T2 
ON T1.cod_articulo = T2.COD_ARTICULO
GROUP BY 
    T1.cod_bodega, 
    T2.DENOMINATION;


SELECT 
    t1.*,
    t2.QUANTITY_SCL,
    t1.TOTAL_QUANTITY - ISNULL(t2.QUANTITY_SCL, 0) AS DIF_QTY 
INTO migracion_resultado_rasca_10102023
FROM #TempTable1 t1
LEFT JOIN #TempTable2 t2 ON t1.COD_BODEGA_SCL = t2.cod_bodega AND t1.DENOMINATION = t2.DENOMINATION;


DROP TABLE #TempTable1;
DROP TABLE #TempTable2;


