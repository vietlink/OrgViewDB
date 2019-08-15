/****** Object:  Procedure [dbo].[uspGetOrgviewSearchResult]    Committed by VersionSQL https://www.versionsql.com ******/

/*OrgView1.1 Script Changes*/
/*OrgView1.1 Script Changes*/
CREATE PROCEDURE [dbo].[uspGetOrgviewSearchResult](@Name varchar(100),@Positiontitle varchar(100),@NOTFLag int,@EmployeeGroupId int,@Condition nvarchar(4000), @loggedInPosID int, @userId int, @iAmManager bit, @locationList varchar(max), @showPrimary bit, @showSecondary bit)                                    
AS                                    
BEGIN                                    
                
DECLARE @POSFound int                        
DECLARE @SQL nvarchar(MAX)                  
                        
DECLARE @WHERESQL nvarchar(max)                          
SET @WHERESQL=''                
SET @POSFound =0                        
                        
DECLARE @SortOrderFields nvarchar(1000)                           
declare @sortorderColumns nvarchar(1000)                          
DECLARE @SortOrder nvarchar(100)                                    
CREATE TABLE #Temp1(sortname varchar(100),columnname varchar(100))                                
DECLARE @SEP varchar(1)                              
SET @SEP =','                            
DECLARE @SP INT                           
DECLARE @SP1 INT                              
DECLARE @VALUE varchar(100)                           
DECLARE @VALUE1 varchar(100)       
DECLARE @ViewEmailId int = dbo.fnGetAttributeIdByCode('workemail');      
DECLARE @AvailMsgViewId int = dbo.fnGetAttributeIdByCode('availmessage-view');
              
SET @sortorderColumns ='e.displayname,p.title'                              
SET @POSFound =(select count(Id) from Position where title =  @Positiontitle)                
if(@POSFound is null)                
 SET @POSFound =0                
SET @SQL ='SELECT  distinct ep.[id], 
E.Surname as EmpSurname,                             
 EP.[employeeid],                                         
 EP.[positionid],                                         
 0 as[displaynameid],                                        
 E.[displayname],                                      
 E.picture,                                          
 0 as [employeeimageurlid],                                         
 E.picture as [employeeimageurl],                                         
 0 as [positiontitleid],                                         
 p.title as [positiontitle],                                         
 0 as customfield1id,                                         
 '''' as [customfield1],                                         
 '''' as customfield1value,
 '''' as  DisplaynameLongname,
 '''' as PositionTitleLongname,
 '''' as CustomField1Columnname,            
 '''' as CustomField2Columnname,            
 '''' as CustomField3Columnname,            
 '''' as CustomField4Columnname,            
 0 as customfield2id,                                         
 '''' as [customfield2],                                         
 '''' as customfield2value,
 0 as customfield3id,                                         
 '''' as [customfield3],                                         
 '''' as customfield3value,
 '''' as [customfield4],                                         
 0 as customfield4id,                                         
 '''' as customfield4value,
 0 as customicon1id,                                         
 '''' as [customicon1url],                                         
 '''' as [customicon1tooltip],                                         
 '''' as [customnavigate1url],                                         
 0 as customicon2id,                                         
 '''' as [customicon2url],                                         
 '''' as [customicon2tooltip],                                         
 '''' as [customnavigate2url],                                         
 0 as customicon3id,                                         
 '''' as [customicon3url],                                         
 '''' as [customicon3tooltip],                                         
 '''' as [customnavigate3url],                                         
 0 as customicon4id,               
 '''' as [customicon4url],                                         
 '''' as [customicon4tooltip],                                         
 '''' as [customnavigate4url],                          
 0 as customicon5id,                                         
 '''' as [customicon5url],                    
 '''' as [customicon5tooltip],                                         
 '''' as [customnavigate5url],                                         
 0 as [emailid],                                         
 ec.workemail as Email,                                       
 cast(0 as bit) as [haschildren],                                         
 isnull(EP.[childcount], 0) as [childcount],                                         
 isnull(EP.[directheadcount], 0) as directheadcount,                                      
 isnull(EP.[totalheadcount], 0) as [totalheadcount],                                      
 0.0 as [directftecount],                                      
 0.0 as [totalftecount],                     
 p.parentid as [positionparentid],  
 dbo.uspGetEmployeeStatusVisible(e.status, EP.Positionid, EP.id) as IsVisible,    
 e.isplaceholder,                                    
 e.availabilitymessage as availabilitymessage,                                         
 avs.icon as [availabilityiconurl],                            
 avs.name as availabilitystatus,
 1 as emailpermission'
            
if(@EmployeeGroupId >=0)                
 SET @SQL=@SQL+', EG.Name as EmpGroupname,isnull(EG.icon,'''') as EmpGroupIcon FROM EmployeePosition EP INNER JOIN Employee E on E.id =EP.employeeid INNER JOIN Position P on P.Id=EP.PositionId LEFT OUTER JOIN EmployeeContact EC on EC.Employeeid=E.Id LEFT OUTER JOIN AvailabilityStatus AvS on AvS.id=e.availabilitystatusid'            
  
   
     
else            
 SET @SQL=@SQL+' ,'''' as EmpGroupname,'''' as  EmpGroupIcon FROM EmployeePosition EP INNER JOIN Employee E on E.id =EP.employeeid INNER JOIN Position P on P.Id=EP.PositionId LEFT OUTER JOIN EmployeeContact EC on EC.Employeeid=E.Id LEFT OUTER JOIN AvailabilityStatus AvS on AvS.id=e.availabilitystatusid'               
 
             
                                   
                
                
