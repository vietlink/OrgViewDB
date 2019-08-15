/****** Object:  Procedure [dbo].[uspGetParentEmpPosId]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspGetParentEmpPosId]       
 (    
  @EmpPosId int,  
  @ParentEmpPosId int output      
 )      
       
AS      
BEGIN      
      
--set @ParentEmpPosId =(
--	select id from EmployeePositionInfo where id=
--		(
--			select top 1 epi.id from EmployeePositionInfo epi 
--			inner join
--			employeeposition ep
--			on
--			ep.id = epi.id
--			inner join employee e
--			on
--			e.id = ep.employeeid
--			inner join
--			position p
--			on
--			p.id = ep.positionid
--			where epi.positionid =(
--				select positionparentid from EmployeePositionInfo where id=@EmpPosId 
--			)
--			and
--			e.isdeleted = 0 and p.isdeleted = 0 and ep.isdeleted = 0 and epi.isvisible = 1

--		)
--	)

DECLARE @positionId int = 0;
SELECT @positionId = positionid FROM EmployeePosition WHERE ID = @EmpPosId;
DECLARE @parentId int = 0;
SELECT @parentId = parentid FROM Position WHERE id = @positionId

SELECT TOP 1
	@ParentEmpPosId = ep.ID
FROM
	EmployeePosition ep
INNER JOIN
	Position p
ON
	ep.PositionID = p.ID
INNER JOIN
	Employee e
ON
	e.ID = ep.employeeid
WHERE
	p.id = @parentId AND e.isdeleted = 0 AND p.isdeleted = 0 AND ep.isdeleted = 0
	AND
	dbo.uspGetEmployeeStatusVisible(e.status, EP.Positionid, EP.id) = 1

if(@ParentEmpPosId is null)      
 set @ParentEmpPosId =0      
return @ParentEmpPosId      
      
END
