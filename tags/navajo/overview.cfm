<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/overview.cfm,v 1.77 2003/11/01 09:07:42 paul Exp $
$Author: paul $
$Date: 2003/11/01 09:07:42 $
$Name: b201 $
$Revision: 1.77 $

|| DESCRIPTION || 
$Description: Javascript tree$
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$
$Developer: Matt Dawson (mad@daemon.com.au)$
$Developer: Brendan Sisson (brendan@daemon.com.au)$


|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="No">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<cfparam name="attributes.zoom" default="16">
<cfparam name="attributes.nodetype" default="dmNavigation"> <!--- Allows you to have tree of diffenent 'typenames' - useful if you want full site tree functionality, but for other applications such as document management perhaps --->
<cfif isDefined("url.zoom")><cfset attributes.zoom=url.zoom></cfif>
<cfset fontZoom = int(attributes.zoom/16*9)>
<cfset menuZoom = int(attributes.zoom/16*120)>
<cfparam name="application.navid.rubbish" default="">
<cfparam name="attributes.lCreateObjects" default="ALL"><!--- This is a list of typenames that you want to restrict to being created in the tree --->


<cfscript>
	//default overivew params structure for further flexibility when using tree functionality with apps other than the 'site overview' - this has no effect as yet	
	stOverview = structNew();
	st = stOverview;
	st.popupmenu.URL.createObject = '#application.url.farcry#/navajo/createObject.cfm';
	st.popupmenu.URL.deleteObject = '#application.url.farcry#/navajo/delete.cfm';
</cfscript>
<cfparam name="attributes.stOverview" default="#stOverview#">

<cfscript>
	function buildTreeCreateTypes(a,lTypes)
	{
		
		aTypes = listToArray(lTypes);
		
		//build core types first
		for(i=1;i LTE arrayLen(aTypes);i = i+1)
		{		
			if (structKeyExists(application.types[aTypes[i]],'bUseInTree') AND application.types[aTypes[i]].bUseInTree AND NOT application.types[aTypes[i]].bcustomType)
			{	stType = structNew();
				stType.typename = aTypes[i];
				if (structKeyExists(application.types[aTypes[i]],'displayname'))   //displayname *seemed* most appropriate without adding new metadata
					stType.description = application.types[aTypes[i]].displayName;
				else
					stType.description = aTypes[i];
				arrayAppend(a,stType);
			}	
		}	
		//now custom types
		for(i=1;i LTE arrayLen(aTypes);i = i+1)
		{		
			if (structKeyExists(application.types[aTypes[i]],'bUseInTree') AND application.types[aTypes[i]].bUseInTree AND application.types[aTypes[i]].bcustomType)
			{	stType = structNew();
				stType.typename = aTypes[i];
				if (structKeyExists(application.types[aTypes[i]],'displayname'))   //displayname *seemed* most appropriate without adding new metadata
					stType.description = application.types[aTypes[i]].displayName;
				else
					stType.description = aTypes[i];
				arrayAppend(a,stType);
			}	
		}	
		
		return a;
	}
	
	aTypesUseInTree = arrayNew(1);
	if(attributes.lCreateObjects is 'ALL')
	{
		lPreferredTypeSeq = '#attributes.nodetype#,dmHTML'; // this list will determine preffered order of objects in create menu - maybe this should be configurable.
		aTypesUseInTree = buildTreeCreateTypes(aTypesUseInTree,lPreferredTypeSeq); 
		lAllTypes = structKeyList(application.types);
		//remove preffered types from *all* list
		aPreferredTypeSeq = listToArray(lPreferredTypeSeq);
		for (i=1;i LTE arrayLen(aPreferredTypeSeq);i=i+1)
		{
			listDeleteAt(lAllTypes,listFindNoCase(lAllTypes,aPreferredTypeSeq[i]));
		}
		aTypesUseInTree = buildTreeCreateTypes(aTypesUseInTree,lAllTypes); 
	}else
		aTypesUseInTree =buildTreeCreateTypes(aTypesUseInTree,attributes.lCreateObjects); 
	//dump(aTypesUseInTree);
		
	
	stTypes = duplicate(application.stTypes);
	PermNavCreate    = application.permission.dmnavigation.Create.permissionId;
	PermNavEdit   = application.permission.dmnavigation.Edit.permissionId;
	PermNavView  = application.permission.dmnavigation.View.permissionId;
	PermNavDelete  = application.permission.dmnavigation.Delete.permissionId;
	PermNavApprove = application.permission.dmnavigation.Approve.permissionId;
	PermNavRequestApprove = application.permission.dmnavigation.RequestApproval.permissionId;
	PermContainerManagement = application.permission.dmnavigation.ContainerManagement.permissionId;
	PermSendToTrash = application.permission.dmnavigation.sendToTrash.permissionId;

	//Permissions
	oAuthorisation = request.dmsec.oAuthorisation;
	iSecurityManagementState = oAuthorisation.checkPermission(permissionName="SecurityManagement",reference="PolicyGroup");	
	iRootNodeManagement = oAuthorisation.checkPermission(permissionName="RootNodeManagement",reference="PolicyGroup");	
	iModifyPermissionsState = oAuthorisation.checkPermission(permissionName="ModifyPermissions",reference="PolicyGroup");	
	iDeveloperState = oAuthorisation.checkPermission(permissionName="developer",reference="PolicyGroup");	
	bPermTrash = oAuthorisation.checkInheritedPermission(permissionName="create",objectid="#application.navid.rubbish#");	
	
	menuOnColor="##dddddd";
	menuOffColor="white";
	menuFlutterOnColor="black";
	menuFlutterOffColor="##cccccc";
	smallPopupFeatures="width=200,height=200,menubar=no,toolbars=no,";
	customIcons = attributes.customIcons;

</cfscript>

<cfoutput>

<script>
	//parent.document.getElementById('siteEditEdit').style.display = 'none';
	var ns6=document.getElementById&&!document.all; //test for ns6
	var ie5=document.getElementById && document.all;//test for ie5

	// serverGet() function when it's done
	function serverPut(objID){
		// the URL of the script on the server to run
		strURL = "#application.url.farcry#/navajo/updateTreeData.cfm";
		// if you need to pass any variables to the script, 
		// then populate the following string with a valid query string	
		strQueryString = "lObjectIds=" + objID + "&" + Math.random();
	
		// this will append a random number to the URL string that will 
		// ensure the document isn't cached
		//strURL = strURL + "/" + Math.random();
		// if the query string variable isn't blank, then append it to the URL
		if( strQueryString.length > 0 ){
			strURL = strURL + "?" + strQueryString;
		}
		
		// if IE then change the location of the IFRAME 
		if( document.all ){
			// this loads the URL stored in the strURL variable into the 
			// hidden frame
			document.idServer.location = strURL;
	
		// otherwise, change Netscape v6's IFRAME source file
		} else if( document.getElementById ){
			// this loads the URL stored in the strURL variable into the hidden frame
			document.getElementById("idServer").contentDocument.location = strURL;

		// otherwise, change Netscape v4's ILAYER source file
		} else if( document.layers ){
			// this loads the URL stored in the strURL variable into the 
			// hidden frame
			document.idServer.src = strURL;
		}
	
		return true;
	}

	var objects = new Object();
	var _tl0 = objects;

</script>
</cfoutput>
<cfparam name="application.navid.root" default="">

<!--- find all the root nodes --->

<cfscript>
if (isDefined("URL.rootObjectID"))
	rootObjectID = URL.rootObjectID;
else
{
	qRoot = application.factory.oTree.getRootNode(typename=attributes.nodetype);
	rootobjectid = qRoot.objectid;
}

if(not isDefined("url.insertonly"))
{
	if (NOT rootobjectid IS application.navid.root AND len(application.navid.root) EQ 35)
	{
		qParent = application.factory.oTree.getParentID(objectid=rootobjectid,dsn=application.dsn);	
		upOneRootobjectid = qParent.parentid;
		if (NOT upOneRootobjectid IS rootobjectid AND iRootNodeManagement EQ 1)
			writeoutput("<div style=""float:right""><a href=""#cgi.script_name#?rootobjectid=#upOneRootobjectid#""><img alt='Up one level' src=""#application.url.farcry#/images/treeImages/uponefolder.gif"" border=""0""></a></div>");	
		
	}
}	
</cfscript>

<!--- get all open nodes + root nodes --->
<cfparam name="cookie.nodestatev2" default="">
<cfset cookie.nodestatev2=listappend(cookie.nodestatev2,"0")>
<nj:treeData
	nodetype="#attributes.nodetype#"
	lObjectIds="#rootObjectID#"
	typename="#attributes.nodetype#"
	get="Children"
	topLevelVariable="objects"
	lStripFields="displayMethod,objecthistory,teaser,body,PATH,commentlog"
	r_javascript="jscode">
	

<cfset imageRoot = "nimages">
<cfset customIcons = attributes.customIcons>

<cfquery name="q" datasource="#application.dsn#">
	SELECT permissionID FROM dmPermission WHERE permissionType = 'dmNavigation'
</cfquery>

