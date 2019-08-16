/****** Object:  Procedure [dbo].[uspGetOnBoardingRecordByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingRecordByID](@id int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
		r.*, p.title as position, e.displayname as employee
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
	WHERE
		r.ID = @id
END
