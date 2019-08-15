/****** Object:  Procedure [dbo].[uspGetOnBoardingTaskTemplateItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingTaskTemplateItems](@templateId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT t.name as OnBoardingTask, i.* FROM OnBoardingTaskTemplateItems i
	INNER JOIN
	OnBoardingTasks t
	ON
	t.id = i.OnBoardingTaskID
	WHERE i.OnBoardingTaskTemplateID = @templateId ORDER BY i.SortOrder ASC
END

