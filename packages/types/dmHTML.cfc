<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmHTML.cfc,v 1.15 2003/09/25 00:14:40 brendan Exp $
$Author: brendan $
$Date: 2003/09/25 00:14:40 $
$Name: b201 $
$Revision: 1.15 $

|| DESCRIPTION || 
$Description: dmHTML Content Type. Forms the basis of the content framework of the site.  HTML objects include containers and static information. $
$TODO: <whatever todo's needed -- can be inline also>$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfcomponent extends="types" displayname="HTML Page" hint="Forms the basis of the content framework of the site.  HTML objects include containers and static information." bSchedule="1" bUseInTree="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="aObjectIDs" type="array" hint="Holds objects to be displayed at this particular node.  Can be of mixed types." required="no" default="">
<cfproperty name="aRelatedIDs" type="array" hint="Holds object pointers to related objects.  Can be of mixed types." required="no" default="">
<cfproperty name="Title" type="nstring" hint="Title of object.  *perhaps this should be deprecated for object label*" required="no" default="">
<cfproperty name="Teaser" type="longchar" hint="Teaser text." required="no" default="">
<cfproperty name="Body" type="longchar" hint="Main body of content." required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render this HTML object with." required="yes" default="display">
<cfproperty name="metaKeywords" type="nstring" hint="HTML head section metakeywords." required="no" default="">
<cfproperty name="extendedmetadata" type="longchar" hint="HTML head section for extended keywords." required="no" default="">
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default="">
<cfproperty name="versionID" type="uuid" hint="objectID of live object - used for versioning" required="no" default="">
<cfproperty name="teaserImage" type="string" hint="UUID of image to display in teaser" required="no" default="">
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">
<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmhtml/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmhtml/display.cfm">
</cffunction>
</cfcomponent>

