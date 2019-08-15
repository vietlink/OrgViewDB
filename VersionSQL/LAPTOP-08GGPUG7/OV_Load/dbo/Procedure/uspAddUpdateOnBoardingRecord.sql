/****** Object:  Procedure [dbo].[uspAddUpdateOnBoardingRecord]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspAddUpdateOnBoardingRecord](@id int, @reference varchar(100), @positionId int, @onBoardingTypeId int, @plannedDate datetime, @requestingManagerEmpId int, @offerTemplateId int, @acceptanceTemplateId int, @onBoardingTaskTemplateId int, @onBoardingDocumentTemplateId int, @onBoardingComplianceTemplateId int, @onBoardingDataEntryTemplateId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @id = 0 BEGIN
		INSERT INTO 
			OnBoardingRecord(reference, positionid, onBoardingTypeId , plannedDate, requestingManagerEmpId, offerTemplateId, acceptanceTemplateId, onBoardingTaskTemplateId, onBoardingDocumentTemplateId, onBoardingComplianceTemplateId, onBoardingDataEntryTemplateId)
				VALUES(@reference, @positionid, @onBoardingTypeId , @plannedDate, @requestingManagerEmpId, @offerTemplateId, @acceptanceTemplateId, @onBoardingTaskTemplateId, @onBoardingDocumentTemplateId, @onBoardingComplianceTemplateId, @onBoardingDataEntryTemplateId)
	END ELSE BEGIN
		UPDATE
			OnBoardingRecord
		SET
			reference = @reference,
			positionid = @positionid,
			onBoardingTypeId = @onBoardingTypeId,
			plannedDate = @plannedDate,
			requestingManagerEmpId = @requestingManagerEmpId,
			offerTemplateId = @offerTemplateId,
			acceptanceTemplateId = @acceptanceTemplateId,
			onBoardingTaskTemplateId = @onBoardingTaskTemplateId,
			onBoardingDocumentTemplateId = @onBoardingDocumentTemplateId,
			onBoardingComplianceTemplateId = @onBoardingComplianceTemplateId,
			onBoardingDataEntryTemplateId = @onBoardingDataEntryTemplateId
		WHERE
			ID = @id;
	END
END

