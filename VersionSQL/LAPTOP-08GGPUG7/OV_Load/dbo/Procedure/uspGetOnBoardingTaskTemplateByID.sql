/****** Object:  Procedure [dbo].[uspGetOnBoardingTaskTemplateByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetOnBoardingTaskTemplateByID](@id int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT obt.*, t.Description as OnBoardingType FROM 
		OnBoardingTaskTemplate obt 
	INNER JOIN
		OnBoardingTypes t
	ON
		t.ID = obt.OnBoardingTypeID
	WHERE obt.ID = @id
END

