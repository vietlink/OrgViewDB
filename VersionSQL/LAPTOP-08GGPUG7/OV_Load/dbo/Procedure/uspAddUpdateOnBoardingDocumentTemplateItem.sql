/****** Object:  Procedure [dbo].[uspAddUpdateOnBoardingDocumentTemplateItem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateOnBoardingDocumentTemplateItem](@id int, @templateId int, @title varchar(100), @description varchar(max), @documentTypeId int, @isMandatory bit, @sortOrder int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @id = 0 BEGIN
		INSERT INTO 
			OnBoardingDocumentTemplateItems(OnBoardingDocumentTemplateID, Title, [Description], DocumentTypeID, IsMandatory, SortOrder)
				VALUES(@templateId, @title, @description, @documentTypeId, @isMandatory, @sortOrder)
	END ELSE BEGIN
		UPDATE
			OnBoardingDocumentTemplateItems
		SET
			Title = @title,
			[Description] = @description,
			DocumentTypeId = @documentTypeId,
			IsMandatory = @isMandatory,
			SortOrder = @sortOrder
		WHERE
			ID = @id;
	END
END

