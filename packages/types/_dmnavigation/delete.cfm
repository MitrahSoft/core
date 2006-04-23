<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmnavigation/delete.cfm,v 1.8 2003/08/20 07:03:13 brendan Exp $
$Author: brendan $
$Date: 2003/08/20 07:03:13 $
$Name: b201 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: Specific delete method for dmNavigation. Deletes all descendants aswell as cleaning up verity collections$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
<cfscript>

	// get descendants
	qGetDescendants = application.factory.oTree.getDescendants(objectid=stObj.objectID);
	oNavigation = createObject("component","#application.packagepath#.types.dmNavigation");
	
	// delete actual object
	deleteData(objectid=stObj.objectId);
	
	// delete fu
	if (application.config.plugins.fu) {
		fuUrl = application.factory.oFU.getFU(objectid=stObj.objectid);
		application.factory.oFU.deleteFu(fuUrl);
	}
	
	// delete branch
	application.factory.oTree.deleteBranch(objectid=stObj.objectID);
	
	// remove permissions
	oAuthorisation = request.dmSec.oAuthorisation;
	oAuthorisation.deletePermissionBarnacle(objectid=stObj.objectID);
	
	// check for associated objects 
	if(structKeyExists(stObj,"aObjectIds") and arrayLen(stObj.aObjectIds)) {

		// loop over associated objects
		for(i=1; i LTE arrayLen(stObj.aObjectIds); i=i+1) {
			
			// work out typename
			objType = findType(stObj.aObjectIds[i]);
			if (application.types[objType].bCustomType) {
				packagepath = application.customPackagepath;
			} else {
				packagepath = application.packagepath;
			}
			
			if (len(objType)) {
				// delete associated object
				oType = createObject("component","#packagepath#.types.#objType#");
				oType.delete(stObj.aObjectIds[i]);
			}
		}
	}

	// loop over descendants
	if (qGetDescendants.recordcount) {
		for(loop0=1; loop0 LTE qGetDescendants.recordcount; loop0=loop0+1) {
			
			//get descendant data
			objDesc = getData(qGetDescendants.objectId[loop0]);
			
			// delete associated descendants
			if (arrayLen(objDesc.aObjectIds)) {
		
				// loop over associated objects
				for(i=1; i LTE arrayLen(objDesc.aObjectIds); i=i+1) {
				
					// work out typename
					objType = findType(objDesc.aObjectIds[i]);
					if (application.types[objType].bCustomType) {
						packagepath = application.customPackagepath;
					} else {
						packagepath = application.packagepath;
					}
					
					if (len(objType)) {
						// delete associated object
						oType = createObject("component","#packagepath#.types.#objType#");
						oType.delete(objDesc.aObjectIds[i]);
					}
				}
			}
			
			// delete fu
			if (application.config.plugins.fu) {
				fuUrl = application.factory.oFU.getFU(objectid=qGetDescendants.objectId[loop0]);
				application.factory.oFU.deleteFu(fuUrl);
			}
			
			// remove permissions
			oAuthorisation.deletePermissionBarnacle(objectid=qGetDescendants.objectId[loop0]);
			
			// delete descendant
			deleteData(qGetDescendants.objectId[loop0]);	
		
		}
	}
	
	// check if in verity collection
	
	// delete from verity
</cfscript>