/****** Object:  Procedure [dbo].[uspGetCustomFields]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetCustomFields](@empId int, @posId int, @empPosId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @tableName varchar(255);
	declare @columnName varchar(255);
	declare @code varchar(255);
	declare @shortName varchar(255);

	declare fieldScan cursor for

	select
		LEFT(ap.value,CHARINDEX('.',ap.value)-1),
		RIGHT(ap.value,LEN(ap.value)-CHARINDEX('.',ap.value)),
		p.code,
		a.shortname
	from
		applicationpreference ap
	inner join
		preference p
	on
		p.id = ap.preferenceid
	inner join
		entity e
	on
		e.tablename = LEFT(ap.value,CHARINDEX('.',ap.value)-1)
	inner join
		attribute a
	on
		a.columnname = RIGHT(ap.value,LEN(ap.value)-CHARINDEX('.',ap.value)) AND a.entityid = e.id
	where
		p.code in ('customfield1value', 'customfield2value', 'customfield3value', 'customfield4value');

	open fieldScan;
	fetch next from fieldScan into @tableName, @columnName, @code, @shortName

	create table #resultTable ( value varchar(max), code varchar(255) );
	declare @result varchar(max);
	while @@FETCH_STATUS = 0 begin
		declare @sql nvarchar(1000);

		IF @tableName = 'Employee' BEGIN
			SET @sql = 'INSERT INTO #resultTable SELECT ' + @columnName + ',''' + @code + ''' FROM Employee WHERE id = ' + CAST(@empId as varchar);
		END
		ELSE IF @tableName = 'Position' BEGIN
			SET @sql = 'INSERT INTO #resultTable SELECT ' + @columnName + ',''' + @code + ''' FROM Position WHERE id = ' + CAST(@posId as varchar)
		END
		ELSE IF @tableName = 'EmployeeContact' BEGIN
			SET @sql = 'INSERT INTO #resultTable SELECT ' + @columnName + ',''' + @code + ''' FROM EmployeeContact WHERE employeeid = ' + CAST(@empId as varchar)
		END
		ELSE IF @tableName = 'EmployeePosition' BEGIN
			SET @sql = 'INSERT INTO #resultTable SELECT ' + @columnName + ',''' + @code + ''' FROM EmployeePosition WHERE id = ' + CAST(@empPosId as varchar)
		END
		print @sql
		EXECUTE sp_executesql @sql

		fetch next from fieldScan into @tableName, @columnName, @code, @shortName
	end

	close fieldScan;
	deallocate fieldScan;

	select @empId as EmployeeID, @posId as PositionID, @empPosId as EmployeePositionID, customfield1value, customfield2value, customfield3value, customfield4value from ( select * from #resultTable) as r pivot ( max(value) for code in (customfield1value, customfield2value, customfield3value, customfield4value) ) as pvt
	drop table #resultTable;
END

