/****** Object:  Procedure [dbo].[uspUpdateLoadingRate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdateLoadingRate] 
	-- Add the parameters for the stored procedure here
	@id int , 
	@code varchar (10),
	@description varchar(100),
	@value decimal (5,3),	
	@isNormalRate bit,
	@ReturnValue int output 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	update LoadingRate
	set Description= @description,
	Code=@code,	
	Value=@value,
	IsNormalRate= @isNormalRate
	where ID=@id
	IF @@error != 0
	BEGIN
		SET @ReturnValue =0
	
	END
	
	ELSE
	BEGIN
	
		SET @ReturnValue =@id 
	END
END
