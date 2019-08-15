/****** Object:  Procedure [dbo].[uspAddOnBoardingTemplateCheckBox]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddOnBoardingTemplateCheckBox](@description varchar(512), @templateId int, @isMandatory bit, @code varchar(16))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO
		OnBoardingTemplateCheckBoxes([Description], OnBoardingTemplateID, IsMandatory, Code)
	VALUES(@description, @templateId, @isMandatory, @code)
END

