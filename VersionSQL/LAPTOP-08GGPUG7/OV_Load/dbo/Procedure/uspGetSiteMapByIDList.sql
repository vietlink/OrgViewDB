/****** Object:  Procedure [dbo].[uspGetSiteMapByIDList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetSiteMapByIDList](@idList varchar(max))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @idTable TABLE(id int);

	IF CHARINDEX(',', @idList, 0) > 0 BEGIN
		INSERT INTO @idTable -- split the text by , and store in temp table
		SELECT CAST(splitdata AS int) FROM fnSplitString(@idList, ',');
    END
    ELSE IF LEN(@idList) > 0 BEGIN -- if text existst without a , then assume 1 id
		INSERT INTO @idTable(id) VALUES(CAST(@idList AS int));
    END

	SELECT
		ep.id,
		e.displayname,
		e.picture as employeeimageurl,
		ep.positionid,
		ep.employeeid
	FROM
		EmployeePosition ep
	INNER JOIN
		@idTable idt
	ON
		idt.id = ep.id
	INNER JOIN
		Employee e
	ON
		e.ID = ep.EmployeeID
END
