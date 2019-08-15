/****** Object:  Procedure [dbo].[uspCreateVacantIfEmpty]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspCreateVacantIfEmpty](@positionId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- assume terminated is still active so find by position
	DECLARE @vacantId int = 0;
	SELECT @vacantId = ID FROM Employee WHERE Identifier = 'Vacant';

	DECLARE @childcount int;
	SELECT TOP 1 @childcount = childcount FROM EmployeePosition WHERE PositionID = @positionId AND IsDeleted = 0;

	DECLARE @isVisible bit;
	SELECT @isVisible = IsVisibleChart FROM Position WHERE ID = @positionId AND IsUnassigned = 0;

	IF ISNULL(@isVisible, 0) = 1 AND @childcount > 0 BEGIN
		DECLARE @availableCount int = 0;
		SELECT @availableCount = COUNT(*) FROM EmployeePosition ep INNER JOIN Employee e ON e.ID = ep.EmployeeID WHERE ep.PositionID = @positionId AND ep.IsDeleted = 0 AND
			dbo.uspGetEmployeeStatusVisible(e.status, EP.Positionid, EP.id) = 1
		IF @availableCount < 1 BEGIN
			DECLARE @currentVacantId int = 0;
			SELECT @currentVacantId = id FROM EmployeePosition WHERE EmployeeID = @vacantId AND PositionID = @positionId;
			IF(ISNULL(@currentVacantId, 0) > 0)
				UPDATE EmployeePosition SET IsDeleted = 0 WHERE ID = @currentVacantId;
			ELSE
				INSERT INTO EmployeePosition(EmployeeID, PositionID, primaryposition, vacant, IsDeleted)
					VALUES(@vacantId, @positionId, 'N', 'Y', 0);
		END
	END
END

