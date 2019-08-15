/****** Object:  Procedure [dbo].[uspGetPayrollCycleByPeriodID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetPayrollCycleByPeriodID] 
	-- Add the parameters for the stored procedure here
	@periodID int, @groupID int, @filter varchar(300), @status bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if (@groupID=0) begin
		select pc.id,
		pc.FromDate, 
		pc.ToDate,
		pc.ClosedDate,
		pc.ExpenseFinalisedDate,
		isnull(e.displayname,'') AS closedby,
		isnull(e1.displayname,'') AS expenseclosedby,
		pp.Description AS periodName,
		pg.Description AS groupName,
		ps.Description AS status,
		ps1.Description as expenseStatus,
		ps.Code AS statuscode,
		ps1.Code AS expensestatuscode,
		pc.isDeleted 
		from PayrollCycle pc
		LEFT OUTER JOIN dbo.[User] e ON pc.ClosedByEmpID = e.id
		LEFT OUTER JOIN dbo.[User] e1 ON pc.ExpenseFinalisedByEmpID = e1.id
		INNER JOIN PayrollCyclePeriods pp ON pc.PayrollCyclePeriodID = pp.id
		INNER JOIN PayrollCycleGroups pg ON pc.PayrollCycleGroupID= pg.ID
		INNER JOIN PayrollStatus ps ON pc.PayrollStatusID= ps.ID
		INNER JOIN PayrollStatus ps1 ON pc.ExpensePayrollStatusID= ps1.ID
		WHERE (pg.Description like '%'+@filter+'%' OR ps.Description like '%'+@filter+'%' OR pp.Description like '%'+@filter+'%')
		AND pc.IsDeleted= @status
		AND pc.PayrollCyclePeriodID=@periodID
		ORDER BY pc.PayrollCycleGroupID,		
		pc.id DESC
	end
	else begin
		select pc.id,
		pc.FromDate, 
		pc.ToDate,
		pc.ClosedDate,
		pc.ExpenseFinalisedDate,
		isnull(e.displayname,'') AS closedby,
		isnull(e1.displayname,'') AS expenseclosedby,
		pp.Description AS periodName,
		pg.Description AS groupName,
		ps.Description AS status,
		ps1.Description as expenseStatus,
		ps.Code AS statuscode,
		ps1.Code AS expensestatuscode,
		pc.isDeleted 
		from PayrollCycle pc
		LEFT OUTER JOIN dbo.[User] e ON pc.ClosedByEmpID = e.id
		LEFT OUTER JOIN dbo.[User] e1 ON pc.ExpenseFinalisedByEmpID = e1.id
		INNER JOIN PayrollCyclePeriods pp ON pc.PayrollCyclePeriodID = pp.id
		INNER JOIN PayrollCycleGroups pg ON pc.PayrollCycleGroupID= pg.ID
		INNER JOIN PayrollStatus ps ON pc.PayrollStatusID= ps.ID
		INNER JOIN PayrollStatus ps1 ON pc.ExpensePayrollStatusID= ps1.ID
		WHERE pg.ID=@groupID 
		AND pc.IsDeleted= @status
		ORDER BY pc.PayrollCycleGroupID,		
		pc.id DESC
	end
END
