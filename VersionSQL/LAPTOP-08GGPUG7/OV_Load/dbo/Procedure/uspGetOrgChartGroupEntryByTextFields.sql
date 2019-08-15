/****** Object:  Procedure [dbo].[uspGetOrgChartGroupEntryByTextFields]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOrgChartGroupEntryByTextFields](@description varchar(50), @code varchar(10), @excludeId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
		*
	FROM
		OrgChartEntryGroups WHERE ([Description] = @description OR Code = @code) AND id <> @excludeId
END

