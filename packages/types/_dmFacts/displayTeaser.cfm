<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFacts/displayTeaser.cfm,v 1.2 2003/09/10 23:46:11 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:46:11 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmFacts default displayTeaser method$
$TODO: $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
--->

<cfoutput>
<li><a href="#application.url.farcry#/navajo/display.cfm" class="teaserHeader">#stObj.title#</a>&nbsp;<span class="newsTeaserDate">#dateformat(stObj.PUBLISHDATE,'DD/MM/YY')#</span></li>
</cfoutput>