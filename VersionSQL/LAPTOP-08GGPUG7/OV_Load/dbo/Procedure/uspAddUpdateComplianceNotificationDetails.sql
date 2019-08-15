/****** Object:  Procedure [dbo].[uspAddUpdateComplianceNotificationDetails]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateComplianceNotificationDetails](@emailTo varchar(2000), @emailEmployeeExpired bit,
	@emailDue bit, @emailExpired bit, @emailAfter bit, @emailAfterDays int, @headerExpired varchar(2000), @checkNotificationDays int, @dueDays int, @headerDue varchar(2000), @headerExpireAfter varchar(2000),
	@headerEmpExpired varchar(2000), @headerEmpDue varchar(2000), @headerEmpExpireAfter varchar(2000), @emailEmployeeDue bit, @emailEmployeeExpireAfter bit, @emailMgrExpired bit,
	@headerMgrExpired varchar(2000), @emailMgrDue bit, @headerMgrDue varchar(2000), @emailMgrExpireAfter bit, @headerMgrExpireAfter varchar(2000), @defaultDueToExpireDays int, @fieldValueListID int,
	@locationLabel varchar(50), @locationDisplay bit, @personLabel varchar(50), @personDisplay bit, @notificationDaysEmp int, @notificationDaysMgr int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF NOT EXISTS (SELECT ID FROM ComplianceNotificationDetails) BEGIN
		INSERT INTO ComplianceNotificationDetails(emailTo, emailEmployeeExpired, emailDue, emailExpired, emailAfter, emailAfterDays, headerExpired, checkNotificationDays, dueDays, headerDue, headerExpireAfter, HeaderEmpExpired, HeaderEmpDue, HeaderEmpExpireAfter, EmailEmployeeDue, EmailEmployeeExpireAfter, 
		EmailMgrDue, HeaderMgrDue, EmailMgrExpireAfter, HeaderMgrExpireAfter, EmailMgrExpired, HeaderMgrExpired, DefaultDueToExpireDays, FieldValueListID, LocationLabel, LocationDisplay, PersonLabel, PersonDisplay, CheckNotificationDaysEmp, CheckNotificationDaysMgr)
			VALUES(@emailTo, @emailEmployeeExpired, @emailDue, @emailExpired, @emailAfter, @emailAfterDays, @headerexpired, @checkNotificationDays, @dueDays, @headerDue, @headerExpireAfter, @headerEmpExpired, @headerEmpDue, @headerEmpExpireAfter, @emailEmployeeDue, @emailEmployeeExpireAfter,
			@emailMgrDue, @headerMgrDue, @emailMgrExpireAfter, @headerMgrExpireAfter, @emailMgrExpired, @headerMgrExpired, @defaultDueToExpireDays, @fieldValueListID, @locationLabel, @locationDisplay, @personLabel, @personDisplay, @notificationDaysEmp, @notificationDaysMgr )
			END 
	ELSE BEGIN
		UPDATE
			ComplianceNotificationDetails
		SET
			emailTo = @emailTo,
			emailEmployeeExpired = @emailEmployeeExpired,
			emailDue = @emailDue,
			emailExpired = @emailExpired,
			emailAfter = @emailAfter,
			emailAfterDays = @emailAfterDays,
			headerexpired = @headerExpired,
			checkNotificationDays = @checkNotificationDays,
			dueDays = @dueDays,
			headerDue = @headerDue,
			headerExpireAfter = @headerExpireAfter,
			HeaderEmpExpired = @headerEmpExpired,
			HeaderEmpDue = @headerEmpDue,
			HeaderEmpExpireAfter = @headerEmpExpireAfter,
			EmailEmployeeDue = @emailEmployeeDue,
			EmailEmployeeExpireAfter = @emailEmployeeExpireAfter,
			EmailMgrDue= @emailMgrDue, HeaderMgrDue = @headerMgrDue,
			EmailMgrExpireAfter= @emailMgrExpireAfter, HeaderMgrExpireAfter= @headerMgrExpireAfter,
			EmailMgrExpired= @emailMgrExpired, HeaderMgrExpired= @headerMgrExpired,
			DefaultDueToExpireDays= @defaultDueToExpireDays, FieldValueListID= @fieldValueListID,
			LocationDisplay = @locationDisplay, LocationLabel= @locationLabel,
			PersonDisplay= @personDisplay, PersonLabel= @personLabel,
			CheckNotificationDaysEmp=@notificationDaysEmp, CheckNotificationDaysMgr= @notificationDaysMgr
	END
END
