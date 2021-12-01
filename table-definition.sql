-- ==================================================================================
-- Description: Obtiene las columnas de la tabla separadas por comma
-- ==================================================================================
SELECT TABLE_SCHEMA, TABLE_NAME
    , STUFF(
        (
        SELECT ', ' + C.COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS As C
        WHERE C.TABLE_SCHEMA = T.TABLE_SCHEMA
            AND C.TABLE_NAME = T.TABLE_NAME
        ORDER BY C.ORDINAL_POSITION
        FOR XML PATH('')
        ), 1, 2, '') AS Columns
FROM INFORMATION_SCHEMA.TABLES AS T
WHERE TABLE_NAME = 'table_name'

-- ==================================================================================
-- Ejecuta la sentencia sql en cada una de las bases de datos en el servidor
-- ==================================================================================
DECLARE @command varchar(1000) 
SELECT @command = 'USE ? SELECT * FROM sys.tables WHERE name =''able_name'''
EXEC sp_MSforeachdb @command

-- ==================================================================================
--Busca una tabla con cierta columna dentro de todas las bases del servidor
-- ==================================================================================
DECLARE @command varchar(1000) 
SELECT @command = 'USE [?] 
SELECT * FROM(
Select CONVERT(VARCHAR(22),DB_NAME()) [database_name], 
CONVERT(VARCHAR(3),TABLE_SCHEMA) [table_schema], 
CONVERT(VARCHAR(24),TABLE_NAME) [table_name],
Stuff(
        (
        Select '', '' + C.COLUMN_NAME
        From INFORMATION_SCHEMA.COLUMNS As C
        Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
            And C.TABLE_NAME = T.TABLE_NAME
        Order By C.ORDINAL_POSITION
        For Xml Path('''')
        ), 1, 2, '''') [columns]
From INFORMATION_SCHEMA.TABLES As T
Where TABLE_NAME = ''tRiesgoConsecuencia''
) t WHERE columns like ''%idConsecuencia%'''
EXEC sp_MSforeachdb @command