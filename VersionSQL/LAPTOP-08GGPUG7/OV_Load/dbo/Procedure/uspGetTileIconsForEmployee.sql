/****** Object:  Procedure [dbo].[uspGetTileIconsForEmployee]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetTileIconsForEmployee](@empId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select
		p.code,
		eg.name,
		'Employee Group/' + eg.icon as icon,
		CAST(replace(RIGHT(ap.value,LEN(ap.value)-CHARINDEX('.',ap.value)), 'Icon.Id=', '') as int)
	from
		applicationpreference ap
	inner join
		preference p
	on
		p.id = ap.preferenceid
	inner join
		EmployeeGroup eg
	on
		ap.value LIKE '%EmployeeGroup.Icon%' AND CAST(replace(RIGHT(ap.value,LEN(ap.value)-CHARINDEX('.',ap.value)), 'Icon.Id=', '') as int) = eg.ID
	where
		p.code in ('customicon1url', 'customicon2url', 'customicon3url', 'customicon4url', 'customicon5url') and
		@empId in (select employeeid from employeegroupemployee ege inner join employeegroup _eg on _eg.id = ege.employeegroupid where _eg.id = eg.ID)
END

