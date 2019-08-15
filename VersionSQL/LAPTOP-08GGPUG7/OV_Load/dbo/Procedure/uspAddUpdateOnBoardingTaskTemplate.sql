/****** Object:  Procedure [dbo].[uspAddUpdateOnBoardingTaskTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateOnBoardingTaskTemplate](@id int, @description varchar(100), @typeId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @id > 0 BEGIN
		UPDATE
			OnBoardingTaskTemplate
		SET
			[Description] = @description,
			OnBoardingTypeID = @typeId
		WHERE
			id = @id;
		RETURN @id;
	END ELSE BEGIN
		INSERT INTO
			OnBoardingTaskTemplate([Description], OnBoardingTypeID)
				VALUES(@description, @typeId);
		RETURN @@IDENTITY;
	END

	
END

