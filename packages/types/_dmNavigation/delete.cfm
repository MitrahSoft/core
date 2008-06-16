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
$Header: /cvs/farcry/core/packages/types/_dmnavigation/delete.cfm,v 1.12 2005/04/21 06:23:53 paul Exp $
$Author: paul $
$Date: 2005/04/21 06:23:53 $
$Name: milestone_3-0-1 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: Specific delete method for dmNavigation. Deletes all descendants aswell as cleaning up verity collections$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>

	// get descendants
	qGetDescendants = application.factory.oTree.getDescendants(objectid=stObj.objectID);
	oNavigation = createObject("component", application.types.dmNavigation.typePath);
	
	// delete actual object
	super.delete(stObj.objectId);
	
	// delete fu
	if (application.config.plugins.fu) {
		fuUrl = application.factory.oFU.getFU(objectid=stObj.objectid);
		application.factory.oFU.deleteFu(fuUrl);
	}
	
	// delete branch
	application.factory.oTree.deleteBranch(objectid=stObj.objectID);
	
	// remove permissions
	application.factory.oAuthorisation.deletePermissionBarnacle(objectid=stObj.objectID);
	
	// check for associated objects 
	if(structKeyExists(stObj,"aObjectIds") and arrayLen(stObj.aObjectIds)) {

		// loop over associated objects
		for(i=1; i LTE arrayLen(stObj.aObjectIds); i=i+1) {
			
			// work out typename
			objType = findType(stObj.aObjectIds[i]);
			if (len(objType)) {
				// delete associated object
				oType = createObject("component", application.types[objType].typePath);
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
					if (len(objType)) {
						// delete associated object
						oType = createObject("component", application.types[objType].typePath);
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
			application.factory.oAuthorisation.deletePermissionBarnacle(objectid=qGetDescendants.objectId[loop0]);
			
			// delete descendant
			super.delete(qGetDescendants.objectId[loop0]);	
		
		}
	}
	
	// check if in verity collection
	
	// delete from verity
</cfscript>