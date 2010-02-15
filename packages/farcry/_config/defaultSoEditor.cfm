<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_config/defaultSoEditor.cfm,v 1.6 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: p300_b113 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: deploys soEditor config file $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfset stStatus = StructNew()>
<cfset stConfig = StructNew()>
<cfset aTmp = ArrayNew(1)>

<cfscript>
stConfig.width = "100%"; 
stConfig.height = "80%"; 
stConfig.cols = "60"; 
stConfig.rows = "10"; 
stConfig.pageedit = "false"; 
stConfig.singlespaced = "false"; 
stConfig.wordcount = "false"; 
stConfig.baseurl = "http://#cgi.HTTP_HOST#/#application.url.webroot#"; 
stConfig.basefont = ""; 
stConfig.basefontsize = ""; 
stConfig.basefontcolor = ""; 
stConfig.basebgcolor = ""; 
stConfig.validateonsave = "false"; 
stConfig.validationmessage = ""; 
stConfig.showborders = "false"; 
stConfig.initialfocus = "false"; 
stConfig.new = "false"; 
stConfig.save = "false"; 
stConfig.cut = "true"; 
stConfig.copy = "true"; 
stConfig.paste = "true"; 
stConfig.delete = "true"; 
stConfig.find = "true"; 
stConfig.undo = "true"; 
stConfig.redo = "true"; 
stConfig.hr = "true"; 
stConfig.image = "true"; 
stConfig.link = "true"; 
stConfig.unlink = "true"; 
stConfig.spellcheck = "false"; 
stConfig.help = "true"; 
stConfig.align = "true"; 
stConfig.list = "true"; 
stConfig.unindent = "true"; 
stConfig.indent = "true"; 
stConfig.fontdialog = "true"; 
stConfig.format = "true"; 
stConfig.formatlist = "none,h1,h2,h3,h4,h5,h6,pre"; 
stConfig.formatlistlabels = "Normal,Heading 1,Heading 2,Heading 3,Heading 4,Heading 5,
				Heading 6,Formatted"; 
stConfig.font = "false"; 
stConfig.fontlist = "Arial,Tahoma,Courier New,Times New Roman,Verdana,Wingdings"; 
stConfig.fontlistlabels = "Arial,Tahoma,Courier New,Times New Roman,Verdana,Wingdings"; 
stConfig.size = "false"; 
stConfig.sizelist = "1,2,3,4,5,6,7"; 
stConfig.sizelistlabels = "1,2,3,4,5,6,7"; 
stConfig.bold = "true"; 
stConfig.italic = "true"; 
stConfig.underline = "true"; 
stConfig.superscript = "true"; 
stConfig.fgcolor = "true"; 
stConfig.bgcolor = "true"; 
stConfig.tables = "true"; 
stConfig.insertcell = "true"; 
stConfig.deletecell = "true"; 
stConfig.insertrow = "true"; 
stConfig.deleterow = "true"; 
stConfig.insertcolumn = "true"; 
stConfig.deletecolumn = "true"; 
stConfig.splitcell = "true"; 
stConfig.mergecell = "true"; 
stConfig.cellprop = "true"; 
stConfig.htmledit = "true"; 
stConfig.borders = "true"; 
stConfig.details = "true"; 
</cfscript>

<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
<cftry>
	<cfquery datasource="#arguments.dsn#" name="qDelete">
		delete from #application.dbowner#config
		where configname = '#arguments.configName#'
	</cfquery>
	
	<!--- bowden1. changed to use cfqueryparam and clob for ora --->
	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
	   <cfquery datasource="#arguments.dsn#" name="qUpdate">
		INSERT INTO #application.dbowner#config
		(configName, wConfig)
		VALUES
		('#arguments.configName#', 
		   <cfqueryparam value='#wConfig#'  cfsqltype="cf_sql_clob" />
             )
	   </cfquery>
	</cfcase>
	<cfdefaultcase>
	   <cfquery datasource="#arguments.dsn#" name="qUpdate">
		INSERT INTO #application.dbowner#config
		(configName, wConfig)
		VALUES
		('#arguments.configName#', '#wConfig#' )
	   </cfquery>
	</cfdefaultcase>
	</cfswitch>
	<!--- end of change bowden1 --->
	
	<cfset stStatus.message = "#arguments.configName# created successfully">
	<cfcatch>
		<cfset stStatus.message = cfcatch.message>
		<cfset stStatus.detail = cfcatch.detail>
	</cfcatch>
</cftry>