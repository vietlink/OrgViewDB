/****** Object:  Procedure [dbo].[uspAddUpdateOnBoardingDataEntryTemplateItem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateOnBoardingDataEntryTemplateItem](@id int, @templateId int, @employeeDataEntryId int, @sortOrder int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    IF @id = 0 BEGIN
		INSERT INTO 
			OnBoardingDataEntryTemplateItems(OnBoardingDataEntryTemplateID, EmployeeEntryGroupID, SortOrder)
				VALUES(@templateId, @employeeDataEntryId, @sortOrder)
	END ELSE BEGIN
		UPDATE
			OnBoardingDataEntryTemplateItems
		SET
			EmployeeEntryGroupID = @employeeDataEntryId,
			SortOrder = @sortOrder
		WHERE
			ID = @id;
	END
END

