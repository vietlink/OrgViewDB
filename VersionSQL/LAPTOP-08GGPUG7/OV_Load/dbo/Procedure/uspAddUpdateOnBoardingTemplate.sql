/****** Object:  Procedure [dbo].[uspAddUpdateOnBoardingTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateOnBoardingTemplate](@id int, @description varchar(100), @typeId int, @html varchar(max))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @id > 0 BEGIN
		UPDATE
			OnBoardingTemplate
		SET
			[Description] = @description,
			OnBoardingTypeID = @typeId,
			[Html] = @html
		WHERE
			id = @id;
		RETURN @id;
	END ELSE BEGIN
		INSERT INTO
			OnBoardingTemplate([Description], [OnBoardingTypeID], [Html])
				VALUES(@description, @typeId, @html);
		RETURN @@IDENTITY;
	END

	
END
