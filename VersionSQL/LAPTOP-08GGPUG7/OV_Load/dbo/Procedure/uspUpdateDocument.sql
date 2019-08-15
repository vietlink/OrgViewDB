/****** Object:  Procedure [dbo].[uspUpdateDocument]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdateDocument](@id int, @storeName varchar(100), @size varchar(20), @pageType varchar(50), @CanEmpView bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE
		Documents
	SET
		StoreName = @storeName,
		Size = @size,
		
		PageType= @pageType,
		CanEmpView= @CanEmpView
	WHERE
		ID = @id

END

