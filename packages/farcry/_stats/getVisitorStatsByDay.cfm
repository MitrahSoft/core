<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getVisitorStatsByDay.cfm,v 1.6 2003/09/12 02:59:21 brendan Exp $
$Author: brendan $
$Date: 2003/09/12 02:59:21 $
$Name: b201 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: get visitor stats $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- run the query to get counts of user activity by hour --->
<cfswitch expression="#application.dbtype#">
<cfcase value="ora">
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByDay">
		select distinct hour, TO_CHAR(fq.logdatetime,'hh') as loginhour, count(distinct sessionId) as count_Ip
		from #application.dbowner#statsHours
		left join (
				select * from stats
		)fq on TO_CHAR(fq.logdatetime,'hh') = statsHours.hour
		and TO_CHAR(fq.logdatetime,'dd' ) = #DatePart("d", arguments.day)# and TO_CHAR(fq.logdatetime,'mm') = #DatePart("m", arguments.day)# and TO_CHAR(fq.logdatetime,'yyyy') = #DatePart("yyyy", arguments.day)#
		group by hour, TO_CHAR(fq.logdatetime,'hh')
		order by 1 
	</cfquery>	
</cfcase>

<cfcase value="mysql">
	<!--- create temp table --->
	<cfquery datasource="#arguments.dsn#" name="temp">
		DROP TABLE IF EXISTS tblTemp1
	</cfquery>
	<cfquery datasource="#arguments.dsn#" name="temp2">
		create temporary table `tblTemp1`
			(
			`LOGID`  VARCHAR(255) NOT NULL ,
			`SESSIONID`  VARCHAR(255) NOT NULL ,
			`LOGDATETIME` DATETIME NOT NULL
			)
	</cfquery>
	<cfquery datasource="#arguments.dsn#" name="temp3">
		INSERT INTO tblTemp1 (LOGID,LOGDATETIME,SESSIONID) 
			SELECT LOGID, LOGDATETIME, SESSIONID FROM #application.dbowner#stats 
	</cfquery>
	<!--- do main query --->
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByDay">
		select distinct hour, HOUR(fq.logdatetime) as loginhour, count(distinct sessionId) as count_Ip
		from #application.dbowner#statsHours
		left join tblTemp1 fq on HOUR(fq.logdatetime) = statsHours.hour
		and DAYOFMONTH(fq.logdatetime) = #DatePart("d", arguments.day)# and MONTH(fq.logdatetime) = #DatePart("m", arguments.day)# and YEAR(fq.logdatetime) = #DatePart("yyyy", arguments.day)#
		group by hour, loginhour
		order by 1 
	</cfquery>
</cfcase>

<cfdefaultcase>
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByDay">
		select distinct hour, count(distinct sessionId) as count_Ip, datepart(hh, fq.logdatetime) as loginhour
		from #application.dbowner#statsHours
		left join (
				select * from stats
		)fq on datepart(hh, fq.logdatetime) = statsHours.hour
		and datepart(dd, fq.logdatetime) = #DatePart("d", arguments.day)# and datepart(mm, fq.logdatetime) = #DatePart("m", arguments.day)# and datepart(yyyy, fq.logdatetime) = #DatePart("yyyy", arguments.day)#
		group by hour, datepart(hh, fq.logdatetime)
		order by 1 ;
	</cfquery>
</cfdefaultcase>
</cfswitch>