if(@EmployeeGroupId > 0)                      
BEGIN                 
                 
 SET @SQL=@SQL+' INNER JOIN EmployeeGroupEmployee EGE on EGE.employeeid=E.Id INNER JOIN EmployeeGroup EG on EG.id=EGE.EmployeeGroupId and EGE.employeegroupid='+Convert(varchar,@EmployeeGroupId) +''                      
END                 
ELSE if(@EmployeeGroupId = 0)                   
              
BEGIN                
 SET @SQL=@SQL+'  INNER JOIN EmployeeGroupEmployee EGE on EGE.employeeid=E.Id LEFT OUTER JOIN EmployeeGroup EG on EG.id=EGE.EmployeeGroupId'                
                                 
END                     
                      
--PRINT @SQL                      
                      
                      
if(@Name <> '')                        
BEGIN                        
                         
 SET @WHERESQL ='(E.firstname like ''%'+@Name +'%'' OR E.surname like ''%'+@Name +'%'' OR E.firstnamepreferred like ''%'+@Name +'%'' OR E.displayname like ''%'+@Name +'%'' )'                        
END                        
if(@Positiontitle <> '')                        
BEGIN                        
PRINT @WHERESQL                        
                        
 if(@WHERESQL ='')                        
 BEGIN                 
                        
   if(@NOTFLag=1)                
   BEGIN                 
  if(@POSFound <>0)                              
   SET @WHERESQL =@WHERESQL + ' (P.title <> '''+@Positiontitle +''' AND p.description <> ''' + @Positiontitle + ''')'                   
  else                
   SET @WHERESQL =@WHERESQL + ' (P.title not like ''%'+@Positiontitle +'%'' AND P.description not like ''%' + @Positiontitle + '%'')'                     
   END                
   else                
   BEGIN                 
  if(@POSFound <>0)                         
   SET @WHERESQL =@WHERESQL + ' (P.title ='''+@Positiontitle +''' OR P.description = ''' + @Positiontitle + ''')'                        
  else                
   SET @WHERESQL =@WHERESQL + ' (P.title like ''%'+@Positiontitle +'%'' OR P.description like ''%' +  @Positiontitle + '%'')'                 
   END                
                          
 END                        
 else                        
 BEGIN                        
  if(@NOTFLag=1)                  
   BEGIN                 
 if(@POSFound <>0)                        
  SET @WHERESQL =@WHERESQL + ' AND (P.title <> '''+@Positiontitle +''' AND p.description <> ''' + @Positiontitle + ''')'                
 else                
  SET @WHERESQL =@WHERESQL + ' AND (P.title not like ''%'+@Positiontitle +'%'' AND p.description not like ''%' + @Positiontitle + '%'')'                  
  END           
  else                 
  BEGIN                
  if(@POSFound <>0)                         
  SET @WHERESQL =@WHERESQL + ' AND (P.title = '''+@Positiontitle +''' OR P.description = ''' + @Positiontitle + ''')'                
  else                
  SET @WHERESQL =@WHERESQL + ' AND (P.title like ''%'+@Positiontitle +'%'' OR P.description like ''%' + @Positiontitle + '%'')'                     
  END                      
 END                        
                         
END                   
          
if(@Condition <> '')                    
BEGIN                  
--	SET @SQL =@SQL + ' LEFT OUTER JOIN EmployeeContact EC on EC.Employeeid=E.Id '    
	IF(@WHERESQL = '')
		SET @WHERESQL =@WHERESQL + @Condition                        
	ELSE
		SET @WHERESQL =@WHERESQL + ' AND ' + @Condition  
END

IF(@locationList <> '')
BEGIN
	IF(@WHERESQL <> '') BEGIN
	SET @WHERESQL = @WHERESQL + ' AND (case when e.location is null or e.location = '''' then ''(Blank)'' else e.location end) IN (' + @locationList + ')';
	END
	ELSE
	SET @WHERESQL = @WHERESQL + ' (case when e.location is null or e.location = '''' then ''(Blank)'' else e.location end) IN (' + @locationList + ')';
END 

IF @showPrimary = 1 AND @showSecondary = 0 BEGIN
	IF(@WHERESQL <> '') 
		SET @WHERESQL = @WHERESQL + ' AND';
	SET @WHERESQL = @WHERESQL + ' ep.primaryposition=''Y'' ';
END
IF @showPrimary = 0 AND @showSecondary = 1 BEGIN
	IF(@WHERESQL <> '') 
		SET @WHERESQL = @WHERESQL + ' AND';
	SET @WHERESQL = @WHERESQL + ' ep.primaryposition=''N'' ';                    
END
                        
IF(@WHERESQL <> '')          
 SET @SQL =@SQL +' WHERE (ep.IsDeleted = 0 AND p.IsDeleted = 0 AND e.IsDeleted = 0) AND ' +@WHERESQL     
ELSE
 SET @SQL = @SQL + ' WHERE (ep.IsDeleted = 0 AND p.IsDeleted = 0 AND e.IsDeleted = 0)'
     exec dbo.longprint @sql   
	
EXECUTE sp_executesql @SQL              
                          
                                  
END 
----------
