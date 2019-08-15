/****** Object:  Procedure [dbo].[uspSetOnBoardingComplianceTemplateIsDeleted]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspSetOnBoardingComplianceTemplateIsDeleted](@id int, @isDeleted bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE OnBoardingComplianceTemplate SET IsDeleted = @isDeleted WHERE ID = @id;
END

