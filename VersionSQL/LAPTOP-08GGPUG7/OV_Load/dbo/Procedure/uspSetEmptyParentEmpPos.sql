/****** Object:  Procedure [dbo].[uspSetEmptyParentEmpPos]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspSetEmptyParentEmpPos](@jobName varchar(30) = '')
AS
BEGIN

	IF @jobName = '' BEGIN
		DECLARE @job varchar(30) = SUBSTRING(cast(newid() as varchar(36)), 0, 30)
		DECLARE @step varchar(30) = SUBSTRING(@job, 0, 29);
		DECLARE @db varchar(50) = db_name();

		EXEC msdb.dbo.sp_add_job
			@job_name = @job,
			@delete_level = 3;

		DECLARE @sqlScript varchar(255) = 'EXEC uspSetEmptyParentEmpPos ' + '''' + @job + '''';
		print @sqlScript
		EXEC msdb.dbo.sp_add_jobstep
			@job_name = @job,
			@step_name = @step,
			@subsystem = N'TSQL',
			@database_name = @db,
			@command = @sqlScript

		EXEC msdb.dbo.sp_add_jobserver  
			@job_name = @job;  

		EXEC msdb.dbo.sp_start_job @job;
		RETURN;
	END

	declare @createdDate datetime;
	select @createdDate = date_created from msdb.dbo.sysjobs where name = @jobName
	-- loop untill no other jobs created earlier are running, this creates a blocking nature
	WAITFOR DELAY '00:00:01';
	while exists (select * from msdb.dbo.sysjobs j 
					inner join msdb.dbo.sysjobactivity a on j.job_id = a.job_id 
					inner join msdb.dbo.sysjobsteps js ON j.job_id= js.job_id
					where name <> @jobName and date_created < @createdDate
					and database_name = db_name()
					and stop_execution_date is null and start_execution_date is not null)
	begin
		WAITFOR DELAY '00:00:01';   
	end

	DECLARE @unassignedId int = 0;
	SELECT @unassignedId = id FROM Position WHERE IsUnassigned = 1

	DECLARE posScan CURSOR
	FOR
	SELECT
		p.ID
	FROM
		Position p
	WHERE
		p.IsDeleted = 0 AND
		p.Isplaceholder = 0 AND
		p.parentid <> @unassignedId
		AND
		ID NOT IN
		(
			SELECT
				ep.PositionID
			FROM
				EmployeePosition ep
			INNER JOIN
				Employee e
			ON
				e.id = ep.employeeid
			INNER JOIN
				[Status] s
			ON
				s.[Description] = e.[status]
			WHERE
				e.IsDeleted = 0 AND ep.IsDeleted = 0 AND s.IsVisibleChart = 1 AND e.identifier <> 'Vacant'
		)
	--	AND
	--	dbo.uspGetTotalHeadCountRecursive(p.ID) > 0

	DECLARE @vacantId int = 0;
	SELECT @vacantId = id FROM Employee WHERE identifier = 'Vacant'

	DECLARE @posId int;
	OPEN posScan
	FETCH NEXT FROM 
		posScan
	INTO 
		@posId
	IF @posId > 0 BEGIN
		DECLARE @empPosNewId int = 0;
		IF EXISTS(SELECT id FROM EmployeePosition WHERE employeeid = @vacantId AND positionid = @posId) BEGIN
			UPDATE EmployeePosition SET IsDeleted = 0 WHERE employeeid = @vacantId AND positionid = @posId
			SELECT @empPosNewId = id FROM EmployeePosition WHERE employeeid = @vacantId AND positionid = @posId
			--IF NOT EXISTS (SELECT id FROM EmployeePositionInfo WHERE employeeid = @vacantId AND positionid = @posId) BEGIN
			--INSERT INTO
			--	EmployeePositionInfo(id, employeeid, positionid, [displaynameid], displayname, employeeimageurlid, employeeimageurl, positiontitle, customfield1,
			--	customfield2, customfield3, customfield4, availabilitystatus, IsVisible, IsAssistant, haschildren, availabilityiconurl, positiontitleid)
			--		VALUES(@empPosNewId, @vacantId, @posId, 0, '', 0, '', '', '', '', '', '', 1, 1, 0, 0, '', 0)
			--END
			--ELSE BEGIN
			--	UPDATE EmployeePositionInfo SET IsVisible = 1 WHERE ID = @empPosNewId;
			--END
			--EXEC uspRunUpdatePreference @empPosNewID, @vacantId, @posId, 1;
		END
		ELSE
		BEGIN
			INSERT INTO EmployeePosition(employeeid, positionid, primaryposition, fte, vacant, Managerial, ExclFromSubordCount)
				VALUES(@vacantId, @posId, 'Y', 1, 'Y', 'N', 'N');
			SET @empPosNewId = @@IDENTITY;
			--IF NOT EXISTS (SELECT id FROM EmployeePositionInfo WHERE employeeid = @vacantId AND positionid = @posId) BEGIN
			--INSERT INTO
			--	EmployeePositionInfo(id, employeeid, positionid, [displaynameid], displayname, employeeimageurlid, employeeimageurl, positiontitle, customfield1,
			--	customfield2, customfield3, customfield4, availabilitystatus, IsVisible, IsAssistant, haschildren, availabilityiconurl, positiontitleid)
			--		VALUES(@empPosNewId, @vacantId, @posId, 0, '', 0, '', '', '', '', '', '', 1, 1, 0, 0, '', 0)
			--	EXEC uspRunUpdatePreference @empPosNewID, @vacantId, @posId, 1;
			--END
			--ELSE BEGIN
			--	UPDATE EmployeePositionInfo SET IsVisible = 1 WHERE ID = @empPosNewId;
			--	EXEC uspRunUpdatePreference @empPosNewID, @vacantId, @posId, 1;
			--END
		END
		WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH NEXT FROM
				posScan
			INTO
				@posId
			IF @posId > 0 
			BEGIN
				IF EXISTS(SELECT id FROM EmployeePosition WHERE employeeid = @vacantId AND positionid = @posId) 
				BEGIN
					UPDATE EmployeePosition SET IsDeleted = 0 WHERE employeeid = @vacantId AND positionid = @posId
					SELECT @empPosNewId = id FROM EmployeePosition WHERE employeeid = @vacantId AND positionid = @posId

					--IF NOT EXISTS (SELECT id FROM EmployeePositionInfo WHERE employeeid = @vacantId AND positionid = @posId)
					--BEGIN 
					--	INSERT INTO
					--	EmployeePositionInfo(id, employeeid, positionid, [displaynameid], displayname, employeeimageurlid, employeeimageurl, positiontitle, customfield1,
					--	customfield2, customfield3, customfield4, availabilitystatus, IsVisible, IsAssistant, haschildren, availabilityiconurl, positiontitleid)
					--		VALUES(@empPosNewId, @vacantId, @posId, 0, '', 0, '', '', '', '', '', '', 1, 1, 0, 0, '', 0)
					--END
					--ELSE BEGIN
					--	UPDATE EmployeePositionInfo SET IsVisible = 1 WHERE ID = @empPosNewId;
					--END
					--EXEC uspRunUpdatePreference @empPosNewID, @vacantId, @posId, 1;
				END
				ELSE 
				BEGIN
				
					INSERT INTO EmployeePosition(employeeid, positionid, primaryposition, fte, vacant, Managerial, ExclFromSubordCount)
						VALUES(@vacantId, @posId, 'Y', 1, 'Y', 'N', 'N');
					SET @empPosNewId = @@IDENTITY;
					
					--IF NOT EXISTS (SELECT id FROM EmployeePositionInfo WHERE employeeid = @vacantId AND positionid = @posId)
					--BEGIN
					--	INSERT INTO
					--	EmployeePositionInfo(id, employeeid, positionid, [displaynameid], displayname, employeeimageurlid, employeeimageurl, positiontitle, customfield1,
					--	customfield2, customfield3, customfield4, availabilitystatus, IsVisible, IsAssistant, haschildren, availabilityiconurl, positiontitleid)
					--		VALUES(@empPosNewId, @vacantId, @posId, 0, '', 0, '', '', '', '', '', '', 1, 1, 0, 0, '', 0)
					--	EXEC uspRunUpdatePreference @empPosNewID, @vacantId, @posId, 1;
					--END
					--ELSE BEGIN
					--	UPDATE EmployeePositionInfo SET IsVisible = 1 WHERE ID = @empPosNewId;
					--	EXEC uspRunUpdatePreference @empPosNewID, @vacantId, @posId, 1;
					--END
				END
			END
		END
	END
	CLOSE posScan
	DEALLOCATE posScan

END
