<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
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
<cfprocessingdirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/admin" prefix="admin">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<!--- get sections --->
<cfset stWebtop = application.factory.oWebtop.getAllItems()>

<!--- init variables from id --->
<cfif structKeyExists(url, "id")>
	<cfset i = listLen(url.id, ".")>
	<cfparam name="url.sec" default="#listGetAt(url.id, 1, ".")#">
	<cfif i gte 2>
		<cfparam name="url.sub" default="#listGetAt(url.id, 2, ".")#">
	</cfif>
	<cfif i gte 3>
		<cfparam name="url.menu" default="#listGetAt(url.id, 3, ".")#">
	</cfif>
	<cfif i gte 4>
		<cfparam name="url.menuitem" default="#listGetAt(url.id, 4, ".")#">
	</cfif>
</cfif>

<!--- default section / subsection / menu --->
<cfparam name="url.sec" default="#listfirst(stWebtop.childorder)#">
<cfparam name="url.sub" default="">
<cfparam name="url.menu" default="">
<cfparam name="url.menuitem" default="">
<cfif structKeyExists(stWebtop, "children") and structKeyExists(stWebtop.children, url.sec)>
	<cfif NOT len(url.sub)>
		<cfset url.sub = listfirst(stWebtop.children[url.sec].childorder)>		
	</cfif>
	<cfif structKeyExists(stWebtop.children[url.sec], "children") and structKeyExists(stWebtop.children[url.sec].children, url.sub)>
		<cfif NOT len(url.menu)>
			<cfset url.menu = listfirst(stWebtop.children[url.sec].children[url.sub].childorder)>
		</cfif>
	</cfif>
</cfif>

<!--- rebuild url.id --->
<cfset url.id = url.sec>
<cfif len(url.sub)>
	<cfset url.id = listAppend(url.id, url.sub, ".")>
</cfif>
<cfif len(url.menu)>
	<cfset url.id = listAppend(url.id, url.menu, ".")>
</cfif>
<cfif len(url.menuitem)>
	<cfset url.id = listAppend(url.id, url.menuitem, ".")>
</cfif>



<cfparam name="url.objectid" default="">
<cfparam name="url.typename" default="dmHTML">
<cfparam name="url.view" default="webtopPageStandard">
<cfparam name="url.bodyView" default="webtopBody">

<!--- determine which body view to use --->
<!--- 
match attributes, in priority order:
- content
- link
- typename + webskin (optional: + view)
 --->

<cfset bodyInclude = application.factory.oWebtop.getItemBodyInclude(stWebtop, url.id)>


<!--- show standard webtop page --->

	<skin:viewlite typename="#url.typename#" webskin="#url.view#" bodyInclude="#bodyInclude#" />


<cfsetting enablecfoutputonly="false">