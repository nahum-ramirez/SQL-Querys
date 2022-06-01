/*****************************************************************************************************************************************************************************************
SQL_LOGIN
*****************************************************************************************************************************************************************************************/
select name, type_desc, create_date, modify_date, default_database_name, default_language_name, is_policy_checked, is_expiration_checked, is_disabled from sys.sql_logins


/****************************************************************************************************************************************************************************************
SQL_USER
*****************************************************************************************************************************************************************************************/
DROP TABLE #RelacionLoginUsuarios

CREATE TABLE #RelacionLoginUsuarios (
	[db_name] nvarchar(512),
	[login_name] nvarchar(512),
	[user_name] nvarchar(512),
	[type_desc] nvarchar(512),
	[default_database_name] nvarchar(512),
	[create_date] datetime,
	[modify_date] datetime,
	[authentication_type_desc] nvarchar(512),
)

DECLARE @command varchar(1000) 

SELECT @command = ' USE [?]
insert into #RelacionLoginUsuarios([db_name], [login_name], [user_name], [type_desc], default_database_name, create_date, modify_date, authentication_type_desc)
select DB_NAME() [db_name], slg.name [login_name], dbp.name [user_name], dbp.type_desc, default_database_name, dbp.create_date, dbp.modify_date, authentication_type_desc
from sys.sql_logins slg
inner join sys.database_principals dbp on dbp.sid = slg.sid
	' 
EXEC sp_MSforeachdb @command 

SELECT * FROM #RelacionLoginUsuarios

--insert into #RelacionLoginUsuarios([db_name], [login_name], [user_name], [type_desc], default_database_name, create_date, modify_date, authentication_type_desc)
--select DB_NAME() [db_name], slg.name [login_name], dbp.name [user_name], dbp.type_desc, default_database_name, dbp.create_date, dbp.modify_date, authentication_type_desc
--from sys.sql_logins slg
--left join sys.database_principals dbp on dbp.sid = slg.sid


/****************************************************************************************************************************************************************************************
SQL_SERVER_ROLE
****************************************************************************************************************************************************************************************/

select slg.name [login_name], svp.name [principal_name], dpr.name [name_server_role], svp.is_disabled
from sys.sql_logins slg
inner join sys.server_principals svp on svp.sid = slg.sid
inner join sys.server_role_members srm on srm.member_principal_id = svp.principal_id
inner join (select name, principal_id from sys.server_principals where type = 'R') dpr on dpr.principal_id = srm.role_principal_id
order by svp.name, dpr.name


/****************************************************************************************************************************************************************************************
SQL_DATABASE_ROLE
****************************************************************************************************************************************************************************************/

DROP TABLE #sql_database_role

CREATE TABLE #sql_database_role (
	[db_name] nvarchar(512),
	[login_name] nvarchar(512),
	[user_name] nvarchar(512),
	[name_database_role] nvarchar(512)
)

DECLARE @cmd_sql_database_role varchar(1000) 

SELECT @cmd_sql_database_role = ' USE [?]
insert into #sql_database_role([db_name], [login_name], [user_name], [name_database_role])
select DB_NAME() [db_name], slg.name [login_name], dbp.name [user_name], dpr.name [name_database_role]
from sys.sql_logins slg
inner join sys.database_principals dbp on dbp.sid = slg.sid
inner join sys.database_role_members drm on drm.member_principal_id = dbp.principal_id
inner join (select name, principal_id from sys.database_principals where type = ''R'') dpr on dpr.principal_id = drm.role_principal_id
order by dbp.name, dpr.name
	' 
EXEC sp_MSforeachdb @cmd_sql_database_role 

SELECT * FROM #sql_database_role


--select DB_NAME() [db_name], slg.name [login_name], dbp.name [user_name], dpr.name [name_database_role]
--from sys.sql_logins slg
--inner join sys.database_principals dbp on dbp.sid = slg.sid
--inner join sys.database_role_members drm on drm.member_principal_id = dbp.principal_id
--inner join (select name, principal_id from sys.database_principals where type = 'R') dpr on dpr.principal_id = drm.role_principal_id
--order by dbp.name, dpr.name
