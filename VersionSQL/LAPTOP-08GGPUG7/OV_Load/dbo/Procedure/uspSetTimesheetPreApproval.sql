/****** Object:  Procedure [dbo].[uspSetTimesheetPreApproval]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspSetTimesheetPreApproval](@timesheetId int, @state bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE TimesheetHeader SET IsPreApproved = @state WHERE ID = @timesheetId;
END

