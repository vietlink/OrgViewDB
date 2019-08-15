/****** Object:  Procedure [dbo].[uspGetOnBoardingDataEntryTemplateItems]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingDataEntryTemplateItems](@templateId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT e.[Description], i.* FROM OnBoardingDataEntryTemplateItems i
	INNER JOIN
	EmployeeEntryGroups e
	ON e.ID = i.employeeentrygroupid
	WHERE i.OnBoardingDataEntryTemplateID = @templateId ORDER BY i.SortOrder ASC
END

