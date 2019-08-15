/****** Object:  Procedure [dbo].[uspRecalculateTransaction]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE uspRecalculateTransaction 
	-- Add the parameters for the stored procedure here
	@empID int, @dateFrom varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--print convert(datetime, @dateFrom, 105);
	declare @date datetime= convert(datetime, @dateFrom, 105);
	
    -- Insert statements for procedure here
	exec dbo.uspRegenAccrueData @date, @empId
	exec dbo.uspRegenAccrueDataByTimesheet @date, @empId

END
