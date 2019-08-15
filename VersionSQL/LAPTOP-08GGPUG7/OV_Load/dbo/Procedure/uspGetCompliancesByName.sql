/****** Object:  Procedure [dbo].[uspGetCompliancesByName]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[uspGetCompliancesByName](@compliance varchar(max))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    SELECT c.*
	FROM Competencies c	
	WHERE c.[Type] = 2 AND c.Description= @compliance
END

