/****** Object:  Procedure [dbo].[uspAddUpdateOnBoardingDocumentTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateOnBoardingDocumentTemplate](@id int, @description varchar(100))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @id > 0 BEGIN
		UPDATE
			OnBoardingDocumentTemplate
		SET
			[Description] = @description
		WHERE
			id = @id;
		RETURN @id;
	END ELSE BEGIN
		INSERT INTO
			OnBoardingDocumentTemplate([Description])
				VALUES(@description)
		RETURN @@IDENTITY;
	END

	
END

