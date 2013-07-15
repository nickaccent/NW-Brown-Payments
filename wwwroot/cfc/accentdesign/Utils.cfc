<!---
	Utils.cfc
	Created By:	Craig Vincent
	Purpose:		Pre-defined standard server-side validation checks
	Created:		23:25 18/05/2010
	Updated:		16:56 25/05/2010
--->
<cfcomponent 
	displayname="Utils"
	hint="Helper cfc to provide helper functions to the application."
	output="false">

	<cfset VARIABLES.version = "1.0" />
	<cfset VARIABLES.initialised = now() />
	
	<cffunction name="getVersion" output="false" hint="returns the version of this instance of validation.cfc"><cfreturn VARIABLES.Version /></cffunction>

	<cffunction name="JSONResponse" hint="" output="true">
		<cfargument name="Response" type="struct" required="true" />
		<cfargument name="CallBack" type="string" required="false" default="" />

		<cfif CallBack is not "">
			<cfcontent reset="true" type="application/json">#CallBack#(#SerializeJSON(ARGUMENTS.Response)#)<cfabort />
		<cfelse>
			<cfcontent reset="true" type="application/json">#SerializeJSON(ARGUMENTS.Response)#<cfabort />
		</cfif>
	</cffunction>
	
	<cffunction name="getHTTPHeader" hint="" output="false">
		<cfargument name="HeaderField" />
		<cftry>
			<cfreturn GetHttpRequestData().headers[ARGUMENTS.HeaderField] />
			<cfcatch>
				<cfreturn "" />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- Determines if a date is a working day (but doesn't take into account holidays) --->
	<cffunction name="IsWorkingDay" access="public" returntype="boolean" output="no">
		<cfargument name="date" required="yes" type="date" />
		<cfargument name="WorkingDays" default="2,3,4,5,6" />
		<cfreturn ListFind(ARGUMENTS.WorkingDays, DayOfWeek(ARGUMENTS.date)) />
	</cffunction>
	
	<cffunction name="WorkingDateAdd" access="public" returntype="string" output="No">
		<cfargument name="number" required="yes"  type="numeric">
		<cfargument name="date"  required="yes"  type="date">
		<cfargument name="SatOFF" required="No"  type="boolean" default="Yes">
		<cfargument name="SunOFF" required="No"  type="boolean" default="Yes">
		<!--- <cfargument name="holidays" required="No"  type="string" default="Jan/19/2009, Feb/16/2009, May/10/2009, May/25/2009, Jun/21/2009, Sep/7/2009, Oct/12/2009, Nov/26/2009, Apr/10/2009, Apr/12/2009, Jan/19/2015, Feb/16/2015, May/10/2015, May/25/2015, Jun/21/2015, Sep/7/2015, Oct/12/2015, Nov/26/2015, Apr/3/2015, Apr/5/2015, Jan/20/2014, Feb/17/2014, May/11/2014, May/26/2014, Jun/15/2014, Sep/1/2014, Oct/13/2014, Nov/27/2014, Apr/18/2014, Apr/20/2014, Jan/21/2013, Feb/18/2013, May/12/2013, May/27/2013, Jun/16/2013, Sep/2/2013, Oct/14/2013, Nov/28/2013, Mar/29/2013, Mar/31/2013, Jan/16/2012, Feb/20/2012, May/13/2012, May/28/2012, Jun/17/2012, Sep/3/2012, Oct/8/2012, Nov/22/2012, Apr/6/2012, Apr/8/2012, Jan/17/2011, Feb/21/2011, May/8/2011, May/30/2011, Jun/19/2011, Sep/5/2011, Oct/10/2011, Nov/24/2011, Apr/22/2011, Apr/24/2011, Jan/18/2010, Feb/15/2010, May/9/2010, May/31/2010, Jun/20/2010, Sep/6/2010, Oct/11/2010, Nov/25/2010, Apr/2/2010, Apr/4/2010, Jan/18/2016, Feb/15/2016, May/8/2016, May/30/2016, Jun/19/2016, Sep/5/2016, Oct/10/2016, Nov/24/2016, Mar/25/2016, Mar/27/2016,">  --->
		<cfargument name="holidays" required="No"  type="string" default="" />
		<!--- reformat date list --->
		<cfset local.FormatDateList = "">
		<cfloop list="#arguments.holidays#" index="i">
			<cfset local.FormatDateList = ListAppend(local.FormatDateList,dateformat(i,'yyyymd'))>
		</cfloop> 
		<cfset local.extradays  = 0>
		<cfset local.today  = arguments.date>
		<cfif arguments.number gt 0>
			<cfset local.d  = 1>
		<cfelse>
			<cfset local.d  = -1>
		</cfif> 
		<!--- loop over 100 years maximum --->
		<cfloop from="1" to="36000" index="i">
			<cfif local.extradays eq arguments.number>
				<cfbreak>
			</cfif>
			<cfset local.today  = dateadd('d',local.today,local.d)>
			<cfset local.DofW = DayOfWeek(local.today)>
			<cfif not ( ListFind(local.FormatDateList,dateformat(local.today,'yyyymd')) or 
				(YesNoFormat(arguments.SatOFF) and local.DofW eq 7) or
				(YesNoFormat(arguments.SunOFF) and local.DofW eq 1)
			)>
				<cfset local.extradays = local.extradays+local.d>
			</cfif>
		</cfloop>
		<cfreturn local.today>
	</cffunction>
	
	<cffunction name="timeDiffInWords" hint="returns a textual representation of how long ago a date was" access="public" returntype="string" output="false">
		<cfargument name="oDate" required="yes" type="date">
		<cfset var currentTime = now()>
		<cfset var referenceDate = arguments.oDate>
		<cfset var difference = dateDiff('n',referenceDate, currentTime)>

		<!--- Hours & Minutes--->
		<cfset minuts = difference>
		<cfset hrs = dateDiff('h',referenceDate, currentTime)>
		<cfset currentMinuts = minuts - (hrs*60)>

		<cfif hrs eq 1>
			<cfset textDifference = hrs&' hour ago'>
		<cfelseif currentMinuts eq 0>
			<cfset secs = dateDiff('s',referenceDate, currentTime)>
			<!--- <cfset textDifference = '#secs# seconds ago' /> --->
			<cfif secs LTE 10>
				<cfset textDifference = 'just now'>
			<cfelse>
				<cfset textDifference = 'less than a minute ago'>
			</cfif>
		<cfelseif hrs eq 0>
			<cfset textDifference = currentMinuts&' mins ago'>
		<cfelse>
			<cfset textDifference = hrs&' hours ago'>
		</cfif>

		<cfset datadifference = textDifference>

		<!--- Days --->
		<cfset difference = dateDiff('d',referenceDate,currentTime) >
		<cfif difference gt 0>
			<cfif difference eq 1>
				<cfset textDifference = ' day ago'>
			<cfelse>
				<cfset textDifference = ' days ago'>
			</cfif>
			<cfset datadifference = difference&textDifference>
		</cfif>
		<cfreturn datadifference>
	</cffunction>
	
	<cfscript>
	/**
	 * Removes HTML from the string.
	 * v2 - Mod by Steve Bryant to find trailing, half done HTML.        
	 * v4 mod by James Moberg - empties out script/style blocks
	 * 
	 * @param string      String to be modified. (Required)
	 * @return Returns a string. 
	 * @author Raymond Camden (ray@camdenfamily.com) 
	 * @version 4, October 4, 2010 
	 */
	function stripHTML(str) {
		str = reReplaceNoCase(str, "<*style.*?>(.*?)</style>","","all");
		str = reReplaceNoCase(str, "<*script.*?>(.*?)</script>","","all");

		str = reReplaceNoCase(str, "<.*?>","","all");
		//get partial html in front
		str = reReplaceNoCase(str, "^.*?>","");
		//get partial html at end
		str = reReplaceNoCase(str, "<.*$","");
		return trim(str);
	}
	</cfscript>
		
</cfcomponent>