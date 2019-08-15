/****** Object:  Procedure [dbo].[uspGetEmployeeCommencementDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetEmployeeCommencementDate](@empId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @commencement DateTime;
	SELECT @commencement = commencement FROM Employee WHERE ID = @empId;
	SELECT @commencement as commencement
END

