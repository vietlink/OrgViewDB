/****** Object:  Procedure [dbo].[uspGetDirectIDs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetDirectIDs](@empPosId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @posId int = 0;
	SELECT @posId = positionid FROM EmployeePosition WHERE id = @empPosId
	SELECT ep.id FROM EmployeePosition ep
	INNER JOIN
	Position p
	ON
	p.id = ep.positionid
	INNER JOIN
	Employee e
	ON
	e.id = ep.employeeid
	WHERE e.isplaceholder = 0 and p.parentid = @posId AND p.IsUnassigned = 0 AND ep.IsDeleted = 0 AND p.IsDeleted = 0 AND e.IsDeleted = 0 and dbo.uspGetEmployeeStatusVisible(e.status, EP.Positionid, EP.id) = 1
END
