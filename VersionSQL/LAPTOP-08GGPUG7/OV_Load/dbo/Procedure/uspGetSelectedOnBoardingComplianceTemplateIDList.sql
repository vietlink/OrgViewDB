/****** Object:  Procedure [dbo].[uspGetSelectedOnBoardingComplianceTemplateIDList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetSelectedOnBoardingComplianceTemplateIDList](@templateId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT ComplianceListID FROM OnBoardingComplianceTemplateItems WHERE OnBoardingComplianceTemplateID = @templateID
END

