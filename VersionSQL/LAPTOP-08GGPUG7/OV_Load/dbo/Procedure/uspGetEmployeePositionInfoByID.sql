/****** Object:  Procedure [dbo].[uspGetEmployeePositionInfoByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspGetEmployeePositionInfoByID](@empPosId int, @loggedInPosID int, @userId int, @iAmManager bit, @hideByVisible int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @AvailMsgViewId int = dbo.fnGetAttributeIdByCode('availmessage-view');
	DECLARE @AvailMsgEditId int = dbo.fnGetAttributeIdByCode('availmessage-edit');

	SELECT 
	EP.[id],
	isnull(ep.[employeeid], 0) as employeeid,
	isnull(ep.[positionid], 0) as positionid,
	isnull(e.[displayname], '') as displayname,
	0 as employeeimageurlid,
	0 as positiontitleid,
	0 as customfield1id,
	'' as customfield1,
	'' as customfield1value,
	0 as customfield2id,
	'' as customfield2,
	'' as customfield2value,
	0 as customfield3id,
	'' as customfield3,
	'' as customfield3value,
	0 as customfield4id,
	'' as customfield4,
	'' as customfield4value,
	0 as customicon1id,
	'' as customicon1url,
	'' as customicon1tooltip,
	'' as customnavigate1url,
	0 as customicon2id,
	'' as customicon2url,
	'' as customicon2tooltip,
	'' as customnavigate2url,
	0 as customicon3id,
	'' as customicon3url,
	'' as customicon3tooltip,
	'' as customnavigate3url,
	0 as customicon4id,
	'' as customicon4url,
	'' as customicon4tooltip,
	'' as customnavigate4url,
	0 as customicon5id,
	'' as customicon5url,
	'' as customicon5tooltip,
	'' as customnavigate5url,
	0 as emailid,
	isnull(e.picture, '') as employeeimageurl,
	isnull(p.title, '') as positiontitle,
	isnull(e.[status], '') as [status],
	isnull(ec.workemail, '') as email,
	cast((case when ep.actualchildcount > 0 then 1 else 0 end) as bit) as haschildren,
	isnull(ep.[childcount], 0) as childcount,
	isnull(ep.[directheadcount], 0) as directheadcount,
	isnull(ep.[totalheadcount], 0) as [totalheadcount],
	0.0 as [directftecount],
	0.0 as [totalftecount],
	isnull(p.parentid, 0) as positionparentid,
	isnull(e.[availabilitymessage], '') as availabilitymessage,
	isnull(avs.icon, '') as availabilityiconurl,
	isnull(AvS.name, '') as availabilitystatus,
	isnull(ep.fte, 0.0) as fte,
	ep.[Managerial],
	ep.[primaryposition],
	ep.[ExclFromSubordCount],
	dbo.uspGetEmployeeStatusVisible(e.status, EP.Positionid, EP.id) as IsVisible,
	cast((case when p.IsAssistant = 'Y' then 1 else 0 end) as bit) as IsAssistant,
	1 AS PermAvailMsgView,
	0 AS PermAvailMsgEdit,
	/*dbo.fnCheckPermission(@loggedInPosID, @userId, @DocEmpViewId, ep.employeeid, ep.positionid, @iAmManager) */ 0 AS PermDocView,
	/*dbo.fnCheckPermission(@loggedInPosID, @userId, @CompetencyViewId, ep.employeeid, ep.positionid, @iAmManager) */ 0 AS PermCompetencyView,
	/*dbo.fnCheckPermission(@loggedInPosID, @userId, @ViewComplianceReportId, ep.employeeid, ep.positionid, @iAmManager) */ 0 AS PermComplianceReport,
	/*dbo.fnCheckPermission(@loggedInPosID, @userId, @ViewComplianceId, ep.employeeid, ep.positionid, @iAmManager) */ 0 AS PermCompliance,
	/*dbo.fnCheckPermission(@loggedInPosID, @userId, @ViewEmailId, ep.employeeid, ep.positionid, @iAmManager) */ 1 AS PermEmail,
	e.firstnamepreferred as preferredname,
	e.surname,
	e.[type],
	e.firstname,
	e.isplaceholder,
	e.isdeleted,
	ep.actualchildcount,
	ep.ExclFromSubordCount,
	ep.ActualTotalCount
	FROM 
		EmployeePosition ep
	INNER JOIN
		Position p
	ON
		p.id = ep.positionid
	INNER JOIN
		Employee e
	ON
		e.id = ep.employeeid
	LEFT OUTER JOIN
		EmployeeContact ec
	ON
		ec.EmployeeID = e.ID
	LEFT OUTER JOIN
		[Status] s
	ON
		s.Description = e.[status]
	LEFT OUTER JOIN 
		AvailabilityStatus AvS 
	on
		AvS.id = e.availabilitystatusid 
	WHERE
	ep.id = @empPosId AND-- AND e.IsDeleted = 0 AND p.IsDeleted = 0 AND _ep.IsDeleted = 0 AND
	((@hideByVisible = 1 AND dbo.uspGetEmployeeStatusVisible(e.status, EP.Positionid, EP.id) = 1) OR @hideByVisible = 0)
	END
