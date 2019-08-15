/****** Object:  Procedure [dbo].[uspGetOnBoardingTasksNotInList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingTasksNotInList](@currentIdList varchar(max))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @idTable TABLE(id int);
	IF CHARINDEX(',', @currentIdList, 0) > 0 BEGIN
		INSERT INTO @idTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS int) FROM fnSplitString(@currentIdList, ',');	
    END ELSE IF LEN(@currentIdList) > 0 BEGIN
		INSERT INTO @idTable SELECT CAST(@currentIdList AS int)
	END

	SELECT t.*, c.description as Category FROM
	OnBoardingTasks t 
	INNER JOIN
	OnBoardingTaskCategories c
	ON c.id = t.OnBoardingTaskCategoryID
	WHERE t.ID NOT IN (SELECT id FROM @idTable)
END

