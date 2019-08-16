/****** Object:  Procedure [dbo].[uspGetOnBoardingRecords]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingRecords](@search varchar(100), @division varchar(100), @department varchar(100), @positionId int, @typeId int, @statusId int, @showClosed bit)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
		r.*,
		p.title as position,
		p.orgunit1 as division,
		p.orgunit2 as department,
		t.[description] as onboardingtype,
		e.displayname as manager,
		0 as numberofcandidates,
		0 as numberofoffers
	FROM
		OnBoardingRecord r
	INNER JOIN
		Position p
	ON
		p.id = r.PositionID
	INNER JOIN
		Employee e
	ON
		e.ID = r.RequestingManagerEmpID
	INNER JOIN	
		OnBoardingType t
	ON
		t.id = r.OnBoardingTypeId
	WHERE
		(e.displayname like '%'+@search +'%' or p.title like '%'+@search +'%' or p.orgunit1 like '%'+@search +'%' or p.orgunit2 like '%'+@search +'%') 
		and
		(@department = '' or p.orgunit2 = @department)
		and
		(@division = '' or p.orgunit1 = @division)
		and
		(@positionId = 0 or p.id = @positionId)
		and
		(@typeId = 0 or t.id = @typeId)
END

