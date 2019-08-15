/****** Object:  Procedure [dbo].[uspGetAddRates]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetAddRates](@rates varchar(1024))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @rateList TABLE(rate varchar(max));

	IF CHARINDEX(';', @rates, 0) > 0 BEGIN
		INSERT INTO @rateList-- split the text by , and store in temp table
		SELECT CAST(splitdata AS varchar) FROM fnSplitString(@rates, ';');	
    END
	ELSE BEGIN
		IF LEN(@rates) > 0
			INSERT INTO @rateList(rate) VALUES(@rates)
	END

	SELECT * FROM LoadingRate WHERE Value NOT IN (SELECT * FROM @rateList) AND IsNormalRate = 0 ORDER BY Value
END
