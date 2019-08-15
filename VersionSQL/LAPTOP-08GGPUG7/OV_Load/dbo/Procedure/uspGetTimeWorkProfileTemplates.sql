/****** Object:  Procedure [dbo].[uspGetTimeWorkProfileTemplates]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetTimeWorkProfileTemplates](@filter varchar(100), @filterDeleted bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM TimeWorkProfileTemplate WHERE [ShortDescription] LIKE '%' + @filter + '%' OR [description] LIKE '%' + @filter + '%'
	AND IsDeleted = @filterDeleted
	ORDER BY ShortDescription
END
