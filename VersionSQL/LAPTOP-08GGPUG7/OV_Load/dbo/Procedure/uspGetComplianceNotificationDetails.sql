/****** Object:  Procedure [dbo].[uspGetComplianceNotificationDetails]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetComplianceNotificationDetails]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT c.id, c.EmailTo, c.EmailDue, c.EmailExpired, c.EmailAfter, c.EmailAfterDays, c.CheckNotificationDays, c.DueDays, 
	c.HeaderDue, c.HeaderExpired, c.HeaderExpireAfter, c.HeaderEmpDue, c.HeaderEmpExpired, c.HeaderEmpExpireAfter, c.EmailEmployeeDue, c.EmailEmployeeExpireAfter, c.EmailEmployeeExpired,
	c.HeaderMgrDue, c.HeaderMgrExpireAfter, c.HeaderMgrExpired, c.EmailMgrDue, c.EmailMgrExpireAfter, c.EmailMgrExpired, isnull(c.FieldValueListID,0) as FieldValueListID,
	c.LocationLabel, c.LocationDisplay, c.PersonDisplay, c.PersonLabel, c.CheckNotificationDays, c.CheckNotificationDaysEmp, c.CheckNotificationDaysMgr, c.LastSentDate, c.LastSentDateEmp, c.LastSentDateMgr, c.DefaultDueToExpireDays 
	FROM ComplianceNotificationDetails c;
END

