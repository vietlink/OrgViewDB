/****** Object:  Procedure [dbo].[uspGetEmployeePositionReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspGetEmployeePositionReport] 
	-- Add the parameters for the stored procedure here
	@empID int, @posID int, @depth int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @managerPosID int 
	set @managerPosID = @posID
	if (@empID =0) begin
		SELECT TOP 1
		@managerPosID = p.ID
	FROM
		EmployeePosition EP
	INNER JOIN
		Position p
	ON
		p.ID = ep.PositionID
	WHERE
		ep.IsDeleted = 0 AND p.IsDeleted = 0 AND p.parentid IS NULL AND p.IsVisibleChart = 1 AND Identifier <> 'Vacant'		
	ORDER BY Ep.ID asc
	IF (isnull(@managerPosID,0)<1) BEGIN
		SELECT TOP 1
			@managerPosID = p.ID
		FROM
			EmployeePosition EP
		INNER JOIN
			Position p
		ON
			p.ID = ep.PositionID
		WHERE
			ep.IsDeleted = 0 AND p.IsDeleted = 0 AND p.parentid IS NULL AND p.IsVisibleChart = 1
		ORDER BY Ep.ID asc
	END
	end
	;WITH EmpCTE (empID, empPosID, displayname, posID, title, division, department, fte, parentid, parentname, parentposition, depth) AS
	(SELECT e.id as empID,
		ep.id as empPosID,
		e.displayname, 
		p.id as posID,
		p.title,
		p.orgunit2 as division,
		p.orgunit3 as department,
		ep.fte,
		isnull(p.parentid,0) as parentid,
		isnull(e1.displayname,'') as parentname,
		isnull(p1.title,'') as parentposition,
		1 as depth
	FROM Employee e 
	INNER JOIN EmployeePosition ep ON e.id= ep.employeeid AND ep.primaryposition='Y' and ep.IsDeleted=0
	INNER JOIN Position p ON ep.positionid= p.id
	INNER JOIN EmployeePosition epP ON p.parentid = epP.positionid and epp.primaryposition='Y' and epp.IsDeleted=0
	INNER JOIN Position p1 ON p1.id= epP.positionid
	INNER JOIN Employee e1 ON e1.id= epP.employeeid
	WHERE e.IsDeleted = 0 and p.IsUnassigned = 0 and p.parentid=@managerPosID
	and e.IsPlaceholder=0
	and e1.IsDeleted = 0 and p1.IsUnassigned = 0 and e1.IsPlaceholder=0 
	
	UNION ALL
	SELECT e.id as empID,
		ep.id as empPosID,
		e.displayname, 
		p.id as posID,
		p.title,
		p.orgunit2 as division,
		p.orgunit3 as department,
		ep.fte,
		
		isnull(p.parentid,0) as parentid,
		isnull(e1.displayname,'') as parentname,
		isnull(p1.title,'') as parentposition,
		depth + 1 as depth
	FROM Employee e 
	INNER JOIN EmployeePosition ep ON e.id= ep.employeeid AND ep.primaryposition='Y' and ep.IsDeleted=0
	INNER JOIN Position p ON ep.positionid= p.id
	INNER JOIN EmpCTE ec ON p.parentid= ec.posID
	INNER JOIN EmployeePosition epP ON p.parentid = epP.positionid and epp.primaryposition='Y' and epp.IsDeleted=0
	INNER JOIN Position p1 ON p1.id= epP.positionid
	INNER JOIN Employee e1 ON e1.id= epP.employeeid
	WHERE e.IsDeleted = 0 and p.IsUnassigned = 0 and e.IsPlaceholder=0 
	and e1.IsDeleted = 0 and p1.IsUnassigned = 0 and e1.IsPlaceholder=0 
)
select * from EmpCTE  where depth<=@depth
UNION
SELECT e.id as empID,
		ep.id as empPosID,
		e.displayname, 
		p.id as posID,
		p.title,
		p.orgunit2 as division,
		p.orgunit3 as department,
		ep.fte,
		
		isnull(p.parentid,0) as parentid,
		isnull(e1.displayname,'') as parentname,
		isnull(p1.title,'') as parentposition,
		0 as depth
	FROM Employee e 
	LEFT OUTER JOIN EmployeePosition ep ON e.id= ep.employeeid AND ep.primaryposition='Y' and ep.IsDeleted=0
	LEFT OUTER JOIN Position p ON ep.positionid= p.id
	LEFT OUTER JOIN EmployeePosition epP ON p.parentid = epP.positionid and epp.primaryposition='Y' and epp.IsDeleted=0
	LEFT OUTER JOIN Position p1 ON p1.id= epP.positionid
	LEFT OUTER JOIN Employee e1 ON e1.id= epP.employeeid
	where ((e.id= @empID)or (@empID=0))
	and p.id= @managerPosID
	and ((e1.IsDeleted = 0 and p1.IsUnassigned = 0 and e1.IsPlaceholder=0  and @empID!=0) or (@empID=0))
order by depth, displayname

END
