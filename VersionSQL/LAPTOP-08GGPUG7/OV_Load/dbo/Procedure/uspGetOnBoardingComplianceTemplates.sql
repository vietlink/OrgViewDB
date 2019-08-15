/****** Object:  Procedure [dbo].[uspGetOnBoardingComplianceTemplates]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingComplianceTemplates](@search varchar(100), @isDeleted bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM OnBoardingComplianceTemplate WHERE ([description] like '%'+@search +'%') AND IsDeleted = @isDeleted;
END

