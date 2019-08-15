/****** Object:  Procedure [dbo].[uspGetAttributeForDynamicReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetAttributeForDynamicReport] 
	-- Add the parameters for the stored procedure here
	@roleID int, @searchText varchar(max), @sortBy varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @personDisplay bit = (SELECT PersonDisplay FROM ComplianceNotificationDetails)
	DECLARE @locationDisplay bit = (SELECT LocationDisplay FROM ComplianceNotificationDetails)
    -- Insert statements for procedure here
	DECLARE @complianceTable table (id int, columnname varchar(max), longname varchar(max), datatype varchar(max), tablename varchar(max), displayTableName varchar(max));
	INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-1, 'Code', 'Code', 'AnsiString','Competencies', 'Compliance');
	INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-7, 'Description', 'Description', 'AnsiString','Competencies', 'Compliance');
	INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-2, 'DateFrom', 'Date From', 'DateTime', 'EmployeeComplianceHistory', 'Compliance');
	INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-3, 'DateTo', 'Date To', 'DateTime', 'EmployeeComplianceHistory', 'Compliance');
	INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-4, 'Reference', 'Reference', 'AnsiString', 'EmployeeComplianceHistory', 'Compliance');
	INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-5, 'ScoreDecimal', 'Score', 'Decimal', 'EmployeeComplianceHistory', 'Compliance');
	INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-6, 'AdditionalInfo', 'Additional Info', 'AnsiString', 'EmployeeComplianceHistory', 'Compliance');
	 INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-8, 'ComplianceStatus', 'Compliance Status', 'Datetime', 'EmployeeCompetencyList', 'Compliance');
	 INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-9, 'DaysDue', 'Days Expired / Due', 'Int32', 'EmployeeCompetencyList', 'Compliance');
	 INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-10, 'IsMandatory', 'Compliance Required', 'Boolean', 'EmployeeCompetencyList', 'Compliance');
	 INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-11, 'IssueDate', 'Issue Date', 'Datetime', 'EmployeeComplianceHistory', 'Compliance');

	 IF (@personDisplay= 1) BEGIN
	 DECLARE @personText varchar(50)= (SELECT PersonLabel FROM ComplianceNotificationDetails)
	 INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-12, 'e1.displayname', @personText, 'AnsiString', '', 'Compliance');
	 END
	 IF (@locationDisplay=1) BEGIN
	 DECLARE @locationText varchar(50)= (SELECT LocationLabel FROM ComplianceNotificationDetails)
	 INSERT INTO @complianceTable (id, columnname, longname, datatype, tablename, displayTableName)
	 VALUES (-13, 'Value', @locationText, 'AnsiString', 'FieldValueListItem', 'Compliance');
	 END
	declare @competencyValueTable TABLE (competencyVal varchar(max), competencyGroup varchar(max))
	declare @positionTemp table (title varchar(max));
	insert into @positionTemp
	select p.title
	from Position p
	where p.IsDeleted=0 and p.IsPlaceholder=0
	order by p.title;
	insert into @competencyValueTable
	select c.Description, cg.Description
	from Competencies c 
	inner join CompetencyList cl on c.Id= cl.CompetencyId
	inner join CompetencyGroups cg on cl.CompetencyGroupId= cg.Id
	where c.Type=2
	order by cg.SortOrder, c.SortOrder
	
	DECLARE @fieldValueTable TABLE(fieldID int, fieldValue varchar(max), fieldText varchar(max))
	INSERT INTO @fieldValueTable
	SELECT f.ID, 
	STUFF((SELECT ','+ fi.Value FROM FieldValueListItem fi WHERE fi.FieldValueListID= f.ID FOR XML PATH('')),1,1,''),
	STUFF((SELECT ','+ fi.Value FROM FieldValueListItem fi WHERE fi.FieldValueListID= f.ID FOR XML PATH('')),1,1,'')
	FROM FieldValueList f

	insert into @fieldValueTable
	values(-7, stuff((select ','+ c.competencyGroup+'-'+c.competencyVal from @competencyValueTable c for xml path('')),1,1,''), stuff((select ','+ c.competencyGroup+'-'+c.competencyVal from @competencyValueTable c for xml path('')),1,1,''))

	declare @empStatusID int= (select a.id from Attribute a where a.code='status')
	declare @primaryPositionID int= (select a.id from Attribute a where a.code='primaryposition')
	declare @positionTitleID int= (select a.id from Attribute a where a.code='postitle')
	insert into @fieldValueTable
	values(999, STUFF((select','+s.Description from Status s for xml path('')),1,1,''), STUFF((select','+s.Description from Status s for xml path('')),1,1,''))
	insert into @fieldValueTable values(@positionTitleID, stuff((select ','+p.title from @positionTemp p for xml path('')),1,1,''), stuff((select ','+p.title from @positionTemp p for xml path('')),1,1,''))
	insert into @fieldValueTable values(1000, 'Y,N', 'Y,N')
	insert into @fieldValueTable values(-10,'1,0', 'Y,N')
	IF (@locationDisplay=1) BEGIN
		DECLARE @fieldValueListID int= (SELECT FieldValueListID FROM ComplianceNotificationDetails)
		INSERT INTO @fieldValueTable values (-13, 
		STUFF((SELECT ','+ fi.Value FROM FieldValueListItem fi WHERE fi.FieldValueListID= @fieldValueListID FOR XML PATH('')),1,1,''),
		STUFF((SELECT ','+ fi.Value FROM FieldValueListItem fi WHERE fi.FieldValueListID= @fieldValueListID FOR XML PATH('')),1,1,'')
		)
	END
	--select * from @fieldValueTable
	
SELECT * FROM(
	SELECT distinct a.id, a.columnname, a.longname, a.datatype, t.Name as Tab, t.TabOrder as TabOrder, 
	case when e.tablename='EmployeePosition' then 'Person Position' 
	when e.tablename='Employee' then 'Person' 
	when e.tablename='EmployeeContact' then 'Person Contact'  
	else e.tablename end as displayTableName,
	isnull(a.FieldValueListID,0) as fieldID,
	isnull(f.fieldValue,'') as fieldValue,
	isnull(f.fieldText,'') as fieldText,
	e.tablename as tablename,
	0 as autoTicked
	FROM Attribute a
	INNER JOIN Entity e ON a.entityid= e.id
	INNER JOIN RoleAttribute ra ON a.id= ra.attributeid
	--INNER JOIN AttributeSource as_ ON a.AttributeSourceID= as_.id
	INNER JOIN Tab t ON a.tab= t.Id
	LEFT OUTER JOIN @fieldValueTable f ON f.fieldID= a.FieldValueListID
	WHERE (e.tablename='EmployeePosition' or e.tablename='Employee' or e.tablename='Position' or e.tablename='EmployeeContact')
	and ((ra.roleid= @roleID) or @roleID=0)
	--and as_.code!='notused' 
	and a.code!='status' and a.code!='primaryposition' and a.code !='postitle'
	UNION
	SELECT distinct a.id, a.columnname, a.longname, a.datatype, t.Name as Tab, t.TabOrder as TabOrder, 
	case when e.tablename='EmployeePosition' then 'Person Position' 
	when e.tablename='Employee' then 'Person' 
	when e.tablename='EmployeeContact' then 'Person Contact'  
	else e.tablename end as displayTableName,
	isnull(f.fieldID,0) as fieldID,
	isnull(f.fieldValue,'') as fieldValue,
	isnull(f.fieldText,'') as fieldText,
	e.tablename as tablename,
	case when a.code='status' then 1 else 0 end as autoTicked
	FROM Attribute a
	INNER JOIN Entity e ON a.entityid= e.id
	INNER JOIN RoleAttribute ra ON a.id= ra.attributeid
	--INNER JOIN AttributeSource as_ ON a.AttributeSourceID= as_.id
	INNER JOIN Tab t ON a.tab= t.Id
	,@fieldValueTable f 
	WHERE 
	(a.code='status' and f.fieldID=999) 
	or
	(a.code='postitle' and f.fieldID=@positionTitleID)
	UNION
	SELECT distinct a.id, a.columnname, a.longname, a.datatype, t.Name as Tab, t.TabOrder as TabOrder, 
	case when e.tablename='EmployeePosition' then 'Person Position' 
	when e.tablename='Employee' then 'Person' 
	when e.tablename='EmployeeContact' then 'Person Contact'  
	else e.tablename end as displayTableName,
	isnull(f.fieldID,0) as fieldID,
	isnull(f.fieldValue,'') as fieldValue,
	isnull(f.fieldText,'') as fieldText,
	e.tablename as tablename,
	0 as autoTicked
	FROM Attribute a
	INNER JOIN Entity e ON a.entityid= e.id
	INNER JOIN RoleAttribute ra ON a.id= ra.attributeid
	--INNER JOIN AttributeSource as_ ON a.AttributeSourceID= as_.id
	INNER JOIN Tab t ON a.tab= t.Id
	,@fieldValueTable f 
	WHERE 
	a.code='primaryposition' and f.fieldID=1000
	UNION
	SELECT c.id, 
		c.columnname, 
		c.longname, 
		c.datatype,
		'' as Tab, 
		999 as TabOrder, 
		c.displayTableName,
		isnull(f.fieldID,0) as fieldID,
		isnull(f.fieldValue,'') as fieldValue,
		isnull(f.fieldText,'') as fieldText,
		c.tablename,
		0 as autoTicked
		FROM @complianceTable c
		left outer join @fieldValueTable f on c.id= f.fieldID
		
	) AS Result
	WHERE (Result.longname like '%'+@searchText+'%' or Result.tablename like '%'+@searchText+'%')
	ORDER BY
		CASE WHEN @sortBy='field' THEN Result.longname END,
		CASE WHEN @sortBy='table' THEN Result.displayTableName END,
		CASE WHEN @sortBy='tab' THEN Result.TabOrder END,
		Result.longname
END
