/****** Object:  Procedure [dbo].[uspSearchPerson]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspSearchPerson](@search varchar(50))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT e.* FROM Employee e 
	INNER JOIN EmployeeWorkHoursHeader ewh
	ON ewh.ID = dbo.fnGetWorkHourHeaderIDByDay(e.ID, GETDATE()) AND ewh.EnableSwipeCard = 1
	WHERE e.IsDeleted = 0 AND ewh.EnableSwipeCard = 1 AND
	e.displayname LIKE '%' + @search + '%' OR e.firstname LIKE '%' + @search + '%' OR e.surname LIKE '%' + @search + '%' OR e.firstnamepreferred LIKE '%' + @search + '%'
END

