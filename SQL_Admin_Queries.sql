--find all the objects that are referencing a table/view/sp
SELECT
referencing_schema_name = SCHEMA_NAME(o.SCHEMA_ID),
referencing_object_name = o.name,
referencing_object_type_desc = o.type_desc,
referenced_schema_name,
referenced_object_name = referenced_entity_name,
referenced_object_type_desc = o1.type_desc,
referenced_server_name, referenced_database_name
--,sed.* -- Uncomment for all the columns
FROM
sys.sql_expression_dependencies sed
INNER JOIN
sys.objects o ON sed.referencing_id = o.[object_id]
LEFT OUTER JOIN
sys.objects o1 ON sed.referenced_id = o1.[object_id]
WHERE
referenced_entity_name like '%usp_insert_record%'


--find all jobs calling a specific stored procedure
SELECT j.name 
  FROM msdb.dbo.sysjobs AS j
  WHERE EXISTS 
  (
    SELECT 1 FROM msdb.dbo.sysjobsteps AS s
      WHERE s.job_id = j.job_id
      AND s.command LIKE '%usp_Daily_Import%'
  );

--finding all the objects which are used in a view
SELECT
referencing_schema_name = SCHEMA_NAME(o.SCHEMA_ID),
referencing_object_name = o.name,
referencing_object_type_desc = o.type_desc,
referenced_schema_name,
referenced_object_name = referenced_entity_name,
referenced_object_type_desc = o1.type_desc,
referenced_server_name, referenced_database_name
--,sed.* -- Uncomment for all the columns
FROM
sys.sql_expression_dependencies sed
INNER JOIN
sys.objects o ON sed.referencing_id = o.[object_id]
LEFT OUTER JOIN
sys.objects o1 ON sed.referenced_id = o1.[object_id]
WHERE
o.name like 'view_all_payments'

--will provide name of all objects which were modified in last x days
SELECT name,type,create_date,modify_date
FROM sys.objects
WHERE 
 DATEDIFF(D,modify_date, GETDATE()) < 60
order by modify_date desc

--will find all objects that reference a field
SELECT sys.objects.object_id, sys.schemas.name AS [Schema], sys.objects.name AS Object_Name, sys.objects.type_desc AS [Type]
FROM sys.sql_modules (NOLOCK) 
INNER JOIN sys.objects (NOLOCK) ON sys.sql_modules.object_id = sys.objects.object_id 
INNER JOIN sys.schemas (NOLOCK) ON sys.objects.schema_id = sys.schemas.schema_id
WHERE
    sys.sql_modules.definition COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%IS_BILLABLE%' ESCAPE '\'
ORDER BY sys.objects.type_desc, sys.schemas.name, sys.objects.name

--Get create/modified date of specified view
select name,create_date, modify_date
 from  sys.views
 WHERE name = 'View_all_data';


--returns the current size of the transaction log and the percentage of log space used for each database
DBCC SQLPERF(LOGSPACE)

-- query to find the recovery model of each database and find the cause of not able to truncate the log file (log_reuse_wait_desc) column.
SELECT name
    ,recovery_model_desc
    ,log_reuse_wait
    ,log_reuse_wait_desc
FROM sys.databases


--Set up a mapped drive for sql to use during backups/imports
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'xp_cmdshell',1
GO
RECONFIGURE
GO

--script to allow a mapped drive to be used in SQL scripts.
EXEC XP_CMDSHELL 'net use Z: "\\192.168.0.0\Directory" /user:name password /persistent:yes'
--Run to verify the mapped drive is accessible to SQL - should see a directory listing
EXEC XP_CMDSHELL 'Dir Z:' 

