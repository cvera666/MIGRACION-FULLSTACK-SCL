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