/****** Object:  Procedure [dbo].[uspAddUpdateOnBoardingComplianceTemplateItem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateOnBoardingComplianceTemplateItem](@id int, @templateId int, @complianceListId int, @description varchar(max), @isMandatory bit, @sortOrder int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @id = 0 BEGIN
		INSERT INTO 
			OnBoardingComplianceTemplateItems(OnBoardingComplianceTemplateID, ComplianceListID, [Description], IsMandatory, SortOrder)
				VALUES(@templateId, @complianceListId, @description, @isMandatory, @sortOrder)
	END ELSE BEGIN
		UPDATE
			OnBoardingComplianceTemplateItems
		SET
			[Description] = @description,
			IsMandatory = @isMandatory,
			SortOrder = @sortOrder
		WHERE
			ID = @id;
	END
END

