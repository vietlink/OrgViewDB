/****** Object:  Procedure [dbo].[uspRemoveOnBoardingDataEntryTemplateItemsNotInList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspRemoveOnBoardingDataEntryTemplateItemsNotInList](@currentIdList varchar(max), @templateId int)
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

	DELETE FROM OnBoardingDataEntryTemplateItems WHERE OnBoardingDataEntryTemplateID = @templateId AND ID NOT IN (SELECT * FROM @idTable)
END

