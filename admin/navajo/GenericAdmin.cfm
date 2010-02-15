<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/navajo/GenericAdmin.cfm,v 1.26 2004/07/15 01:51:08 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:08 $
$Name: milestone_3-0-1 $

|| DESCRIPTION || 
$Description: calls generic admin for all types. $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: [url.typename]: object type $
--->

<!--- required variables --->
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<cfif not IsDefined("url.typename")>
	<cfoutput>
	#application.adminBundle[session.dmProfile.locale].errorMissingTypeName#
	</cfoutput>
	<cfabort>
</cfif>

<cfscript>
/*
 build stGrid for core content types
*/
	if (isDefined('URL.objectid'))
		form.objectid = url.objectid;	
	typename = "#URL.typeName#";
	stGrid = structNew();
	stGrid.typename = URL.typename;
	switch(typename)
	{
		case 'dmNews':
			permissionType = 'news';
			break;
		case 'dmEvent':
			permissionType = 'event';
			break;
		case 'dmLink':
			permissionType = 'link';
			break;	
		case 'dmFacts':
			permissionType = 'fact';
			break;	
		default:
			permissionType = 'news';
			break;
				
	}		
	stGrid.permissionType = permissionType;
	
	// check for edit permission
	oAuthorisation = request.dmSec.oAuthorisation;
	iObjectEditPermission = oAuthorisation.checkPermission(permissionName="#stGrid.permissionType#Edit",reference="PolicyGroup");		
	
	stGrid.finishURL = "#application.url.farcry#/navajo/GenericAdmin.cfm?type=#permissionType#&typename=#typename#"; //this is the url you will end back at after add/edit operations.
	//stGrid.approveURL = "#cgi.server_name#/farcry/index.cfm?section=Dynamic";
	
	stGrid.aTable = arrayNew(1);
	st = structNew();
	//select
	
	st.columnType = 'expression'; 
	st.heading = '#application.adminBundle[session.dmProfile.locale].select#';
	st.value = "<input type=""checkbox"" name=""objectid"" value=""##recordset.objectid##"">";
	st.align = 'center';
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].edit#';
	st.align = "center";
	st.columnType = 'eval'; 
	editobjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=##recordset.objectID[recordset.currentrow]##&type=#stGrid.typename#";	
	st.value = "iif(iObjectEditPermission eq 1,DE(iif(locked and lockedby neq '##session.dmSec.authentication.userlogin##_##session.dmSec.authentication.userDirectory##',DE('<span style=""color:red"">Locked</span>'),DE('<a href=''#editObjectURL#''><img src=""#application.url.farcry#/images/treeImages/edit.gif"" border=""0""></a>'))),DE('<img src=""#application.url.farcry#/images/treeImages/edit.gif"" border=""0"">'))";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].view#';
	st.align = "center";
	st.columnType = 'expression'; 
	st.value = "<a href=""#application.url.webroot#/index.cfm?objectID=##recordset.objectID##&flushcache=1"" target=""_blank""><img src=""#application.url.farcry#/images/treeImages/preview.gif"" border=""0""></a>";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].stats#';
	st.align = 'center';
	st.columnType = 'expression'; 
	st.value = "<a href=""javascript:void(0);"" onclick=""window.open('#application.url.farcry#/edittabStats.cfm?objectid=##recordset.objectid##','Stats','scrollbars,height=600,width=620');""><img src=""#application.url.farcry#/images/treeImages/stats.gif"" border=""0""></a>";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].label#';
	st.columnType = 'eval'; 
	editobjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=##recordset.objectID[recordset.currentrow]##&type=#stGrid.typename#";	
	st.value = "iif(iObjectEditPermission eq 1,DE(iif(locked and lockedby neq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#',DE('##replace(recordset.label[recordset.currentrow],'####','','all')##'),DE('<a href=''#editObjectURL#''>##replace(recordset.label[recordset.currentrow],'####','','all')##</a>'))),DE('##replace(recordset.label[recordset.currentrow],'####','','all')##'))";
	st.align = "left";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].status#';
	st.columnType = 'expression'; //this will default to objectid of row. 
	st.value = "##status##";
	st.align = "center";
	arrayAppend(stGrid.aTable,st);
		
	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].lastUpdated#';
	st.columnType = 'eval'; //this will default to objectid of row. 
	st.value = "application.thisCalendar.i18nDateFormat('##datetimelastupdated##',session.dmProfile.locale,application.mediumF)";
	arrayAppend(stGrid.aTable,st);
	
	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].by#';
	st.columnType = 'expression'; //this will default to objectid of row. 
	st.value = "##lastupdatedby##";
	st.align = 'center';
	arrayAppend(stGrid.aTable,st);
			
	if (typename IS 'dmnews')
	{
	st = structNew();
	st.heading = '#application.adminBundle[session.dmProfile.locale].publishDate#';
	st.columnType = 'eval'; //this will default to objectid of row. 
	st.value = "application.thisCalendar.i18nDateFormat('##publishdate##',session.dmProfile.locale,application.mediumF)";
	arrayAppend(stGrid.aTable,st);
	
	}
</cfscript>	

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<!--- javascript routines used to integrate global image and file libraries --->
<cfoutput>
<script>
if (parent.frames['treeFrame'].location.href.indexOf('dynamicMenuFrame.cfm') < 0)
{
	parent.frames['treeFrame'].location.href='#application.url.farcry#/dynamic/dynamicMenuFrame.cfm?type=general';
	em = parent.document.getElementById('subTabArea');
	for (var i = 0;i < em.childNodes.length;i++)
	{
		parent.document.getElementById(em.childNodes[i].id).style.display = 'inline';	
	}
	parent.document.getElementById('DynamicFileTab').style.display ='none';
	parent.document.getElementById('DynamicImageTab').style.display ='none';
}	
</script>
</cfoutput>

<farcry:genericAdmin 
	permissionType="#stGrid.permissionType#"
	typename="#typename#"
	stGrid="#stGrid#">

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="No">