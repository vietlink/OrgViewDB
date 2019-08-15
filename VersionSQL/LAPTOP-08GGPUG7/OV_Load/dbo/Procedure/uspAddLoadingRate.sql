/****** Object:  Procedure [dbo].[uspAddLoadingRate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspAddLoadingRate] 
	-- Add the parameters for the stored procedure here
	 @code varchar(10), @description varchar(100), @value decimal (5,3), @status bit, @isNormalRate bit, @ReturnValue int output
	  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	if (@isNormalRate=1) BEGIN
		UPDATE LoadingRate
		SET IsNormalRate=0
	END
	if (@status=0) begin
		update LoadingRate
		set 				
		Description=@description,	
		IsDeleted=@status,
		IsNormalRate= @isNormalRate
		where Code= @code
		set @ReturnValue=1;
	end
	else begin	
		insert into LoadingRate(Code, Description, Value, IsDeleted, IsNormalRate)
		values
		(@code, 
		@description,
		@value,		
		0,
		@isNormalRate)			
		set @ReturnValue= @@IDENTITY
	end
END
