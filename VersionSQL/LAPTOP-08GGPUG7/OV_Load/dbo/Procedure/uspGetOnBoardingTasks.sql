/****** Object:  Procedure [dbo].[uspGetOnBoardingTasks]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingTasks](@search varchar(100), @isDeleted bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT t.*, c.[description] as category, obt.[description] as onboardingtype FROM OnBoardingTasks t
	INNER JOIN 
	OnBoardingTaskCategories c ON c.ID = t.OnBoardingTaskCategoryID
	INNER JOIN
	OnBoardingTypes obt ON obt.ID = t.OnBoardingTypeID
	 WHERE ([name] like '%'+@search +'%') AND t.IsDeleted = @isDeleted;
END

