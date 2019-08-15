/****** Object:  Procedure [dbo].[uspSetCurrentPrimaryPosition]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspSetCurrentPrimaryPosition](@empId int, @isFromEngine int = 0)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @currentPrimaryPositionID int;
	DECLARE @currentEPID int;
	DECLARE @currentStartDate datetime;
	DECLARE @currentEndDate datetime;

	DECLARE @unassignedId int = 0;
	SELECT @unassignedId = id FROM Position p WHERE IsUnassigned = 1

	SELECT TOP 1
		@currentEPID = id,
		@currentPrimaryPositionID = positionid,
		@currentStartDate = startdate,
		@currentEndDate = enddate
	FROM 
		EmployeePosition
	WHERE
		IsDeleted = 0 AND EmployeeID = @empId AND primaryposition = 'Y'

	DECLARE @newPrimaryPositionID int;
	DECLARE @newEPID int;
	DECLARE @newStartDate datetime;
	DECLARE @newEndDate datetime;
	DECLARE @newFte decimal(18,8);
	DECLARE @newExclFromSubordCount varchar(1);
	DECLARE @newManagerial varchar(1);
	DECLARE @newManagerID int;

	DECLARE @vacantId int = 0;
	SELECT @vacantId = id FROM employee WHERE identifier = 'Vacant';

	DECLARE @updateCounts bit = 1;
	DECLARE @availableCount int = 0;
	DECLARE @currentVacantId int = 0;
	DECLARE @isVisible bit;
	DECLARE @childcount int;
	
	SELECT TOP 1
		@newEPID = id,
		@newPrimaryPositionID = positionid,
		@newStartDate = startdate,
		@newEndDate = enddate,
		@newFte = fte,
		@newExclFromSubordCount = ExclFromSubordCount,
		@newManagerial = managerial,
		@newManagerID = managerid
	FROM
		EmployeePositionHistory
	WHERE
		employeeid = @empid AND primaryposition = 'Y'
		AND
		((DATEADD(d,0,DATEDIFF(d,0,GETDATE())) >= startdate AND DATEADD(d,0,DATEDIFF(d,0,GETDATE())) <= isnull(enddate, '01-01-9999'))
		OR
		(startdate = DATEADD(d,0,DATEDIFF(d,0,GETDATE())) OR enddate = DATEADD(d,0,DATEDIFF(d,0,GETDATE()))))

	
	DECLARE @currentIsVisibleChart bit;
	DECLARE @newIsVisibleChart bit;
	DECLARE @currentParentId bit;
	DECLARE @newParentId bit;

	SELECT @currentIsVisibleChart = ISNULL(IsVisibleChart, 0), @currentParentId = parentid FROM Position WHERE id = @currentPrimaryPositionID;
	SELECT @newIsVisibleChart = ISNULL(IsVisibleChart, 0), @newParentId = parentid FROM Position WHERE id = @newPrimaryPositionID

	IF @currentParentId = @unassignedId OR @currentPrimaryPositionID = @unassignedId
		SET @currentIsVisibleChart = 0

	IF @newParentId = @unassignedId
		SET @newIsVisibleChart = 0;

	IF @newPrimaryPositionID IS NULL BEGIN -- No new record found, means no current valid EP, create unassigned
		UPDATE EmployeePosition	SET	IsDeleted = 1 WHERE id = @currentEPID
		--UPDATE EmployeePositionInfo SET IsVisible = 0 WHERE id = @currentEPID
		exec dbo.uspRunUpdatePreferenceBlocking @currentEpId, @empId, @currentPrimaryPositionID, 1
		
		DECLARE @unassignedEpId int;
		SELECT @unassignedEpId = id FROM EmployeePosition WHERE positionid = @unassignedId AND primaryposition = 'Y' AND employeeid = @empid;
		IF @unassignedEpId IS NOT NULL AND @unassignedEpId > 0 BEGIN
			UPDATE EmployeePosition SET IsDeleted = 0, startdate = DATEADD(d,0,DATEDIFF(d,0,GETDATE())), enddate = null, primaryposition = 'Y', ExclFromSubordCount = 'Y', Managerial = 'N' WHERE id = @unassignedEpId;
		END ELSE BEGIN
			INSERT INTO EmployeePosition(employeeid, positionid, startdate, primaryposition, ExclFromSubordCount, Managerial)
				VALUES(@empId, @unassignedId, DATEADD(d,0,DATEDIFF(d,0,GETDATE())), 'Y', 'Y', 'N')
			SET @unassignedEpId = @@IDENTITY;
		END

		exec dbo.uspCreateEPIRecord @unassignedEpId, @empId, @unassignedId;
		exec dbo.uspRunUpdatePreferenceBlocking @unassignedEpId, @empId, @unassignedId, 1;
		
		IF @isFromEngine = 0 AND (@currentIsVisibleChart = 1 OR @newIsVisibleChart = 1) BEGIN
			exec dbo.uspBuildPositionGrouplessHierarchy;
			exec dbo.uspUpdateAllCounts;
			exec dbo.uspSetEmptyParentEmpPos;
		END

		SELECT @childcount = childcount FROM EmployeePosition WHERE ID = @currentEPID
		SELECT @isVisible = IsVisibleChart FROM Position WHERE ID = @currentPrimaryPositionID AND IsUnassigned = 0;

		IF ISNULL(@isVisible, 0) = 1 AND @childcount > 0 BEGIN
			SELECT @availableCount = COUNT(*) FROM EmployeePosition ep INNER JOIN Employee e ON e.ID = ep.employeeid WHERE PositionID = @currentPrimaryPositionID AND ep.IsDeleted = 0 AND ep.EmployeeID <> @empId
			AND dbo.uspGetEmployeeStatusVisible(e.status, EP.Positionid, EP.id) = 1

			IF @availableCount < 1 BEGIN
				SELECT @currentVacantId = id FROM EmployeePosition WHERE EmployeeID = @vacantId AND PositionID = @currentPrimaryPositionID;
				IF(ISNULL(@currentVacantId, 0) > 0)
					UPDATE EmployeePosition SET IsDeleted = 0 WHERE ID = @currentVacantId;
				ELSE
					INSERT INTO EmployeePosition(EmployeeID, PositionID, primaryposition, vacant, IsDeleted)
						VALUES(@vacantId, @currentPrimaryPositionID, 'N', 'Y', 0);
			END
		END

		RETURN;
	END
	
	IF @newPrimaryPositionID = ISNULL(@currentPrimaryPositionID, 0) BEGIN -- EP exists with same pos, update data
		UPDATE
			EmployeePosition
		SET
			startdate = @newStartDate,
			enddate = @newEndDate,
			fte = @newFte,
			ExclFromSubordCount = @newExclFromSubordCount,
			Managerial = @newManagerial,
			managerid = @newManagerID,
			primaryposition = 'Y',
			IsDeleted = 0
		WHERE
			id = @currentEPID;
		exec dbo.uspCreateEPIRecord @currentEpId, @empId, @currentPrimaryPositionID 
		exec dbo.uspRunUpdatePreferenceBlocking @currentEpId, @empId, @currentPrimaryPositionID, 1;
		SET @updateCounts = 0;
	END
	ELSE BEGIN
		IF @currentEPID IS NOT NULL BEGIN -- ep exists, delete and create a new one
			UPDATE EmployeePosition SET IsDeleted = 1 WHERE id = @currentEPID;
			--UPDATE EmployeePositionInfo SET IsVisible = 0 WHERE id = @currentEPID
			exec dbo.uspRunUpdatePreferenceBlocking @currentEpId, @empId, @currentPrimaryPositionID, 1
		END

		DECLARE @existsId int;
		SELECT @existsId = id FROM EmployeePosition WHERE employeeid = @empId AND positionid = @newPrimaryPositionID;
		
		IF @existsId IS NOT NULL BEGIN
			UPDATE
				EmployeePosition
			SET
				startdate = @newStartDate,
				enddate = @newEndDate,
				fte = @newFte,
				ExclFromSubordCount = @newExclFromSubordCount,
				Managerial = @newManagerial,
				managerid = @newManagerID,
				primaryposition = 'Y',
				IsDeleted = 0
			WHERE
				id = @existsId				
		END
		ELSE BEGIN
			INSERT INTO EmployeePosition(positionid, employeeid, primaryposition, startdate, enddate, fte, vacant,
			managerial, ExclFromSubordCount, managerid)
			VALUES(@newPrimaryPositionID, @empId, 'Y', @newStartDate, @newEndDate, @newFte, 'N',
				@newManagerial, @newExclFromSubordCount, @newManagerID)

			SET @existsId = @@IDENTITY;
		END
		exec dbo.uspCreateEPIRecord @existsId, @empId, @newPrimaryPositionID
		exec dbo.uspRunUpdatePreferenceBlocking @existsId, @empId, @newPrimaryPositionID, 1
	END
	
	IF @empId <> @vacantId BEGIN
		UPDATE EmployeePosition SET IsDeleted = 1 WHERE positionid = @newPrimaryPositionID AND employeeid = @vacantId;
		--UPDATE EmployeePositionInfo SET IsVisible = 0 WHERE positionid = @newPrimaryPositionID AND employeeid = @vacantId;
	END

	SELECT @childcount = childcount FROM EmployeePosition WHERE ID = @currentEPID

	SELECT @isVisible = IsVisibleChart FROM Position WHERE ID = @currentPrimaryPositionID AND IsUnassigned = 0;

	-- add vacant for old
	IF ISNULL(@isVisible, 0) = 1 AND @childcount > 0 BEGIN
		SELECT @availableCount = COUNT(*) FROM EmployeePosition ep INNER JOIN Employee e ON e.ID = ep.employeeid WHERE PositionID = @currentPrimaryPositionID AND ep.IsDeleted = 0 AND ep.EmployeeID <> @empId
		AND dbo.uspGetEmployeeStatusVisible(e.status, EP.Positionid, EP.id) = 1

		IF @availableCount < 1 BEGIN
			SELECT @currentVacantId = id FROM EmployeePosition WHERE EmployeeID = @vacantId AND PositionID = @currentPrimaryPositionID;
			IF(ISNULL(@currentVacantId, 0) > 0)
				UPDATE EmployeePosition SET IsDeleted = 0 WHERE ID = @currentVacantId;
			ELSE
				INSERT INTO EmployeePosition(EmployeeID, PositionID, primaryposition, vacant, IsDeleted)
					VALUES(@vacantId, @currentPrimaryPositionID, 'N', 'Y', 0);
		END
	END

	-- remove vaccant from new
	SELECT @isVisible = IsVisibleChart FROM Position WHERE ID = @newPrimaryPositionID AND IsUnassigned = 0;
	IF ISNULL(@isVisible, 0) = 1 BEGIN
		SELECT @availableCount = COUNT(*) FROM EmployeePosition ep INNER JOIN Employee e ON e.ID = ep.employeeid WHERE PositionID = @newPrimaryPositionID AND ep.IsDeleted = 0 AND ep.EmployeeID <> @empId
			AND dbo.uspGetEmployeeStatusVisible(e.status, EP.Positionid, EP.id) = 1

		IF @availableCount > 0
			UPDATE EmployeePosition SET IsDeleted = 1 WHERE EmployeeID = @vacantId AND PositionID = @newPrimaryPositionID
	END

	-- clean up any loose deleted ep records
	--UPDATE
	--	epi
	--SET
	--	epi.IsVisible = 0
	--FROM
	--	EmployeePositionInfo epi
	--INNER JOIN
	--	EmployeePosition ep
	--ON
	--	ep.id = epi.id
	--WHERE
	--	ep.employeeid = @empId AND ep.primaryposition = 'Y' AND ep.IsDeleted = 1

	--DELETE FROM EmployeePositionInfo WHERE ID IN (SELECT ID FROM EmployeePosition WHERE EmployeeID = @empId AND
	--	primaryposition = 'Y' AND IsDeleted = 1)

	DECLARE @checkId int;
	SELECT @checkId = id FROM EmployeePosition WHERE employeeid = @empId AND positionid = @newPrimaryPositionID;

	--IF ISNULL(@newPrimaryPositionID, 0) > 0 BEGIN
	--	IF NOT EXISTS (SELECT ID FROM EmployeePositionInfo WHERE ID = @checkId) BEGIN
	--		exec dbo.uspCreateEPIRecord @checkId, @empId, @newPrimaryPositionID
	--	END
	--END

	--IF ISNULL(@checkId, 0) > 0 BEGIN
	--	exec dbo.uspRunUpdatePreferenceBlocking @checkId, @empId, @newPrimaryPositionID, 1
	--END

	EXEC dbo.uspUpdateAllCounts
	
	IF @isFromEngine = 0 AND @updateCounts = 1 AND (@currentIsVisibleChart = 1 OR @newIsVisibleChart = 1) BEGIN
		exec dbo.uspBuildPositionGrouplessHierarchyWithJob;
		exec dbo.uspSetEmptyParentEmpPos;
	END
END
