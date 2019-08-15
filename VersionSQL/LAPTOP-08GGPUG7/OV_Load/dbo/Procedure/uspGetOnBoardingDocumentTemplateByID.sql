/****** Object:  Procedure [dbo].[uspGetOnBoardingDocumentTemplateByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingDocumentTemplateByID](@id int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM OnBoardingDocumentTemplate WHERE ID = @id
END

