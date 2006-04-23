<!--- createDraftObject.cfm 

Creates a draft object

--->

<cfsetting enablecfoutputonly="no">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfoutput>
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/navajo/navajo_popup.css">
</cfoutput>


<cfparam name="url.objectId" default="">

<cfif len(url.objectId)>
	<!--- Get this object so we can duplicate it --->
	<q4:contentobjectget objectid="#url.objectId#" bactiveonly="False" r_stobject="stObject">
	
	<cfscript>
		stProps=structCopy(stObject);
		stProps.objectid = createUUID();
		stProps.lastupdatedby = session.dmSec.authentication.userlogin;
		stProps.datetimelastupdated = Now();
		stProps.createdby = session.dmSec.authentication.userlogin;
		stProps.datetimecreated = Now();
		// dmHTML specific props
		//stProps.displayMethod = "display";
		stProps.status = "draft";
		//dmNews specific props
		stProps.publishDate = now();
		stProps.expiryDate = now();
		stProps.versionID = URL.objectID;

		//is this a custom type?
		if(application.types[stProps.typename].bCustomType)
			packagePath = application.customPackagePath;
		else
			packagePath = application.packagePath;
		// create the new OBJECT 
		oType = createobject("component","#packagepath#.types.#stProps.TypeName#");
		stNewObj = oType.createData(stProperties=stProps);
		NewObjId = stNewObj.objectid;
		oAuthentication = request.dmSec.oAuthentication;	
		stuser = oAuthentication.getUserAuthenticationData();
		application.factory.oaudit.logActivity(objectid="#URL.objectid#",auditType="Create", username=StUser.userlogin, location=cgi.remote_host, note="Draft object created");
	</cfscript>

	<cfoutput>
	<script>
		window.location="#application.url.farcry#/navajo/edit.cfm?objectId=#NewObjID#&type=#stProps.typename#<cfif isDefined('url.finishUrl')>&finishUrl=#url.finishUrl#</cfif>";
	</script>
	</cfoutput>
</cfif>

