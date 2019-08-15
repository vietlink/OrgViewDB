/****** Object:  Procedure [dbo].[uspGetEmployeeEntryGroupsNotInList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetEmployeeEntryGroupsNotInList](@currentIdList varchar(max))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @idTable TABLE(id int);
	IF CHARINDEX(',', @currentIdList, 0) > 0 BEGIN
		INSERT INTO @idTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS int) FROM fnSplitString(@currentIdList, ',');	
    END ELSE IF LEN(@currentIdList) > 0 BEGIN
		INSERT INTO @idTable SELECT CAST(@currentIdList AS int)
	END

	SELECT * FROM EmployeeEntryGroups WHERE ID NOT IN (SELECT id FROM @idTable)
END

