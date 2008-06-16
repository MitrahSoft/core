<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/Attic/rebuildFU.cfm,v 1.1.2.3 2006/01/23 22:28:00 geoff Exp $
$Author: geoff $
$Date: 2006/01/23 22:28:00 $
$Name: milestone_3-0-1 $
$Revision: 1.1.2.3 $

|| DESCRIPTION || 
$Description: $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$

|| ATTRIBUTES ||
$in: attribute -- description $
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />


<!--- environment variables --->
<cfparam name="form.bFormSubmitted" default="false">
<cfparam name="form.content_types" default="">
<cfparam name="successmessage" default="">
<cfparam name="errormessage" default="">

<sec:CheckPermission error="true" permission="AdminGeneralTab">
	<!--- ENGAGE: make it happen --->
	<cfif form.bFormSubmitted EQ "true">
		<cfloop index="currentType" list="#content_types#">
			<cfset objType = CreateObject("component", application.types[currentType].typepath)>
			<cfset returnstruct = objType.fRebuildFriendlyURLs(currentType)>
			<cfif returnstruct.bSuccess>
				<cfset successmessage = successmessage & returnstruct.message>
			<cfelse>
				<cfset errormessage = errormessage & returnstruct.message>
			</cfif>
		</cfloop>
		<cfset createObject("component","#application.packagepath#.farcry.fu").refreshApplicationScope() />
	</cfif>
	
	<!--- build an array of content types that have friendly URLs enabled --->
	<cfset aFUTypes = ArrayNew(1)>
	<cfloop item="currentType" collection="#application.types#">
		<cfif structKeyExists(application.types[currentType],"bFriendly") AND application.types[currentType].bFriendly>
			<cfset ArrayAppend(aFUTypes,currentType)>
		</cfif>
	</cfloop>
	
	<!--- JS library for select toggles --->
	<cfsavecontent variable="jsContent">
	<cfoutput>
	<script type="text/javascript">
	function fSelectSelection(selectionType){
		aCheckBoxes = document.frm.content_types;
		if(selectionType == "all"){
			for(i=0;i<aCheckBoxes.length;i++)
				aCheckBoxes[i].checked = true;
		}
		else if (selectionType == "none"){
			for(i=0;i<aCheckBoxes.length;i++)
				aCheckBoxes[i].checked = false;
		}
		else{
			for(i=0;i<aCheckBoxes.length;i++)
				aCheckBoxes[i].checked = !aCheckBoxes[i].checked;
		}
		return false;
	}
	</script>
	</cfoutput>
	</cfsavecontent>
	
	<!--- set up page header --->
	<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
	<cfhtmlHead text="#jsContent#">
	
	<cfoutput>
		<cfif successmessage NEQ ""><p class="success">#successmessage#</p></cfif>
		<cfif errormessage NEQ ""><p class="error">#errormessage#</p></cfif>
		
		<form name="frm" id="frm" action="#cgi.script_name#" method="post" class="f-wrap-1 f-bg-long">
			<h3>Rebuild Friendly URLs</h3>
	
			<a href="##" onclick="return fSelectSelection('all');">[SELECT ALL]</a> 
			<a href="##" onclick="return fSelectSelection('none');">[DESELECT ALL]</a> 
			<a href="##" onclick="return fSelectSelection('inverse');">[INVERSE SELECTION]</a>
	
			<div class="imageWrap">
				<ul><cfloop index="i" from="1" to="#ArrayLen(aFUTypes)#">
					<li><label for="content_types_#i#"><input type="checkbox" name="content_types" id="content_types_#i#" value="#aFUTypes[i]#">#aFUTypes[i]#</label></li></cfloop>
				</ul>
			</div>
	
			<input type="submit" name="buttonSubmit" value="Rebuild">
			<input type="hidden" name="bFormSubmitted" value="yes">
		</form>
	</cfoutput>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">
