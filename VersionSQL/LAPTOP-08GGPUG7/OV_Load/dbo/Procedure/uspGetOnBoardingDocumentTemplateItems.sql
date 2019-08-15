/****** Object:  Procedure [dbo].[uspGetOnBoardingDocumentTemplateItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingDocumentTemplateItems](@templateId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM OnBoardingDocumentTemplateItems WHERE OnBoardingDocumentTemplateID = @templateId ORDER BY SortOrder ASC
END

