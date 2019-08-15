/****** Object:  Procedure [dbo].[uspUpdateAllCounts]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdateAllCounts] (@jobName varchar(30) = '')
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

		DECLARE @sqlScript varchar(255) = 'EXEC uspUpdateAllCounts ''' + @job + '''';
	
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
					where name <> @jobName  and date_created < @createdDate
					and database_name = db_name()
					and stop_execution_date is null and start_execution_date is not null)
	begin
		WAITFOR DELAY '00:00:01';   
	end

    UPDATE
		ep
	SET
		ep.childcount = dbo.uspCheckHasChildren(ep.id),
		ep.directheadcount = dbo.uspCheckHasChildren(ep.id),
		ep.totalheadcount = dbo.uspGetTotalHeadCountRecursive(ep.positionid),
		ep.actualchildcount = dbo.uspGetTotalHeadCountRecursive2(ep.positionid),
		ep.actualtotalcount = dbo.uspGetTotalHeadCountRecursive3(ep.positionid)
	FROM
		EmployeePosition ep
	INNER JOIN
		Employee e
	ON
		e.ID = ep.EmployeeID
	WHERE
		dbo.uspGetEmployeeStatusVisible(e.status, EP.Positionid, EP.id) = 1

END
