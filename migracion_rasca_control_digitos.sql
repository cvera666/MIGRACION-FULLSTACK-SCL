SELECT count(*)
FROM OPENQUERY(RAOPRO_OLD, '
    SELECT * 
    FROM AL_MOVIMIENTOS_MIGRACION  
    WHERE 
        LENGTH(num_serie) <> 9
        AND NOM_USUARORA = ''MIGRAPP''
        AND TIP_STOCK IN (''2'', ''10'')
        AND COD_ARTICULO IN (
            ''1672'', ''675'', ''668'', ''1119'', ''665'', ''669'', ''666'', ''670'', 
            ''674'', ''1264'', ''671'', ''1118'', ''1672'', ''1673'', ''1674'', ''1675'', 
            ''1676'', ''1677'', ''1678'', ''1679''
        )
        AND 
        cod_estado <> ''22''')