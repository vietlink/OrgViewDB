/****** Object:  Procedure [dbo].[uspSetOnBoardingDocumentTemplateIsDeleted]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspSetOnBoardingDocumentTemplateIsDeleted](@id int, @isDeleted bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE OnBoardingDocumentTemplate SET IsDeleted = @isDeleted WHERE ID = @id;
END

