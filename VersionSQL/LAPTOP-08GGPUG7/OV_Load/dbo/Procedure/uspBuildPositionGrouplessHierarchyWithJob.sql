/****** Object:  Procedure [dbo].[uspBuildPositionGrouplessHierarchyWithJob]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspBuildPositionGrouplessHierarchyWithJob](@jobName varchar(30) = '')
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @jobName = '' BEGIN
		DECLARE @job varchar(30) = SUBSTRING(cast(newid() as varchar(36)), 0, 30)
		DECLARE @step varchar(30) = SUBSTRING(@job, 0, 29);
		DECLARE @db varchar(50) = db_name();

		EXEC msdb.dbo.sp_add_job
			@job_name = @job,
			@delete_level = 3;

		DECLARE @sqlScript varchar(255) = 'EXEC uspBuildPositionGrouplessHierarchy ' + '''' + @job + '''';
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

	DELETE FROM PositionGrouplessHierarchy
	
	DECLARE 
		posCursor CURSOR FOR
	SELECT 
		id, parentid, isplaceholder
	FROM 
		Position
	WHERE
		IsDeleted = 0 AND IsUnassigned = 0

	DECLARE @posId int;
	DECLARE @parentId int;
	DECLARE @isPlaceholder bit;

	OPEN posCursor;

	FETCH NEXT FROM
		posCursor
	INTO
		@posId, @parentId, @isPlaceholder;

	WHILE @@FETCH_STATUS = 0  
	BEGIN
		IF @parentId IS NOT NULL BEGIN
			-- scan up the hierarchy looking for a parent which is not a group
	
			DECLARE @parent_Id int;
			DECLARE @parent_parentId int
			DECLARE @parent_isPlaceholder int;

			SET @parent_parentId = @parentId;

			INSERT INTO PositionGrouplessHierarchy(PositionID, ParentID)
				VALUES(@posId, @parent_parentId);

			SELECT 
				@parent_Id = id, @parent_parentId = parentid, @parent_isPlaceholder = isplaceholder
			FROM
				Position
			WHERE
				id = @parent_parentId;

			-- Scan up the hierarchy creating dummy data, stop at position
			WHILE @parent_parentId IS NOT NULL
			BEGIN
				IF @parent_isPlaceholder = 0
					BREAK;

				IF @parent_parentId IS NOT NULL
					INSERT INTO PositionGrouplessHierarchy(PositionID, ParentID)
						VALUES(@posId, @parent_parentId);

				SELECT 
					@parent_Id = id, @parent_parentId = parentid, @parent_isPlaceholder = isplaceholder
				FROM
					Position
				WHERE
					id = @parent_parentId;
			END

		END
		FETCH NEXT FROM
			posCursor
		INTO
			@posId, @parentId, @isPlaceholder;
	END

	CLOSE posCursor;
	DEALLOCATE posCursor;

	DECLARE @topPositionId int = 0;
	SELECT @topPositionId = id FROM Position WHERE ParentID IS NULL AND IsDeleted = 0
	IF NOT EXISTS (SELECT TOP 1 PositionID FROM PositionGrouplessHierarchy WHERE PositionID = @topPositionId AND ParentID IS NULL) BEGIN
		INSERT INTO PositionGrouplessHierarchy(PositionID, ParentID) VALUES (@topPositionId, NULL);
	END

	EXEC uspBuildPositionParentHierarchy
END

