/****** Object:  Procedure [dbo].[uspGetDynamicReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetDynamicReport] 
	-- Add the parameters for the stored procedure here
	@columnName varchar(max), @condition varchar(max), @groupBy varchar(max), @competencySelected int, @employeeSelected int, @employeepositionSelected int, @positionSelected int, 
	@employeecontactSelected int, @isDaysDueSelected int, @isScoreSelected int, @isPersonSelected int, @isLocationSelected int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @personLabel varchar(50) = (SELECT PersonLabel from ComplianceNotificationDetails)
	DECLARE @competencySQL varchar(max)='	
	INNER JOIN EmployeeComplianceHistory ON Employee.ID= EmployeeComplianceHistory.EmployeeID
	INNER JOIN CompetencyList ON EmployeeComplianceHistory.ListId= CompetencyList.ID
	INNER JOIN Competencies ON CompetencyList.CompetencyId= Competencies.ID and Competencies.Type=2
	INNER JOIN EmployeeCompetencyList ON EmployeeComplianceHistory.EmployeeCompetencyListID= EmployeeCompetencyList.ID
	'
	DECLARE @complianceSQL varchar(max)='
	 AND (EmployeeCompetencyList.hascompliance = 1)	
	'
	IF (@competencySelected=2) BEGIN
		SET @competencySQL= @competencySQL+@complianceSQL;
	END
	IF (@isPersonSelected=1) BEGIN
		SET @competencySQL = @competencySQL + 'LEFT OUTER JOIN Employee e1 ON e1.id= EmployeeComplianceHistory.EmpID
		'
	END
	IF (@isLocationSelected=1) BEGIN
		SET @competencySQL = @competencySQL+ 'LEFT OUTER JOIN FieldValueListItem ON FieldValueListItem.ID = EmployeeComplianceHistory.FieldValueListItemID
		'
	END
	IF (@isDaysDueSelected =1) BEGIN
		SET @columnName= @columnName+ ', DATEDIFF(day, GETDATE(), EmployeeCompetencyList.Dateto) as DaysDue'
	END
	DECLARE @sql nvarchar(max)='	
	SELECT '+@columnName;
	IF (@isScoreSelected =1) BEGIN
		SET @sql= @sql+', EmployeeComplianceHistory.ScoreType, EmployeeComplianceHistory.ScoreRange ';
	END

	SET @sql= @sql+'
	FROM';
	IF (@employeeSelected=1) BEGIN
		SET @sql= @sql+' Employee '
		IF (@employeecontactSelected=1) BEGIN
			SET @sql= @sql+'INNER JOIN EmployeeContact ON Employee.ID= EmployeeContact.employeeid '
		END
		IF (@employeepositionSelected=1) BEGIN
			SET @sql= @sql + 'LEFT OUTER JOIN EmployeePosition ON Employee.ID= EmployeePosition.EmployeeID '
		END
		IF (@positionSelected =1 ) BEGIN
			SET @sql= @sql+ 'LEFT OUTER JOIN Position ON Position.ID= EmployeePosition.PositionID '
		END
	END
	IF (@employeeSelected=0 AND @positionSelected=1) BEGIN
		SET @sql= @sql+' Position ';
	END	
	IF (@competencySelected>0) BEGIN
		SET @sql= @sql+@competencySQL
	END
	IF(@condition!='') BEGIN
		SET @sql=@sql+' WHERE ';
		IF (@employeeSelected=1) BEGIN
			SET @sql= @sql+'Employee.IsPlaceholder=0 ';
		END	
		IF (@employeepositionSelected=1) BEGIN
			SET @sql= @sql+' and EmployeePosition.isDeleted=0'
		END 
		IF (@competencySelected=2) BEGIN
			SET @sql = @sql + ' and dbo.fnGetLatestComplianceDate(Employee.ID, CompetencyList.ID)= EmployeeCompetencyList.DateFrom'
		END
		SET @sql= @sql+@condition
	END
	IF (@groupBy!='') BEGIN
		SET @sql=@sql+@groupBy
	END
	
PRINT @sql
EXEC sp_executesql @sql
END
