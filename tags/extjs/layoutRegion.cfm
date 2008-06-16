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
<!--- @@displayname: extjs Layout Region Div --->
<!--- @@description: Places a Layout Region Div on the page.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>


<cfparam name="attributes.id" default="layoutRegion#randRange(1,9999999)#" />
<cfparam name="attributes.title" default="" />
<cfparam name="attributes.class" default="" />
<cfparam name="attributes.style" default="" />

<!------------------ 
START TAG
 ------------------>
<cfif thistag.executionMode eq "start">
<cfoutput>
<div id="#attributes.id#" class="#attributes.class#" style="#attributes.style#">
</cfoutput>
</cfif>


<cfif thistag.executionMode eq "End">
<cfoutput>
</div>
</cfoutput>
</cfif>


<cfsetting enablecfoutputonly="false">