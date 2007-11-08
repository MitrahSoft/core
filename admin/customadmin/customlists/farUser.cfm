<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION ||
$Description: Permission administration. $

|| DEVELOPER ||
$Developer: Blair McKenzie (blair@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="User Admin" />

<ft:objectadmin 
	typename="farUser"
	permissionset="news"
	title="User Administration"
	columnList="userid,userstatus" 
	sortableColumns="userid,userstatus"
	lFilterFields="userid"
	sqlorderby="userid asc" />

<admin:footer />