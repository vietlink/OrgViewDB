/****** Object:  Procedure [dbo].[uspSetOnBoardingTaskTemplateIsDeleted]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspSetOnBoardingTaskTemplateIsDeleted](@id int, @isDeleted bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE OnBoardingTaskTemplate SET IsDeleted = @isDeleted WHERE ID = @id;
END