<!-------- PERMISSIONS ------------>
<cfoutput>
	<script>
		var aPerms = new Array();
		<cfloop query="q">
		aPerms[#q.currentrow#] = #q.permissionid#;
		</cfloop>
		// permissions objects
		p=new Object();
		
		function hasPermission( id, pid )
		{	var permission = 0;
			var thisPerm = 0;
			var oid=id;
			
			while(permission==0)
			{	
				if( typeof(p[id])=='undefined' || typeof(p[id][pid])=='undefined' ) thisPerm=0; else thisPerm=p[id][pid];
				if( permission==0 && thisPerm != 0) permission=thisPerm;
				if( permission==-1 && thisPerm ==1 ) permission=1;
				
				if( getParentObject(id) != 0 ) id = getParentObject(id)['OBJECTID']; else break;
			}
			
			return permission;
		}
		//this is preparing for the ability to hode nodes that user doesn't have permission to edit
		function hideNode(id)
		{
			
			var permission = 0;
			var thisPerm = 0;
			var oid=id;
			//alert(aPerms.length);
			for (var i = 1;i < aPerms.length;i++)
			{   pid = aPerms[i];
				while(permission==0)
				{	
					if( typeof(p[id])=='undefined' || typeof(p[id][pid])=='undefined' ) thisPerm=0; else thisPerm=p[id][pid];
					if( permission==0 && thisPerm != 0) permission=thisPerm;
					if( permission==-1 && thisPerm ==1 ) permission=1;
				
					if( getParentObject(id) != 0 ) id = getParentObject(id)['OBJECTID']; else break;
				}
				if (permission > -1)
					break;
			}
			//alert(id);alert(permission);
			return permission;
			
		}	
	
		
	</script>
</cfoutput>

<cfscript>
	nimages = "#application.url.farcry#/images/treeImages";
	cimages = "#nimages#/customIcons";
</cfscript>

<cfoutput>
<!--- initial javascript code for tree --->
<script>#jscode#</script>

<div id="popupMenus"></div>

<script>
var localWin = window;
var editFlag = false;

function popupopen( strURL,b,c )
{
	
	if( document.all )
		document.idServer.location = strURL;
	else if( document.getElementById )
		document.getElementById("idServer").contentDocument.location = strURL;
	
}

function frameopen( a,b )
{
	if( parent[b] && !heldEvent.ctrlKey )
	{
		if( b == 'editFrame' && parent[b].location.href.toLowerCase().indexOf( "edit.cfm" ) != -1 )
		{
			alert("You are currently editing an object.\nPlease complete or cancel editing before doing anything else.\n" );
		}
		else
		{
			
			parent[b].document.location=a;
		}
	}
	else popupopen( a,b+"_popup" );
}

var cookieName = "nodeStatev2=";
var rootIds = '#rootObjectId#';

var lastSelectedId = '';
var aSelectedIds = new Array();
var zoom=#attributes.zoom#;


//pre load images
//pre load images
toggleUpEmpty = new Image(16,16); toggleUpEmpty.src = "#nimages#/nbe.gif";
toggleUpOpen =  new Image(16,16);toggleUpOpen.src  = "#nimages#/bbc.gif";
toggleUpClose =  new Image(16,16);toggleUpClose.src = "#nimages#/bbo.gif";
toggleDownEmpty  = new Image(16,16);toggleDownEmpty.src = "#nimages#/nte.gif";
toggleDownOpen = new Image(16,16); toggleDownOpen.src  = "#nimages#/btc.gif";
toggleDownClose = new Image(16,16);toggleDownClose.src = "#nimages#/bto.gif";
toggleMiddleEmpty = new Image(16,16);toggleMiddleEmpty.src = "#nimages#/nme.gif";
toggleMiddleOpen = new Image(16,16);toggleMiddleOpen.src  = "#nimages#/bmc.gif";
toggleMiddleClose = new Image(16,16);toggleMiddleClose.src = "#nimages#/bmo.gif";
toggleNoneEmpty = new Image(16,16);toggleNoneEmpty.src = "#nimages#/nne.gif";
toggleNoneOpen = new Image(16,16);toggleNoneOpen.src  = "#nimages#/bnc.gif";
toggleNoneClose = new Image(16,16); toggleNoneClose.src = "#nimages#/bno.gif";
s = new Image(16,16);s.src="#nimages#/s.gif";
c = new Image(16,16);c.src="#nimages#/c.gif";
loading = new Image(23,23);loading.src="#nimages#/loading.gif";
subnavmore = new Image(16,11);subnavmore.src = "#nimages#/subnavmore.gif";
subnavmoreDisabled = new Image(16,11);subnavmoreDisabled.src = "#nimages#/subnavmoreDisabled.gif";
defaultObjectDraft = new Image(16,16);defaultObjectDraft.src ="#cimages#/defaultObjectDraft.gif";
defaultObjectLiveDraft = new Image(16,16);defaultObjectLiveDraft.src ="#cimages#/defaultObjectLiveDraft.gif";
defaultObjectLivePendingDraft = new Image(16,16);defaultObjectLivePendingDraft.src ="#cimages#/defaultObjectLivePendingDraft.gif";
defaultObjectPending = new Image(16,16); defaultObjectPending.src = "#cimages#/defaultObjectPending.gif";
defaultObjectApproved = new Image(16,16); defaultObjectApproved.src = "#cimages#/defaultObjectApproved.gif";
webserver = new Image(16,16);webserver.src="#cimages#/webserver.gif";
home = new Image(16,16); home.src="#cimages#/home.gif";
rubbish = new Image(16,16); rubbish.src = "#cimages#/rubbish.gif";
navDraftImg = new Image(16,16);navDraftImg.src = "#cimages#/NavDraft.gif";
navApprovedImg = new Image(16,16);navApprovedImg.src = "#cimages#/NavApproved.gif";
images = new Image(16,16);images.src = "#cimages#/images.gif";
floppyDisk = new Image(16,16);floppyDisk.src="#cimages#/floppyDisk.gif";
navPending = new Image(16,16);navPending.src = "#cimages#/NavPending.gif";
pictureDraft = new Image(16,16); pictureDraft.src = "#cimages#/pictureDraft.gif";
picturePending = new Image(16,16); picturePending.src = "#cimages#/picturePending.gif";
pictureApproved = new Image(16,16); pictureApproved.src = "#cimages#/pictureApproved.gif";
includeDraft = new Image(16,16);includeDraft.src = "#cimages#/includeDraft.gif";
includePending = new Image(16,16); includePending.src = "#cimages#/includePending.gif";
includeApproved = new Image(16,16); includeApproved.src = "#cimages#/includeApproved.gif";
fileDraft = new Image(16,16); fileDraft.src = "#cimages#/fileDraft.gif";
filePending = new Image(16,16);filePending.src="#cimages#/filePending.gif";
fileApproved = new Image(16,16);fileApproved.src="#cimages#/fileApproved.gif";
cssDraft = new Image(16,16); cssDraft.src = "#cimages#/cssDraft.gif";
flashDraft = new Image(16,16); flashDraft.src = "#cimages#/flashApproved.gif";
flashPending = new Image(16,16);flashPending.src="#cimages#/flashApproved.gif";
flashApproved = new Image(16,16);flashApproved.src="#cimages#/flashApproved.gif";
linkDraft = new Image(16,16); linkDraft.src = "#cimages#/linkDraft.gif";
linkPending = new Image(16,16);linkPending.src="#cimages#/linkPending.gif";
linkApproved = new Image(16,16);linkApproved.src="#cimages#/linkApproved.gif";

<cfwddx action="CFML2JS" input="#customIcons.type#" toplevelvariable="customIconMapType">

function renderObjectToDiv( objId, divId )
{
	var el = document.getElementById( divId );
	var elData=renderObject( objId )
	el.innerHTML = elData;
	
}

function renderObject( objId )
{
	var thisObject = objects[objId];
	
	if( !thisObject ) return "";
	
	var elData="";
	
	if( rootIds.indexOf(objId)!=-1) elData += "<table class=tableNode><tr><td>";
	else
	{   
		var parent = getParentObject( objId );
		var parentParent = getParentObject( parent['OBJECTID'] );
		if( parentParent['OBJECTID'] 
			&& (nodeIndex(parent['OBJECTID'])!=-1 && nodeIndex(parent['OBJECTID'])!=countNodes(parentParent['OBJECTID'])-1)
			|| (objectIndex(parent['OBJECTID'])!=-1 && objectIndex(parent['OBJECTID'])!=countChildren(parentParent['OBJECTID'])-1) &&  countNodes(parent['OBJECTID']) > 1  )
			elData += "<table id=\""+objId+"_table\" class=tableNode><tr><td style='background-image: url(\""+c.src+"\");background-repeat : repeat-y;'><img src='"+s.src+"' width="+zoom+" height="+zoom+"></td><td>";
		else
			elData += "<table id=\""+objId+"_table\" class=tableNode><tr><td style='background-image: url(\"" + s.src +"\");background-repeat : repeat-y;'><img src='"+s.src+"' width="+zoom+" height="+zoom+"></td><td>";
	}
	
	var jsHighlight=' onclick="highlightObjectClick(\''+objId+'\',event)" ';
	
	var contextMenu = ' oncontextmenu="if(!event.ctrlKey)highlightObjectClick(\''+objId+'\',event);popupObjectMenu(event);return false;" ';
	var drag = " ondragstart='\startDrag(\""+objId+"\",\""+thisObject['TYPENAME']+"\")' ondrop='dropDrag(\""+objId+"\")' ";
	
	//objects can only be dropped under dmNavigation nodes
	if( thisObject['TYPENAME'].toLowerCase()=="#lCase(attributes.nodetype)#" )
		drag += " ondragover='dragOver()'";	
	else if( thisObject['TYPENAME']=="dmHTML")
		drag += " ondragover='if(dragTypeId.toLowerCase()==\"dmimage\" || dragTypeId.toLowerCase()==\"dmfile\") dragOver()' ";
		
			
	elData+='<table class=\"tableNode\" '+contextMenu+'>\n<tr><td class=iconText>'+getToggleImage(objId)+
				'<div id=\"non'+jsHighlight+'\" style="display:inline" '+drag+jsHighlight+'>'+getTypeImage(objId)+'</div>\n</td>'+
				'<td valign=middle class=iconText>'+
				'\n<div id="'+objId+'_text" '+jsHighlight+'>'+getObjectTitle(objId)+
				'</div>\n</td></tr>\n</table>'+
				'<div id="'+objId+'" style="display:none;">\n</div>\n';
	
	elData += "</td></tr>\n</table>";
	return elData;
	//this is for hiding nodes that user does not have permission to see
	/*if (hideNode(objId) > -1)
		return elData;
	else 
		return "";	*/
}

var dragObjectId='';
var dragTypeId='';

function startDrag( aDragObjectId, aDragTypeId )
{	
    <!--- store the source of the object into a string acting as a dummy object so we don't ruin the original object: --->
	dragObjectId = aDragObjectId;
	dragTypeId = aDragTypeId;
	
    <!--- post the data for Windows: --->
    var dragData = window.event.dataTransfer;

    <!--- set the type of data for the clipboard: --->
	dragData.setData('Text', dragObjectId);
	
    <!--- allow only dragging that involves moving the object: --->
    dragData.effectAllowed = 'linkMove';

    <!--- use the special 'move' cursor when dragging: --->
    dragData.dropEffect = 'move';
}

function dragOver()
{
	<!--- tell onOverDrag handler not to do anything: --->
	window.event.returnValue = false;
}

function dropDrag( aDropObjectId )
{	
	<!--- eliminate default action of ondrop so we can customize: --->
	//double checking here - shouldn't ever need to though
	if (objects[dragObjectId]['TYPENAME'] == 'dmHTML' && objects[aDropObjectId]['TYPENAME'].toLowerCase() != '#lCase(attributes.nodetype)#')
	{
		alert('You may only drag a HTML object to a Navigation node');
		window.event.returnValue = false;
		return;
	}
	//check for equal dest/parent objectid
			
	if(aDropObjectId == getParentObject(dragObjectId)['OBJECTID'])
	{
		alert('Object parent and destination parent cannot be the same');
		return;
	}
	
	if(aDropObjectId == '#application.navid.rubbish#')
		permcheck = "hasPermission( lastSelectedId, #PermSendToTrash# ) > 0";
	else
		permcheck = "hasPermission( aDropObjectId, #PermNavCreate# ) > 0";
	
	if (eval(permcheck))
	{	if( dragObjectId != aDropObjectId && confirm('Are you sure you wish to move this object?'))
		{			
			popupopen('#application.url.farcry#/navajo/move.cfm?srcObjectId='+dragObjectId+'&destObjectId='+aDropObjectId,'NavajoExt','#smallPopupFeatures#');
		}
	}	
	else
		alert('You do not have permission to move objects to this node');	
	
	window.event.returnValue = false;
}

function renderObjectSubElements( objId )
{
	var thisObject = objects[objId];
	if( !thisObject ) return;
	
	var updateDivEl = document.getElementById( objId );
	var divData = "";
	
	var aObjectIds = thisObject['AOBJECTIDS'];
	if( aObjectIds )
	{
		for( var index=0; index < aObjectIds.length; index++ )
		{
			divData += renderObject( aObjectIds[index] );
		}
	}
	
	var aNodes = thisObject['ANAVCHILD'];
	if( aNodes )
	{
		for( var index=0; index < aNodes.length; index++ )
		{
			divData += renderObject( aNodes[index] );
		}
	}
	
	updateDivEl.innerHTML = divData;
}

function getObjectTitle( objId )
{
	var thisObject = objects[objId];
	
	if( !thisObject || !thisObject['TITLE'] ) return "undefined";
	
	return thisObject['TITLE'];
}

function getToggleImage( objId )
{
	<!--- work out what toggle to put on this node --->
	<!--- if it has children or aObjectIds then we need a toggle --->
	var toggle="Empty";
	
	if( countChildren(objId) ) toggle="Open";
	
	var parent = getParentObject( objId );
	
	var direction = "Middle";
	
	<!--- if this is a root node then the toggle is none --->
	if( parent=='0' ) direction = "None";
	
	<!--- else if this is the last node or object --->
	else if( (objectIndex(objId)!=-1 && objectIndex(objId)==countChildren(parent['OBJECTID'])-1)
			|| (nodeIndex(objId)!=-1 && nodeIndex(objId)==countNodes(parent['OBJECTID'])-1) ) direction = "Up";

	scripting="";	
	if( toggle!="Empty" ) scripting=" onclick=\"toggleObject('"+objId+"')\" ";
	
	return "<img id='"+objId+"_toggle' src='"+eval( 'toggle'+direction+toggle+'.src' )+"' width="+zoom+" height="+zoom+" "+scripting+">";
}

function swapToggleImage( src )
{   
	if( src.indexOf(toggleUpOpen.src) !=-1 ) return toggleUpClose.src;
	if( src.indexOf(toggleUpClose.src) !=-1 ) return toggleUpOpen.src;
	
	if( src.indexOf(toggleDownOpen.src) !=-1 ) return toggleDownClose.src;
	if( src.indexOf(toggleDownClose.src) !=-1 ) return toggleDownOpen.src;
	
	if( src.indexOf(toggleMiddleOpen.src) !=-1 ) return toggleMiddleClose.src;
	if( src.indexOf(toggleMiddleClose.src) !=-1 ) return toggleMiddleOpen.src;
	
	if( src.indexOf(toggleNoneOpen.src) !=-1 ) return toggleNoneClose.src;
	if( src.indexOf(toggleNoneClose.src) !=-1 ) return toggleNoneOpen.src;
	
	return src;
}

function getTypeImage( objId )
{
	var thisObject = objects[objId];
	
	var tp = thisObject['TYPENAME'].toLowerCase();
	if (tp == '#lCase(attributes.nodetype)#')
		tp = 'dmnavigation';
	
	var st = 'approved';
	if( thisObject['STATUS'] ) {
        if (thisObject['BHASDRAFT'] && thisObject['DRAFTSTATUS'] == 'pending')
            st = 'livependingdraft';
		else if (thisObject['BHASDRAFT'])
			st = 'livedraft';
		else	
			st = thisObject['STATUS'].toLowerCase();
	}		

	var cm = customIconMapType['default'][st];

	if( customIconMapType[tp] && st ) cm=customIconMapType[tp][st];
	
	var na=thisObject['LNAVIDALIAS'];
	if(na) na=na.toLowerCase();
	
	if( na && customIconMapType[na] ) cm = customIconMapType[na][st];
	
	var alt = "Current Status: "+thisObject['STATUS']+"\nCreated By: "+thisObject['ATTR_CREATEDBY']+" on "+thisObject['ATTR_DATETIMECREATED']+
			"\nLast Updated By: "+thisObject['ATTR_LASTUPDATEDBY']+" on "+thisObject['ATTR_DATETIMELASTUPDATED'];
			
	
	 return "<img src='"+eval(cm+'.src')+"' width="+zoom+" height="+zoom+" alt='"+alt+"'>"; 
}

function countChildren( objId )
{
	return countNodes(objId) + countObjects(objId);
}

function countNodes( objId )
{
	var theObject = objects[objId];
	
	if(!theObject || !theObject['ANAVCHILD'] ) return 0;
	
	return theObject['ANAVCHILD'].length;
}

//Counts all objects in a navigation node
function countObjects( objId )
{
	
	var theObject = objects[objId];
	
	if(!theObject || !theObject['AOBJECTIDS'] ) return 0;
	
	return theObject['AOBJECTIDS'].length;
}

function objectIndex( objId )
{
	var parent = getParentObject( objId );
	
	if( parent["AOBJECTIDS"] )
	{
		for( var index=0; index < parent["AOBJECTIDS"].length; index++ )
		{
			if( parent[searchKey][index]==objId ) return index;
		}
	}
	
	return -1;
}

function nodeIndex( objId )
{
	var parent = getParentObject( objId );
	
	if( parent["ANAVCHILD"] )
	{
		for( var index=0; index < parent["ANAVCHILD"].length; index++ )
		{
			if( parent["ANAVCHILD"][index]==objId ) return index;
		}
	}
	
	return -1;
}

function deleteObject(objId)
{
	delete objects[objId];
}


function getParentObject( objId )
{
	var theNode = objects[objId];
	
	if( !theNode ) return '0';
	
	<!--- if this is a nav node search aNavChild else search aObjectIds --->
	searchKey="AOBJECTIDS";
	
	if( theNode['TYPENAME'].toLowerCase()=='#lCase(attributes.nodetype)#' ) searchKey="ANAVCHILD";
	
	for( var testObjId in objects )
	{
		var thisObject = objects[testObjId];
		
		if( thisObject && thisObject[searchKey] )
		{
			for( var index=0; index < thisObject[searchKey].length; index++ )
			{
				if( thisObject[searchKey][index]==objId ) return thisObject;
			}
		}
	}
	
	return 0;
}

function toggleObject( objId )
{
	 //if( !countChildren(objId) ) return;  
	
	var toggleImageEl = document.getElementById( objId+"_toggle" );
	if(toggleImageEl)
		toggleImageEl.src = swapToggleImage( toggleImageEl.src ); 
		
	var el = document.getElementById( objId );
	
	if(el && (el.style.display=='none' || el.style.display=='') )
	{
		el.innerHTML = "<img src='"+loading.src+"' width="+(zoom-8)+" height="+(zoom-8)+"><span class=iconText>loading...</span>";
		
		allDefined=1;
		
		<!--- Check that we don't already have the data in memory --->
		<!--- and don't have to do a reload  --->
		if( objects[objId] )
		{
			var o = objects[objId];

			if( o['ANAVCHILD'] )
			{
				for( var i=0; i < o['ANAVCHILD'].length; i++ )
				{
					if( !objects[o['ANAVCHILD'][i]] )
					{
						allDefined=0;
						break;
					}
				}
			}
			
			if( allDefined==1 && o['AOBJECTIDS'] )
			{   for( var i=0; i < o['AOBJECTIDS'].length; i++ )
				{   
					if( !objects[o['AOBJECTIDS'][i]] )
					{
						allDefined=0;
						break;
					}
				}
			}
		}
		
		if( allDefined ) 
		{	
			downloadRender( objId );
		}
		else 
		{
			serverPut(objId);
		}
				
	
		storeState( objId, 1 );
		el.style.display = "inline";
		/*else
			//alert(objId);
			//alert(getParentObject(objId)['OBJECTID']);
			document.getElementById(objId).style.display = 'none';	
		*/	
		
	}
	else if (el)
	{
		storeState( objId, 0 );
		el.style.display = "none";
		if(ns6)
			el.innerHTML='';
	}
	
}

function updateTree(src,dest,srcobjid)
{	//alert('src parend is ' + src + ' dest parent is ' + dest);
		
	//thing = document.getElementById(srcobjid+'_shit').parentNode.removeChild(document.getElementById(srcobjid+'_shit'));
	srcParent = getParentObject(src);
		
	if(objects[srcobjid]['TYPENAME'].toLowerCase() != 'dmnavigation')
	{		
		delete srcParent['AOBJECTIDS'][objectIndex(src)];
				
		//add to destination array
		if(objects[dest])
		{
			if(objects[dest]['AOBJECTIDS'].length > 0)
				objects[dest]['AOBJECTIDS'].push(src);
			else
				objects[dest]['AOBJECTIDS'] = new Array(src);
		}		
		downloadRender(srcParent['OBJECTID']);	
	}	
	else	
	{
		delete srcParent['ANAVCHILD'][nodeIndex(src)];
		//insert into dest
		if(objects[dest])
		{
			if(objects[dest]['ANAVCHILD'].length)
				objects[dest]['ANAVCHILD'].unshift(src);
			else
				objects[dest]['ANAVCHILD'] = new Array(src);	
		}		
		downloadRender(srcParent['OBJECTID']);		
	}	
	//alert(dest);
	if(objects[dest])
	{		
		getObjectDataAndRender(dest);
		downloadRender(dest);	
		//toggleObject(dest);
		//toggleObject(dest);	
	}	
	getObjectDataAndRender(srcParent['OBJECTID']);
	downloadRender(srcParent['OBJECTID']);
	//toggleObject(srcParent['OBJECTID']);
	//toggleObject(srcParent['OBJECTID']);
	

}


function downloadDone( s )
{	var objectId = eval(s);
	var parentId = getParentObject(objectId)['OBJECTID'];
	toggleObject(parentId);
	toggleObject(parentId);
		
}


function getObjectDataAndRender( objId )
{	
	var parentObj;
	if( objId && objId !=0 ) parentObj = getParentObject(objId);
	
	if( objId && objId != '0' && parentObj )
	{
		serverPut(objId);
	}
	else
	{
		<!--- this is a gay arse way of reloading the window, because of some bug --->
		<!--- in windows causing window.reload to crash --->
		window.location.href = "#application.url.farcry#/navajo/overview_frame.cfm?i="+(new Date()).getTime()+"&rootObjectID=#rootobjectID#";
	}
}


function downloadRender( objectId )
{
	
	renderObjectSubElements( objectId );

	<!--- loop throught this object children and see if any of them need to be toggled --->
	var theObject = objects[objectId];
	var aCookies = document.cookie.split(";");
	var cookieString="";
	
	for( var i=0; i<aCookies.length; i++ )
	{
		if ( aCookies[i].indexOf( cookieName ) != -1 )
		{
			cookieString = aCookies[i];
			break;
		}
	}
	
	if( theObject['AOBJECTIDS'] )
	{
		for( var cnt=0; cnt < theObject['AOBJECTIDS'].length; cnt++ )
		{
			if( cookieString.indexOf(theObject['AOBJECTIDS'][cnt]) != -1 )
			{
				toggleObject( theObject['AOBJECTIDS'][cnt] );
			}
		}
	}
	
	if( theObject['ANAVCHILD'] )
	{
		for( var cnt=0; cnt < theObject['ANAVCHILD'].length; cnt++ )
		{
			if( cookieString.indexOf(theObject['ANAVCHILD'][cnt]) != -1 )
			{
				toggleObject( theObject['ANAVCHILD'][cnt] );
			}
		}
	}
	
}

function highlightObjectClick( id,e )
{    
	if( !e.ctrlKey )
	{
		// check if already in edit mode, if not show overview page	
		if(parent['editFrame'] && parent['editFrame'].document.location.href.indexOf(id) < 0 && parent['editFrame'].document.location.href.indexOf("edittabEdit") < 0 && parent['editFrame'].document.location.href.indexOf("edit.cfm") < 0)
		{
			// load overview page
			parent['editFrame'].document.location = "#application.url.farcry#/edittabOverview.cfm?objectid=" + id;
			// make tabs visible in edit frame
			showEditTabs('site',id,'edittabOverview');
			// change title in edit frame
		}
		
		clearHighlightedObjects();
		highlightObject( id );
		
	}
	else toggleObjectHighlight( id );
}

function highlightObject( id )
{
	
	var theDiv = document.getElementById( id+"_text" );
	if( theDiv )
	{
		theDiv.style.backgroundColor="##aaaaaa";
		if( !isSelected(id) )
		{
			aSelectedIds[aSelectedIds.length]=id;
			lastSelectedId = id;
		}
	}

	/*var rng = document.body.createTextRange( );
	rng.move('character');
	rng.select();*/
}

function isSelected( id )
{
	for( var i=0; i<aSelectedIds.length; i++ )
	{
		if( aSelectedIds[i]==id ) return 1;
	}
	
	return 0;
}

function clearHighlightedObjects()
{
	for( var i=0; i<aSelectedIds.length; i++ )
	{
		var theDiv = document.getElementById( aSelectedIds[i]+"_text" );
		if( theDiv ) theDiv.style.backgroundColor="";
	}
	
	<!--- clear the array --->
	lastSelectedId = 0;
	aSelectedIds = new Array();

	/*var rng = document.body.createTextRange( );
	rng.move('character');
	rng.select();*/
}

function toggleObjectHighlight( id )
{
	<!--- see if div is already selected --->
	var isSelected = 0;
	var i;
	
	for( i=0; i<aSelectedIds.length; i++ )
	{
		if( aSelectedIds[i]==id )
		{
			isSelected=1;
			break;
		}
	}
	
	if( isSelected )<!--- if it is selected, turn it off --->
	{
		var theDiv = document.getElementById( id+"_text" );
		if( theDiv ) theDiv.style.backgroundColor="";
		
		aSelectedIds.splice( i, 1 );
	}
	else highlightObject( id );<!--- else turn it on --->
	
	/*var rng = document.body.createTextRange( );
	rng.move('character');
	rng.select();*/
}

function storeState( id, state )
{
	if( id == 0 ) return;
	var aCookies = document.cookie.split(";");

	var newCookie=cookieName;
	
	for( var i=0; i<aCookies.length; i++ )
	{
		if ( aCookies[i].indexOf( cookieName ) != -1 )
		{
			var temp = aCookies[i].substring( cookieName.length, aCookies[i].length);
			var nodeids = temp.split(",");
			
			<!--- loop through the cookies and generate the new node state --->
			for( var index=0; index < nodeids.length; index++ )
			{
				var aid = nodeids[index].replace( /\=/g, "" );
				if( aid != id )
				{
					if ( newCookie.length > cookieName.length ) newCookie += ",";
					newCookie += aid;
				}
			}
		}
	}
	
	if(state)
	{
		if ( newCookie.length > cookieName.length ) newCookie += ",";
		newCookie += id;
	}
	
	var aDate = new Date();
	//aDate.setFullYear( aDate.getFullYear()+1 );
	//var expiration = new Date((new Date()).getTime() + 1*3600000);
	//document.cookie = newCookie + "; expires="+aDate.toGMTString();
	document.cookie = newCookie;// + "; expires="+expiration;
}
</cfoutput>

objectMenu = new Object();
objectMenu.menuInfo = new Object();
objectMenu.menuInfo.name = "ObjectMenu";

<cfif isDefined("url.insertonly")>
<cfoutput>
o = new Object();
objectMenu['Insert'] = o;
o.text = "Insert";
o.js = "menuOption_Insert()";
o.jsvalidate = "(parent['editFrame'].insertObjId || parent['editFrame'].insertObjIds || parent['editFrame'].insertHTML)?1:0";
o.bShowDisabled = 1;
o.bSeperator = 0;

function menuOption_Insert()
{
	// get object
	var theNode = objects[ lastSelectedId ];
	var p = parent['editFrame'];
	
	if( p.insertaObjIds ) p.insertaObjIds( aSelectedIds );
	else if( p.insertObjId ) p.insertObjId( lastSelectedId );
	else switch( theNode['TYPENAME'] )
	{
		case "dmImage":
            if ( theNode['HIGHRESFILENAME'] )
    			p.insertHTML( "<a href=\"javascript:popup=window.open('/dmfile/display_hires_image.cfm?objectID="+theNode['OBJECTID']+"', 'popup', 'width=270,height=270,channelmode=no,directories=no,fullscreen=no,location=no,menubar=no,resizable=yes,scrollbars=no,status=no,titlebar=no,toolbar=no', false); popup.focus();\"><img alt='"+theNode['ALT']+"' src='/images/"+theNode['FILENAME']+"'></a>" );
            else
				p.insertHTML( "<img alt='"+theNode['ALT']+"' src='#application.url.webroot#/images/"+theNode['IMAGEFILE']+"'>" );
			break;
		
		case "dmFile":
			p.insertHTML( "<a href='#application.url.webroot#/download.cfm?DownloadFile="+lastSelectedId+"' target='_blank'>"+theNode['TITLE']+"</a>" );
			break;
			
		case "dmFlash":
			p.insertHTML( "<OBJECT classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version="+theNode['FLASHVERSION']+"' WIDTH='"+theNode['FLASHWIDTH']+"'  HEIGHT='"+theNode['FLASHHEIGHT']+"'  ALIGN='"+theNode['FLASHALIGN']+"'><PARAM NAME='movie' VALUE='http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT##application.url.webroot#/files/"+theNode['FLASHMOVIE']+"'><PARAM NAME='quality' VALUE='"+theNode['FLASHQUALITY']+"'><PARAM NAME='play' VALUE='"+theNode['FLASHPLAY']+"'><PARAM NAME='menu' VALUE='"+theNode['FLASHMENU']+"'><PARAM NAME='loop' VALUE='"+theNode['FLASHLOOP']+"'><PARAM NAME='FlashVars' VALUE='"+theNode['FLASHPARAMS']+"'><EMBED SRC='http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT#/#application.url.webroot#/files/"+theNode['FLASHMOVIE']+"' QUALITY='"+theNode['FLASHQUALITY']+"' WIDTH='"+theNode['FLASHWIDTH']+"' HEIGHT='"+theNode['FLASHHEIGHT']+"' FLASHVARS='"+theNode['FLASHPARAMS']+"' ALIGN='"+theNode['FLASHALIGN']+"' MENU='"+theNode['FLASHMENU']+"' PLAY='"+theNode['FLASHPLAY']+"' LOOP='"+theNode['FLASHLOOP']+"' TYPE='application/x-shockwave-flash' PLUGINSPAGE='http://www.macromedia.com/go/getflashplayer'></EMBED></OBJECT>" );
			break;
			
		default:
			p.insertHTML( "<a href='#application.url.webroot#/index.cfm?objectId="+lastSelectedId+"'>"+theNode['TITLE']+"</a>" );
			break;
	}
} 
</cfoutput>
<cfelse>
<cfoutput>
<!--- ***  MENU DATA *** --->


o = new Object();
objectMenu['Edit'] = o;
o.text = "Edit";
o.js = "menuOption_Edit();";
o.jsvalidate = "hasPermission( lastSelectedId, #PermNavEdit# );";
o.bShowDisabled = "1";

function menuOption_Edit()
{
	// open edit page in edit frame
	frameopen( '#application.url.farcry#/edittabEdit.cfm?objectId='+lastSelectedId, 'editFrame' );
	// set edit tab to active
	showEditTabs('site',lastSelectedId,'edittabEdit');
	
}

o = new Object();
objectMenu['Preview'] = o;
o.text = "Preview";
o.js = "menuOption_Preview()";
o.jsvalidate = "hasPermission( lastSelectedId, #PermNavView# );";
o.bShowDisabled = 1;

function menuOption_Preview()
{   
	window.open('#application.url.conjurer#?objectId='+lastSelectedId+"&flushcache=1&showDraft=1");
}


o = new Object();
objectMenu['Preview Draft'] = o;
o.text = "Preview Draft";
o.js = "menuOption_PreviewDraft()";
o.jsvalidate = "hasDraft(lastSelectedId);";
o.bShowDisabled = 1;

function hasDraft (objectid)
{
	if(objects[objectid]['BHASDRAFT'])
		{permission = 1;}
	else {permission = 0;}
	
	return permission;
}
function menuOption_PreviewDraft()
{   
	window.open('#application.url.conjurer#?objectId='+objects[lastSelectedId]['DRAFTOBJECTID']+"&flushcache=1&showDraft=1");
}


o = new Object();
objectMenu['Move'] = o;
o.text = "Move";
o.submenu = "Move";
o.jsvalidate = "((objects[lastSelectedId]['TYPENAME'].toLowerCase()=='#lCase(attributes.nodetype)#' && hasPermission(getParentObject(lastSelectedId)['OBJECTID'], #PermNavEdit# ) && countNodes(getParentObject(lastSelectedId)['OBJECTID']) > 1) || (hasPermission(getParentObject(lastSelectedId)['OBJECTID'], #PermNavEdit# ) && countObjects(getParentObject(lastSelectedId)['OBJECTID']) > 1))?1:0";

//o.jsvalidate = "(hasPermission(getParentObject(lastSelectedId)['OBJECTID'], #PermNavEdit# ) && (countObjects(getParentObject(lastSelectedId)['OBJECTID']) > 1 || countNodes(getParentObject(lastSelectedId)['OBJECTID']) > 1 ))?1:0";
//o.jsvalidate = 1;
o.bShowDisabled = 1;
o.bSeperator = 0;

	moveMenu = new Object();
	moveMenu.menuInfo = new Object();
	moveMenu.menuInfo.name = "MoveMenu";

	o = new Object();
	moveMenu['MoveUp'] = o;
	o.text = "Move Up";
	o.js = "menuOption_MoveInternal(\\'up\\');";
	o.jsvalidate = "objectIndex(lastSelectedId)>0||nodeIndex(lastSelectedId)>0";
	o.bShowDisabled = 1;
	
	o = new Object();
	moveMenu['MoveDown'] = o;
	o.text = "Move Down";
	o.js = "menuOption_MoveInternal(\\'down\\');";
	o.jsvalidate = 	"(objectIndex(lastSelectedId)!=-1 && objectIndex(lastSelectedId)+1 < countObjects(getParentObject(lastSelectedId)['OBJECTID'])) || "+
					"(nodeIndex(lastSelectedId)!=-1 && nodeIndex(lastSelectedId)+1 < countNodes(getParentObject(lastSelectedId)['OBJECTID']))";
	o.bShowDisabled = 1;
	o.bSeperator = 0;
	
	o = new Object();
	moveMenu['MoveToTop'] = o;
	o.text = "Move To Top";
	o.js = "menuOption_MoveInternal(\\'top\\');";
	o.jsvalidate = "objectIndex(lastSelectedId)>0||nodeIndex(lastSelectedId)>0";
	o.bShowDisabled = 1;
	
	o = new Object();
	moveMenu['MoveToBottom'] = o;
	o.text = "Move To Bottom";
	o.js = "menuOption_MoveInternal(\\'bottom\\');";
	o.jsvalidate = "(objectIndex(lastSelectedId)!=-1 && objectIndex(lastSelectedId)+1 < countObjects(getParentObject(lastSelectedId)['OBJECTID'])) || "+
					"(nodeIndex(lastSelectedId)!=-1 && nodeIndex(lastSelectedId)+1 < countNodes(getParentObject(lastSelectedId)['OBJECTID']))";
	o.bShowDisabled = 1;
	
	function menuOption_MoveInternal( dir )
	{
		popupopen( '#application.url.farcry#/navajo/moveInternal.cfm?direction='+dir+'&objectId='+lastSelectedId, '_blank', '#smallpopupfeatures#' );
	}

o = new Object();
objectMenu['Create'] = o;
o.text = "Create";
o.submenu = "Create";
o.jsvalidate = "((hasPermission( lastSelectedId, #PermNavCreate# ) >=0) &&  (objects[lastSelectedId]['TYPENAME'].toLowerCase()=='#lcase(attributes.nodetype)#'))";
o.bShowDisabled = 1;

	createMenu = new Object();
	createMenu.menuInfo = new Object();
	createMenu.menuInfo.name = "CreateMenu";

	
	<!-------*************** OBJECT CREATE MENU OPTIONS HERE **************------->
	
	</cfoutput>
	
	<!--- build types to create in tree --->
	<cfloop from="1" to="#arrayLen(aTypesUseInTree)#" index="index">
		<cfset stType = structNew()>
		<Cfset stType.label = "#aTypesUseInTree[index].typename#">
		<Cfset stType.description = "#aTypesUseInTree[index].description#">
		<Cfset i="#aTypesUseInTree[index].typename#">
		<Cfset stType.typeid = i>
		<cfif i IS attributes.nodetype>
			<cfset i = "dmNavigation">
		</cfif>
		
		<cfset defaultImage = customIcons.Type.default.draft>
		<cfif( StructKeyExists( customIcons.Type, i ) AND StructKeyExists( customIcons.Type[i], "draft" ))>
			<Cfset defaultImage = customIcons.Type[i].draft>
		</cfif>
		<cfoutput>
	
		o = new Object();
		createMenu['create#stType.label#'] = o;
		o.text = "<img align='absmiddle' src='"+#defaultImage#.src+"' height="+zoom+">&nbsp;#stType.description#";
		o.js = "menuOption_CreateFramed(\\'#stType.typeId#\\');";
		o.jsvalidate = 1;
		o.bShowDisabled = "";
		</cfoutput>
	</cfloop>
<cfoutput>
function menuOption_CreateFramed( id )
{
	frameopen( '#application.url.farcry#/navajo/createObject.cfm?nodetype=#attributes.nodetype#&objectId='+lastSelectedId+'&typename='+id, 'editFrame' );
	// set edit tab to active
	showEditTabs('site',lastSelectedId,'edittabEdit');
}

function menuOption_CreatePopup( id )
{
	popupopen( '#application.url.farcry#/navajo/createObject.cfm?nodetype=#attributes.nodetype#&objectId='+lastSelectedId+'&typename='+id, 'popupEditFrame', '#smallPopupFeatures#' );
}

o = new Object();
objectMenu['Approve'] = o;
o.text = "Status";
o.submenu = "Approve";
o.jsvalidate = "(objects[lastSelectedId]['STATUS'] && (objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#' || objects[lastSelectedId]['TYPENAME'] == 'dmHTML'))?1:0";
o.bShowDisabled = 1;

	approveMenu = new Object();
	approveMenu.menuInfo = new Object();
	approveMenu.menuInfo.name = "ApproveMenu";

	o = new Object();
	approveMenu['ApproveItem'] = o;
	o.text = "Approve";
	o.js = "menuOption_Approve(\\'approved\\')";
	o.jsvalidate = "(hasPermission( lastSelectedId, #PermNavApprove# )>=0 && (objects[lastSelectedId]['STATUS'] == 'draft' || objects[lastSelectedId]['STATUS'] == 'pending'))?1:0";
	o.bShowDisabled = 1;
	
	o = new Object();
	approveMenu['ApproveDraft'] = o;
	o.text = "Approve Draft";
	o.js = "menuOption_Approve(\\'approved\\')";
    o.jsvalidate = "( hasPermission(lastSelectedId, #PermNavApprove#)>=0 && (hasDraft(lastSelectedId) && objects[lastSelectedId]['DRAFTSTATUS'] == 'pending') )?1:0";
	o.bShowDisabled = 1;

	o = new Object();
	approveMenu['ApproveBranch'] = o;
	o.text = "Approve Branch";
	o.js = "menuOption_ApproveBranch(\\'approved\\')";
	o.jsvalidate = "(hasPermission( lastSelectedId, #PermNavApprove# )>=0 && (objects[lastSelectedId]['STATUS'] == 'draft' || objects[lastSelectedId]['STATUS'] == 'pending') && objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#')?1:0";
	o.bShowDisabled = 1;

	function menuOption_Approve( status ) {
		//popupopen( 'approve.cfm?objectId='+lastSelectedId+'&status='+status, '_blank', '#smallpopupfeatures#' );
		if (objects[lastSelectedId]['BHASDRAFT'] && status.toLowerCase() == 'requestapproval')
			frameopen( '#application.url.farcry#/navajo/approve.cfm?objectID='+lastSelectedId+'&draftObjectId='+objects[lastSelectedId]['DRAFTOBJECTID']+'&status='+status+'&requestlivedraft=1', 'editFrame' );
        else if (objects[lastSelectedId]['BHASDRAFT'] && (status.toLowerCase() == 'approved' || status.toLowerCase() == 'draft'))
            frameopen( '#application.url.farcry#/navajo/approve.cfm?objectId='+objects[lastSelectedId]['DRAFTOBJECTID']+'&status='+status, 'editFrame' );
		else
			frameopen( '#application.url.farcry#/navajo/approve.cfm?objectId='+lastSelectedId+'&status='+status, 'editFrame' );
	}

	function menuOption_ApproveBranch( status ) {
		if( confirm('This action will send all objects in this branch to status of ' + status + '. Are you sure you wish to do this?'))
			//popupopen( 'approve.cfm?approveBranch=1&objectId='+lastSelectedId+'&status='+status, '_blank', '#smallpopupfeatures#' );
			frameopen( '#application.url.farcry#/navajo/approve.cfm?approveBranch=1&objectId='+lastSelectedId+'&status='+status, 'editFrame' );
	}
	
	o = new Object();
	approveMenu['Request'] = o;
	o.text = "Request";
	o.js = "menuOption_Approve(\\'requestApproval\\')";
	o.jsvalidate = "(hasPermission( lastSelectedId, #PermNavRequestApprove# )>=0 && ((objects[lastSelectedId]['STATUS'] == 'draft') || (objects[lastSelectedId]['DRAFTOBJECTID'] && objects[lastSelectedId]['DRAFTSTATUS']=='draft')) )?1:0";
	o.bShowDisabled = 1;
	o.bSeperator = 0;
	
	o = new Object();
	approveMenu['RequestBranch'] = o;
	o.text = "Request Approval for Branch";
	o.js = "menuOption_ApproveBranch(\\'requestApproval\\')";
	o.jsvalidate = "(hasPermission( lastSelectedId, #PermNavRequestApprove# )>=0 && (objects[lastSelectedId]['STATUS'] == 'draft') && objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#')?1:0";
	o.bShowDisabled = 1;
	
	o = new Object();
	approveMenu['Decline'] = o;
	o.text = "Decline Draft";
	o.js = "menuOption_Approve(\\'draft\\')";
    o.jsvalidate = "( hasPermission(lastSelectedId, #PermNavApprove#)>=0 && (hasDraft(lastSelectedId) && objects[lastSelectedId]['DRAFTSTATUS'] == 'pending') )?1:0";
	o.bShowDisabled = 1;

	o = new Object();
	approveMenu['Cancel'] = o;
	o.text = "Send To Draft";
	o.js = "menuOption_Approve(\\'draft\\')";
	o.jsvalidate = "(hasPermission( lastSelectedId, #PermNavApprove# )>=0 && !hasDraft(lastSelectedId) && (objects[lastSelectedId]['STATUS'] == 'approved' || objects[lastSelectedId]['STATUS'] == 'pending'))?1:0";
	o.bShowDisabled = 1;
	
	o = new Object();
	approveMenu['CancelBranch'] = o;
	o.text = "Send Branch To Draft";
	o.js = "menuOption_ApproveBranch(\\'draft\\')";
	o.jsvalidate = "(hasPermission( lastSelectedId, #PermNavApprove# )>=0 && (objects[lastSelectedId]['STATUS'] == 'approved' || objects[lastSelectedId]['STATUS'] == 'pending') && objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#')?1:0";
	o.bShowDisabled = 1;

	
o = new Object();
objectMenu['Insert'] = o;
o.text = "Insert";
o.js = "menuOption_Insert()";
o.jsvalidate = "(parent['editFrame'].insertObjId || parent['editFrame'].insertObjIds || parent['editFrame'].insertHTML)?1:0";
o.bShowDisabled = 1;
o.bSeperator = 0;

function menuOption_Insert()
{
	// get object
	var theNode = objects[ lastSelectedId ];
	var p = parent['editFrame'];
	
	if( p.insertaObjIds ) p.insertaObjIds( aSelectedIds );
	else if( p.insertObjId ) p.insertObjId( lastSelectedId );
	else switch( theNode['TYPENAME'] )
	{
		case "dmImage":
            if ( theNode['HIGHRESFILENAME'] )
    			p.insertHTML( "<a href=\"javascript:popup=window.open('/dmfile/display_hires_image.cfm?objectID="+theNode['OBJECTID']+"', 'popup', 'width=270,height=270,channelmode=no,directories=no,fullscreen=no,location=no,menubar=no,resizable=yes,scrollbars=no,status=no,titlebar=no,toolbar=no', false); popup.focus();\"><img alt='"+theNode['ALT']+"' src='/images/"+theNode['FILENAME']+"'></a>" );
            else
				p.insertHTML( "<img alt='"+theNode['ALT']+"' src='#application.url.webroot#/images/"+theNode['IMAGEFILE']+"'>" );
			break;
		
		case "dmFile":
			p.insertHTML( "<a href='#application.url.webroot#/download.cfm?DownloadFile="+lastSelectedId+"' target='_blank'>"+theNode['TITLE']+"</a>" );
			break;
			
		case "dmFlash":
			p.insertHTML( "<OBJECT classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version="+theNode['FLASHVERSION']+"' WIDTH='"+theNode['FLASHWIDTH']+"'  HEIGHT='"+theNode['FLASHHEIGHT']+"'  ALIGN='"+theNode['FLASHALIGN']+"'><PARAM NAME='movie' VALUE='http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT##application.url.webroot#/files/"+theNode['FLASHMOVIE']+"'><PARAM NAME='quality' VALUE='"+theNode['FLASHQUALITY']+"'><PARAM NAME='play' VALUE='"+theNode['FLASHPLAY']+"'><PARAM NAME='menu' VALUE='"+theNode['FLASHMENU']+"'><PARAM NAME='loop' VALUE='"+theNode['FLASHLOOP']+"'><PARAM NAME='FlashVars' VALUE='"+theNode['FLASHPARAMS']+"'><EMBED SRC='http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT#/#application.url.webroot#/files/"+theNode['FLASHMOVIE']+"' QUALITY='"+theNode['FLASHQUALITY']+"' WIDTH='"+theNode['FLASHWIDTH']+"' HEIGHT='"+theNode['FLASHHEIGHT']+"' FLASHVARS='"+theNode['FLASHPARAMS']+"' ALIGN='"+theNode['FLASHALIGN']+"' MENU='"+theNode['FLASHMENU']+"' PLAY='"+theNode['FLASHPLAY']+"' LOOP='"+theNode['FLASHLOOP']+"' TYPE='application/x-shockwave-flash' PLUGINSPAGE='http://www.macromedia.com/go/getflashplayer'></EMBED></OBJECT>" );
			break;
			
		default:
			p.insertHTML( "<a href='#application.url.webroot#/index.cfm?objectId="+lastSelectedId+"'>"+theNode['TITLE']+"</a>" );
			break;
	}
} 

o = new Object();
objectMenu['Permissions'] = o;
o.text = "Permissions";
o.js = "menuOption_Permissions()";
o.jsvalidate = "(#iModifyPermissionsState# > -1 && objects[lastSelectedId]['TYPENAME'].toLowerCase()=='#lcase(attributes.nodetype)#')?1:0";
o.bShowDisabled = 1;
o.bSeperator = 0;

function menuOption_Permissions()
{
	frameopen( '#application.url.farcry#/navajo/permissions.cfm?objectId='+lastSelectedId, 'editFrame' );
}

o = new Object();
objectMenu['Dump'] = o;
o.text = "Dump";
o.js = "menuOption_Dump();";
o.jsvalidate = "#iDeveloperState#";
o.bShowDisabled = 0;
o.bSeperator = 0;

function menuOption_Dump()
{
	frameopen( '#application.url.farcry#/navajo/dump.cfm?lObjectIds='+aSelectedIds.toString(),'editFrame' );
}

o = new Object();
objectMenu['Delete'] = o;
o.text = "Delete";
o.js = "menuOption_Delete()"; //  && countObjects(lastSelectedId) <=0  && countNodes(lastSelectedId) <=0
o.jsvalidate = "hasPermission( lastSelectedId, #PermNavDelete# )";
o.bShowDisabled = 1;
o.bSeperator = 0;

function menuOption_Delete()
{
	// if( confirm('Are you sure you wish to delete this object(s)?') ) popupopen( 'delete.cfm?objectId='+lastSelectedId, '_blank', '#smallpopupfeatures#' );
	if( confirm('Are you sure you wish to delete this object(s)?') )
		frameopen('#application.url.farcry#/navajo/delete.cfm?objectId='+lastSelectedId,'editFrame');
}

o = new Object();
objectMenu['Trash'] = o;
o.text = "Send To Trash";
o.js = "menuOption_Trash()"; 
o.jsvalidate = "hasPermission( lastSelectedId, #PermSendToTrash# );";
o.bShowDisabled = 0;
o.bSeperator = 0;

function menuOption_Trash()
{
	if( confirm('Are you sure you wish to send this object to the trash?') ) popupopen( '#application.url.farcry#/navajo/move.cfm?srcObjectId='+lastSelectedId+'&destObjectId=#application.navid.rubbish#', '_blank', '#smallpopupfeatures#' );
}

o = new Object();
objectMenu['Zoom'] = o;
o.text = "Zoom In/Zoom Out";
o.js = "menuOption_Zoom()"; 
o.jsvalidate = "objects[lastSelectedId]['TYPENAME'].toLowerCase()=='#lcase(attributes.nodetype)#'?1:0";
o.bShowDisabled = 0;
o.bSeperator = 0;

function menuOption_Zoom()
{
	<cfif isDefined("URL.rootobjectID") AND NOT URL.rootobjectID IS rootobjectID>
		
		if (lastSelectedId != '#URL.rootobjectID#')
			location.href='#CGI.SCRIPT_NAME#?rootObjectId='+lastSelectedId;
		else
			location.href='#CGI.SCRIPT_NAME#';	
	<cfelse>
		if (lastSelectedId == '#rootObjectID#')
			location.href='#CGI.SCRIPT_NAME#';
		else
			location.href='#CGI.SCRIPT_NAME#?rootObjectId='+lastSelectedId;
				
	</cfif>	
}
</cfoutput>
</cfif>
<cfoutput>
function generateMenu( data, bIsSub )
{
	var menuData;
	
	if( bIsSub ) menuData = beginSubMenu(data.menuInfo.name);
		else menuData = beginMainMenu(data.menuInfo.name);
	
	for( var menuItemId in data )
	{
		if( menuItemId != 'menuInfo' )
		{
			var o = data[ menuItemId ];
			if( o.submenu )
			menuData += menuItemPopup( menuItemId, o.text, o.submenu, o.bShowDisabled );
				else
			menuData += menuItemClickable( menuItemId, o.text, o.js, o.bShowDisabled );
			
			if( o.bSeperator ) menuData += menuItemSeperator();
		}
	}
	menuData += endMenu();
	//alert(menuData);
	pm = document.getElementById("popupMenus");
	pm.innerHTML += menuData;
	//document.all.popupMenus.innerHTML += menuData;
}

generateMenu( objectMenu, 0 );
<cfif not IsDefined("url.insertonly")>
generateMenu( moveMenu  , 1 );
generateMenu( createMenu, 1 );
generateMenu( approveMenu, 1 );
</cfif>

function objectCopy( obj )
{
	var newObj = new Object();
	
	newObj.x = obj.x;
	newObj.y = obj.y;
	newObj.ctrlKey = obj.ctrlKey;
	
	return newObj;
}

function beginMainMenu( id )
{
	return "<div id='"+id+"' onClick='event.cancelBubble=true' class='menudiv'>\n<div id='"+id+"_header' class='menuItemHeader'>hello</div>\n";
}

function beginSubMenu( id )
{
	return "<div id='"+id+"' onClick='event.cancelBubble=true'  class='menudiv'>";
}

function endMenu()
{
	return "</div>";
}

function menuItemClickable( id, text, onclick, bShowDisabled )
{
	return	'<div id="'+id+'Item" class="menuItem" onclick="heldEvent=objectCopy(event);flutter(this,\''+onclick+'\');" onMouseOver="fpo(this)" onMouseOut="fpf(this);">'+
			'<table width=100% class="menuItem"><tr><td width=100%><nobr class="menuText">'+text+'</nobr></td></table></div>'+
			'<div id="'+id+'_disabled" class="menuItemDisabled">'+
			'<table width=100% class="menuItemDisabled"><tr><td width=100%><nobr class="menuText">'+text+'</nobr></td></table></div>';
}

function menuItemPopup( id, text, popup, bShowDisabled )
{
	return	'<div id="'+id+'Item" class="menuItem" onMouseOver="fpo(this);popupMenu(\''+popup+'\');" onMouseOut="fpf(this);">\n'+
			'<table width=100% class="menuItem"><tr><td width=100%><nobr class="menuText">'+text+'...</nobr></td><Td><img align=right src="'+subnavmore.src+'" width="#attributes.zoom#"></td></tr></table></div>'+
			'<div id="'+id+'_disabled" class="menuItemDisabled">\n'+
			'<table width=100% class="menuItemDisabled"><tr><td width=100%><nobr class="menuText">'+text+'...</nobr></td><Td><img align=right src="'+subnavmoreDisabled.src+'" width="#attributes.zoom#"></td></tr></table></div>';
}

function menuItemSeperator()
{
	return "<hr>";
}

function popupMenu( id )
{
	hideSubMenus();

	var data = eval(id.toLowerCase()+"Menu");
	
	for( var menuItemId in data )
	{
		if( menuItemId != 'menuInfo' )
		{
			var o = data[ menuItemId ];
			
			var menuOptionEnabledDiv = document.getElementById( menuItemId+"Item" );
			var menuOptionDisabledDiv = document.getElementById( menuItemId+"_disabled" );

			if( eval(o.jsvalidate)>0 )
			{
				// make vis
				menuOptionEnabledDiv.style.display = "block";
				menuOptionDisabledDiv.style.display = "none";
			}
			else
			{
				// make invis
				menuOptionEnabledDiv.style.display = "none";
				menuOptionDisabledDiv.style.display = "block";
			}
		}
	}
	
	var menuObject = document.getElementById(id+"Menu");
	var boundingRect = myGetBoundingRect(document.getElementById(id+"Item"));
	
	menuObject.style.left=boundingRect.right+document.body.scrollLeft-4;
	menuObject.style.top=boundingRect.top+document.body.scrollTop;
	
	menuObject.style.visibility="visible";
	
	divOnScreen( id+"Menu" );
}

function popupObjectMenu(e)
{
	// do normal context menu if shift key is down
	if ( e.shiftKey ) return;
	
	// cancel the normal context menu
	e.returnValue = false;
	
	// run through the object menu and run enabled/disabled checks
	var data = objectMenu;
	
	for( var menuItemId in data )
	{
		if( menuItemId != 'menuInfo' )
		{
			var o = data[ menuItemId ];
			
			var menuOptionEnabledDiv = document.getElementById( menuItemId+"Item" );
			var menuOptionDisabledDiv = document.getElementById( menuItemId+"_disabled" );
						
			if( eval(o.jsvalidate)>0 )
			{
				// make vis
				menuOptionEnabledDiv.style.display = "block";
				menuOptionDisabledDiv.style.display = "none";
			}
			else
			{
				// make invis
				menuOptionEnabledDiv.style.display = "none";
				menuOptionDisabledDiv.style.display = "block";
			}
		}
	}

	// set the title
	var title = getObjectTitle( lastSelectedId );
	if( title.length > 16 ) title=title.substr( 0, 15 )+"...";
	document.getElementById( "ObjectMenu_header" ).innerHTML = title;

	var objectMenuDiv = document.getElementById( "ObjectMenu" );
	
	var rightedge=ie5? document.body.clientWidth-event.clientX : window.innerWidth-e.clientX
	var bottomedge=ie5? document.body.clientHeight-event.clientY : window.innerHeight-e.clientY
		
	
	//if the horizontal distance isn't enough to accomodate the width of the context menu
	if (rightedge<objectMenuDiv.offsetWidth)
	//move the horizontal position of the menu to the left by it's width
		objectMenuDiv.style.left=ie5? document.body.scrollLeft+event.clientX-objectMenuDiv.offsetWidth : window.pageXOffset+e.clientX-objectMenuDiv.offsetWidth
	else
	//position the horizontal position of the menu where the mouse was clicked
		objectMenuDiv.style.left=ie5? document.body.scrollLeft+event.clientX : window.pageXOffset+e.clientX

	//same concept with the vertical position
	if (bottomedge<objectMenuDiv.offsetHeight)
		objectMenuDiv.style.top=ie5? document.body.scrollTop+event.clientY-objectMenuDiv.offsetHeight : window.pageYOffset+e.clientY-objectMenuDiv.offsetHeight
	else
		objectMenuDiv.style.top=ie5? document.body.scrollTop+event.clientY : window.pageYOffset+e.clientY

	objectMenuDiv.style.visibility = "visible";
	
	//window.event.cancelBubble = true;
	
	divOnScreen( "daemon_object_popupMenu_header" );
	
}

function divOnScreen( divId )
{
	var theDiv = document.getElementById( divId );
	if( theDiv )
	{
		var boundingRect = myGetBoundingRect( theDiv );
		
		if( boundingRect.bottom > document.body.clientHeight )
		{
			var st = theDiv.style;
			st.top = parseInt( st.top ) - (boundingRect.bottom - document.body.clientHeight);
		}
		
		if( boundingRect.right > document.body.clientWidth )
		{
			var st = theDiv.style;
			st.left = parseInt( st.left ) - (boundingRect.right - document.body.clientWidth);
		}
	}
}

function myGetBoundingRect( theDiv )
{
	var boundingRect = new Object();
	
	boundingRect['left'] = -document.body.scrollLeft;
	boundingRect['top'] = -document.body.scrollTop;
	boundingRect['right'] = theDiv.offsetWidth-document.body.scrollLeft;
	boundingRect['bottom'] = theDiv.offsetHeight-document.body.scrollTop;

	while( theDiv )
	{
		
		
		boundingRect['left'] += theDiv.offsetLeft;
		boundingRect['top'] += theDiv.offsetTop;
		boundingRect['right'] += theDiv.offsetLeft;
		boundingRect['bottom'] += theDiv.offsetTop;
		
		theDiv=theDiv.offsetParent;
	}
	
	return boundingRect;
}

<!--- flip menu on/off --->
function fpo( el )  { el.style.backgroundColor='#menuOnColor#'; }
function fpf( el ) { el.style.backgroundColor='#menuOffColor#'; }

function flutter( el, action )
{
	flutterState=-1;
	flutterLength=8;
	flutterSpeed=60;
	flutterElement=el;
	flutterAction=action;
	
	flutterTimeout();
}

function flutterTimeout()
{
	flutterLength--;
	flutterState=-flutterState;

	if( flutterLength==0 )
	{
		documentClick();
		setTimeout("flutterDoAction()", 20 );
	}
	else
	{
		if( flutterState==-1 ) flutterElement.style.backgroundColor='#menuFlutterOnColor#';
		                  else flutterElement.style.backgroundColor='#menuFlutterOffColor#';
		
		setTimeout("flutterTimeout()", flutterSpeed);
	}
}

function flutterDoAction() { eval( flutterAction ); }

function documentClick()
{
	
	var objectMenuDiv = document.getElementById( "ObjectMenu" );
	objectMenuDiv.style.visibility = "hidden";
	hideSubMenus();
	<cfif not IsDefined("url.insertonly")>
	secureTabs();
	</cfif>
}

function secureTabs()
{
	//add more checks here as necessary
	if ((hasPermission( lastSelectedId, #PermNavEdit#) > 0) && parent.document.getElementById('siteEditEdit')) 
		parent.document.getElementById('siteEditEdit').style.display = 'inline';
	else if (parent.document.getElementById('siteEditEdit'))	
		parent.document.getElementById('siteEditEdit').style.display = 'none';
	//This will display the container tab if we are dealing with a dmHTML object	
	
	if (objects[lastSelectedId] && objects[lastSelectedId]['TYPENAME'].toLowerCase()=='dmhtml')
	{
		
		if ((hasPermission(lastSelectedId,#permContainerManagement#) > 0) && parent.document.getElementById('siteEditRules'))
			parent.document.getElementById('siteEditRules').style.display = 'inline';
		else	
			parent.document.getElementById('siteEditRules').style.display = 'none';		
	}	
	
	else if (parent.document.getElementById('siteEditRules'))
		parent.document.getElementById('siteEditRules').style.display = 'none';		
		
		
		
}		

function hideSubMenus()
{
	for( var item in objectMenu )
	{
	 	var temp = objectMenu[item].submenu;
		
		if( temp )
		{
			var theMenuDiv = document.getElementById( temp+"Menu" );
			if( theMenuDiv ) theMenuDiv.style.visibility = "hidden";
		}
	}
}

function showEditTabs (tabType, objectid, activeTab)
{
	var elList, i;
	var curList, newList;
   // Set current active link to non active
 
  elList = parent.document.getElementsByTagName("A");
  for (i = 0; i < elList.length; i++)

    // Check if the id contains the tabtype and make tab visible
	
	if (elList[i].id)
	{
		
		if (elList[i].id.indexOf(tabType)!= -1) 
		{
		    elList[i].style.visibility = 'visible'; 
			elList[i].style.zindex = 1; 
			
			// break href into 2 bits, one the file and one the object parameter
			  newList = new Array();
			  curList = elList[i].href.split("=");
			  elList[i].href = curList[0] + "=" + objectid; 
			  
			// set tab to active
			if(elList[i].href.indexOf(activeTab)!=-1)
			{
				elList[i].className = "activesubtab";}
				else {
				elList[i].className = "subtab";
			}
		}
	}
}

document.body.onclick = documentClick;
</script>

<STYLE TYPE="text/css">
	##idServer { 
		position:relative; 
		width: 400px; 
		height: 200px; 
		display:none;
	}
</STYLE>

<IFRAME WIDTH="100" HEIGHT="1" NAME="idServer" ID="idServer" 
	 FRAMEBORDER="0" FRAMESPACING="0" MARGINWIDTH="0" MARGINHEIGHT="0">
		<ILAYER NAME="idServer" WIDTH="400" HEIGHT="100" VISIBILITY="Hide" 
		 ID="idServer">
		<P>This page uses a hidden frame and requires either Microsoft 
		Internet Explorer v4.0 (or higher) or Netscape Navigator v4.0 (or 
		higher.)</P>
		</ILAYER>
</IFRAME>

<!--- now go through each unparented node and generate a div for it --->
<cfloop index="objId" list="#rootObjectId#">
	<div id="#objId#_root">
	</div>
	<script>
	renderObjectToDiv( '#objId#', '#objId#_root' );
	toggleObject( '#objId#' );
	</script>
</cfloop>



</cfoutput>

<cfsetting enablecfoutputonly="No">



