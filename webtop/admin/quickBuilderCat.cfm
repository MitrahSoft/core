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
$Header: /cvs/farcry/core/webtop/admin/quickBuilderCat.cfm,v 1.2 2005/05/30 07:35:15 pottery Exp $
$Author: pottery $
$Date: 2005/05/30 07:35:15 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Quickly builds a category structure$
$TODO:$

|| DEVELOPER ||
$Developer: Quentin Zervaas (quentin@mitousa.com) $
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />


<!--- character to indicate levels --->
<cfset levelToken = "-" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="developer">
	<cfif isDefined("form.submit")>
	    <cfscript>
		    aliasDelimiter = "||";
	        startPoint = form.startPoint;
	        makenavaliases = isDefined("form.makenavaliases") and form.makenavaliases;
	        if (makenavaliases)navaliaseslevel = form.navaliaseslevel;
	
	        structure = form.structure;
	
	        lines = listToArray(structure, "#chr(13)##chr(10)#");
	
	        // setup items with their level and objectids
	        items = arrayNew(1);
	        lastlevel = 1;
	
	        for (i = 1; i lte arraylen(lines); i = i + 1) {
	            prefix = spanIncluding(lines[i], levelToken);
	            prefixLen = len(prefix);
	
	            line = lines[i];
	            lineLen = len(line);
	
	            level = prefixLen + 1;
	            if (level gt lastlevel)
	                level = lastlevel + 1;
	            title = trim(right(lines[i], lineLen - prefixLen));
	
	            if (len(title) gt 0) {
	                item = structNew();
	                //item.title = ReplaceNoCase(title, "'", "''", "ALL");
	                item.title = listFirst(title,aliasDelimiter);
	                if(listLen(title,aliasDelimiter) eq 2){
	                	item.navAlias = lcase(replace(trim(listLast(title,aliasDelimiter))," ","_","ALL"));
	                }
	                else item.navAlias = "";
	                item.level = level;
	                item.objectid = createuuid();
	                item.parentid = '';
	                arrayAppend(items, item);
	                lastlevel = item.level;
	            }
	        }
	
	        parentstack = arrayNew(1);
	        navstack = arrayNew(1);
	        arrayAppend(parentstack, startPoint);
	
	        // now figure out each item's parent node
	        lastlevel = 0;
	        for (i = 1; i lte arraylen(items); i = i + 1) {
	            if (items[i].level lt lastlevel) {
	                diff = lastlevel - items[i].level;
	                for (j = 0; j lte diff; j = j + 1) {
	                    arrayDeleteAt(parentstack, arraylen(parentstack));
	                    arrayDeleteAt(navstack, arraylen(navstack));
	                }
	            }
	            else if (items[i].level eq lastlevel) {
	                arrayDeleteAt(parentstack, arraylen(parentstack));
	                arrayDeleteAt(navstack, arraylen(navstack));
	            }
	
	            items[i].parentid = parentstack[arraylen(parentstack)];
	
	            arrayAppend(parentstack, items[i].objectid);
	
	            navtitle = lcase(rereplacenocase(items[i].title, "\W+", "_", "all"));
	            arrayAppend(navstack, rereplace(navtitle, "_+", "_", "all"));
	
	            if (makenavaliases) {
	                if (navaliaseslevel eq 0 or items[i].level lte navaliaseslevel)
	                    items[i].lNavIDAlias = arrayToList(navstack, '_');
	                else
	                    items[i].lNavIDAlias = '';
	
	            }
	            else
	                items[i].lNavIDAlias = '';
	
	            lastlevel = items[i].level;
	        }
			
	        // now finish setting up the structure of each item
	        for (i = 1; i lte arraylen(items); i = i + 1) {
	            structDelete(items[i], "level");
	        }
	    </cfscript>
	
	    <cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">		
	    <cfscript>
	        o_farcrytree = createObject("component", "#application.packagepath#.farcry.tree");
	        oCat = createObject("component", "#application.packagepath#.farcry.category");
	
	        for (i = 1; i lte arraylen(items); i = i + 1) {
	            oCat.addCategory(dsn=application.dsn,parentID=items[i].parentID,categoryID=items[i].objectID,categoryLabel=items[i].title);
	            if (len(items[i].lNavIDAlias) and len(items[i].navAlias) eq 0){oCat.setAlias(categoryid=items[i].objectID,alias=lcase(replace(trim(items[i].title)," ","_","ALL")));}
	            else if(len(items[i].navAlias) GT 0){oCat.setAlias(categoryid=items[i].objectID, alias=items[i].navAlias);}
	        }
	    </cfscript>
	
	    <cfoutput>
	        <div class="formTitle">#application.rb.getResource("catTreeQuickBuilder")#</div>
	        <p>
	            #application.rb.getResource("followingItemsCreated")#
	        </p>
	        <ul>
				<cfset subS=listToArray('#arrayLen(items)#,"Category"')>
				<li>#application.rb.formatRBString("objects",subS)#</li>
	        </ul>
	    </cfoutput>
	<cfelse>
	
	    <cfscript>
	        o = createObject("component", "#application.packagepath#.farcry.tree");
	        qNodes = o.getDescendants(dsn=application.dsn, objectid=application.catid.root);
	    </cfscript>
		
	<cfoutput>
	<script language="JavaScript">
	    function updateDisplayBox()
	    {
	        document.theForm.displayMethod.disabled = !document.theForm.makehtml.checked;
	    }
	
	    function updateNavTreeDepthBox()
	    {
	        document.theForm.navaliaseslevel.disabled = !document.theForm.makenavaliases.checked;
	    }
	</script>

	<form method="post" class="f-wrap-1 f-bg-long wider" action="" name="theForm">
	<fieldset>
	
		<h3>#application.rb.getResource("catTreeQuickBuilder")#</h3>
		
		<label for="startPoint"><b>#application.rb.getResource("createStructureWithin")#</b>
		<select name="startPoint" id="startPoint">
		<option value="#application.catid.root#" selected>#application.rb.getResource("Root")#</option>
		<cfloop query="qNodes">
		<option value="#qNodes.objectId#">#RepeatString("&nbsp;&nbsp;|", qNodes.nlevel)#- #qNodes.objectName#</option>
		</cfloop>
		</select><br />
		</label>
		
		<fieldset class="f-checkbox-wrap">
		
			<b>#application.rb.getResource("navAliases")#</b>
			
			<fieldset>
			
			<label for="makenavaliases">
			<input type="checkbox" name="makenavaliases" id="makenavaliases" checked="checked" value="1" onclick="updateNavTreeDepthBox()" class="f-checkbox" />
			#application.rb.getResource("createNavAliases")#
			</label>
			
			<select name="navaliaseslevel">
	            <option value="0">#application.rb.getResource("all")#</option>
	            <option value="1" selected >1</option>
	            <option value="2">2</option>
	            <option value="3">3</option>
	            <option value="4">4</option>
	            <option value="5">5</option>
	            <option value="6">6</option>
	          </select><br />
	          #application.rb.getResource("levels")#
			  <script>updateNavTreeDepthBox()</script>
			
			</fieldset>
		
		</fieldset>
		
		<label for="levelToken"><b>#application.rb.getResource("levelToken")#</b>
		<select name="levelToken" id="levelToken">
		<option>#levelToken#</option>
		</select><br />
		</label>
		
		<label for="structure"><b>#application.rb.getResource("structure")#</b>
		<textarea name="structure" id="structure" rows="10" cols="40" class="f-comments"></textarea><br />
		</label>
		
		<div class="f-submit-wrap">
		<input type="submit" value="#application.rb.getResource("buildSiteStructure")#" name="submit" class="f-submit" /><br />
		</div>
		
	</fieldset>
	</form>
	
	<hr />

	<h4>#application.rb.getResource("instructions")#</h4>
	<p>
	#application.rb.getResource("quicklyBuildFarCrySiteBlurb")#
	</p>
	
	<hr />
	
	<h4>#application.rb.getResource("example")#</h4>
	<p>
	<pre>
	Item 1
	-Item 1.2
	--Item 1.2.1
	-Item 1.3
	Item 2
	-Item 2.1
	--Item 2.2
	Item 3
	</pre>
	</p>
	
	<p>
	#application.rb.getResource("visualPurposesBlurb")#
	</p>
	
	<p>
	<pre>
	Item 1
	- Item 1.2
	-- Item 1.2.1
	</pre>
	</p>
	
	</cfoutput>
	</cfif>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">
