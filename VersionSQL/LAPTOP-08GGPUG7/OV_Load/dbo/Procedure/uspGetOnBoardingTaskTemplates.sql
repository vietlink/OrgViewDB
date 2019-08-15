/****** Object:  Procedure [dbo].[uspGetOnBoardingTaskTemplates]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingTaskTemplates](@search varchar(100), @isDeleted bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM OnBoardingTaskTemplate WHERE ([description] like '%'+@search +'%') AND IsDeleted = @isDeleted;
END

