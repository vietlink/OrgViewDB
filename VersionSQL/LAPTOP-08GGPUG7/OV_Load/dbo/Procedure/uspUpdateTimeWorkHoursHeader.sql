/****** Object:  Procedure [dbo].[uspUpdateTimeWorkHoursHeader]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdateTimeWorkHoursHeader](@id int, @weekPattern int, @extraHoursPayType int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @id > 0 BEGIN
		UPDATE
			TimeWorkHoursHeader
		SET
			weekPattern = @weekPattern,
			extraHoursPayType = @extraHoursPayType
		WHERE
			id = @id;
		RETURN @id;
	END ELSE BEGIN
		INSERT INTO TimeWorkHoursHeader(weekpattern, extrahourspaytype)
			VALUES(@weekPattern, @extraHoursPayType)
		RETURN @@IDENTITY;
	END
END

