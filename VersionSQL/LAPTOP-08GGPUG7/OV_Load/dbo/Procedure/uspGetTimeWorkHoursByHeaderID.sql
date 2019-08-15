/****** Object:  Procedure [dbo].[uspGetTimeWorkHoursByHeaderID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetTimeWorkHoursByHeaderID](@headerId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT twh.*, h.WeekPattern as HeaderWeekPattern, h.ExtraHoursPayType FROM TimeWorkHours twh
	INNER JOIN
	TimeWorkHoursHeader h ON twh.TimeWorkHoursHeaderID = h.ID
	WHERE TimeWorkHoursHeaderID = @headerId;
END

