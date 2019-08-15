/****** Object:  Procedure [dbo].[uspBulkSetCurrentPrimaryPosition]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspBulkSetCurrentPrimaryPosition](@idListEmp varchar(max))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @idTableEmp TABLE(rowNum int, id varchar(max));
	INSERT INTO @idTableEmp SELECT row_number() OVER (ORDER BY (SELECT 0)), splitdata FROM fnSplitString(@idListEmp, ',');

	DECLARE @empIdentifier varchar(255);

	DECLARE empScan CURSOR FOR
	SELECT id FROM @idTableEmp WHERE id <> '' and id is not null

	OPEN empScan;
	
	FETCH NEXT FROM empScan INTO @empIdentifier;

	WHILE @@FETCH_STATUS = 0 BEGIN
		DECLARE @empId int = 0;
		SELECT @empId = ID FROM Employee WHERE Identifier = @empIdentifier
		EXEC dbo.uspSetCurrentPrimaryPosition @empId, 1;
		FETCH NEXT FROM empScan INTO @empIdentifier;
	END

	CLOSE empScan;
	DEALLOCATE empScan;



END

