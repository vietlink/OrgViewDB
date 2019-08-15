/****** Object:  Procedure [dbo].[uspGetTopChartID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetTopChartID]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id int = 0;

	SELECT TOP 1
		@id = EP.ID
	FROM
		EmployeePosition EP
	INNER JOIN
		Position p
	ON
		p.ID = ep.PositionID
	WHERE
		ep.IsDeleted = 0 AND p.IsDeleted = 0 AND p.parentid IS NULL AND p.IsVisibleChart = 1 AND Identifier <> 'Vacant'
	ORDER BY Ep.ID asc

	IF ISNULL(@id, 0) < 1 BEGIN
		SELECT TOP 1
			@id = EP.ID
		FROM
			EmployeePosition EP
		INNER JOIN
			Position p
		ON
			p.ID = ep.PositionID
		WHERE
			ep.IsDeleted = 0 AND p.IsDeleted = 0 AND p.parentid IS NULL AND p.IsVisibleChart = 1
		ORDER BY Ep.ID asc
	END

	--SELECT TOP 1 @id = ID FROM EmployeePositionInfo WHERE positionparentid IS NULL AND IsVisible = 1 AND displayname <> 'Vacant';
	--IF ISNULL(@id, 0) < 1 BEGIN
	--	SELECT TOP 1 @id = ID FROM EmployeePositionInfo WHERE positionparentid IS NULL AND IsVisible = 1;
	--END

	SELECT ISNULL(@id, 0) AS ID
END
