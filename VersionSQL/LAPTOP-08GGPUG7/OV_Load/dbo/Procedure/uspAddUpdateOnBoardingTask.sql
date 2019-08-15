/****** Object:  Procedure [dbo].[uspAddUpdateOnBoardingTask]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateOnBoardingTask](@id int, @name varchar(100), @description varchar(512), @onBoardingTypeId int, @onBoardingTaskCategoryId int, @leadTime decimal(10,5), @daysBeforeAfter decimal(10,5), @daysBeforeAfterType int, @actionByType int, @actionById int, @notifyTo int, @emailTitle varchar(256), @emailBody varchar(max))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @id = 0 BEGIN
		INSERT INTO 
			OnBoardingTasks(name, [description], onBoardingTypeId, onBoardingTaskCategoryId, leadTime, daysBeforeAfter, daysBeforeAfterType, actionByType, actionById, NotifyToID, emailTitle, emailBody)
				VALUES(@name, @description, @onBoardingTypeId, @onBoardingTaskCategoryId, @leadTime, @daysBeforeAfter, @daysBeforeAfterType, @actionByType, @actionById, @notifyTo, @emailTitle, @emailBody)
	END ELSE BEGIN
		UPDATE
			OnBoardingTasks
		SET
			name = @name,
			[description] = @description, 
			onBoardingTypeId = @onBoardingTypeId, 
			onBoardingTaskCategoryId = @onBoardingTaskCategoryId, 
			leadTime = @leadTime, 
			daysBeforeAfter = @daysBeforeAfter, 
			daysBeforeAfterType = @daysBeforeAfterType, 
			actionByType = @actionByType, 
			actionById = @actionById, 
			NotifyToID = @notifyTo, 
			emailTitle = @emailTitle, 
			emailBody  = @emailBody
		WHERE
			ID = @id;
	END
END

