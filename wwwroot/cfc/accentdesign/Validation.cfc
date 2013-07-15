<!---
	Validation.cfc
	Created By:	Craig Vincent
	Purpose:		Pre-defined standard server-side validation checks
	Created:		23:25 18/05/2010
	Updated:		16:56 25/05/2010
--->
<cfcomponent 
	displayname="Validation"
	hint="Helper cfc to provide standard <em>pre-defined</em> validation rules across a system/website."
	output="false">

	<cfset VARIABLES.version = "1.02" />
	<cfset VARIABLES.initialised = now() />
	
	<cffunction name="required" output="false" hint="check if string is empty" returntype="boolean">
		<cfargument name="str" default="" hint="the string to test" />
		<cfreturn trim(ARGUMENTS.str) is not "" />
	</cffunction>
	
	<cffunction name="longerThan" output="false" hint="string must be longer than x chars">
		<cfargument name="str" required="true" hint="the string to test" />
		<cfargument name="length" required="true" hint="the minimum length (exclusive of)">
		<cfreturn len(ARGUMENTS.str) GT ARGUMENTS.length />
	</cffunction>
	
	<cffunction name="lessThan" output="false" hint="string must be less than x chars">
		<cfargument name="str" required="true" hint="the string to test" />
		<cfargument name="length" required="true" hint="the max length (inclusive of)">
		<cfreturn len(ARGUMENTS.str) LTE ARGUMENTS.length />
	</cffunction>
	
	<cffunction name="identical" output="false" hint="checks two strings are the same">
		<cfargument name="str1" required="true" type="string" />
		<cfargument name="str2" required="true" type="string" />
		<cfreturn ARGUMENTS.str1 EQ ARGUMENTS.str2 />
	</cffunction>
	
	<cffunction name="date" output="false" hint="check date for validity" returntype="boolean">
		<cfargument name="str" required="true" hint="date string to be checked" />
		<cfargument name="yearlength" default="2" type="numeric" hint="whether to test for 2 or 4 digit year (useful for DOBs)" />
		<cfargument name="required" default="true" type="boolean" />
		<cfargument name="minDate" type="date" hint="the earliest date that would be classed as valid" />
		<cfargument name="maxDate" type="date" hint="the latest date that would be classed as valid" />
		
		<cfset var d = "" />
		
		<!--- return true if not required and passed string is empty --->
		<cfif NOT ARGUMENTS.required AND NOT len(trim(ARGUMENTS.str))>
			<cfreturn true />
		</cfif>
		
		<cftry>
			<cfset d = LSParseDateTime(ARGUMENTS.str) />
			<cfcatch>
				<cfreturn false />
			</cfcatch>
		</cftry>
		
		<!--- check date is not earlier than the minimum date --->
		<cfif structKeyExists(ARGUMENTS, "minDate")>
			<cfif dateCompare(d, ARGUMENTS.minDate, "d") LTE 0>
				<cfreturn false>
			</cfif>
		</cfif>
		
		<!--- check date is not after the maximum date --->
		<cfif structKeyExists(ARGUMENTS, "maxDate")>
			<cfif dateCompare(d, ARGUMENTS.maxDate, "d") GT 0>
				<cfreturn false>
			</cfif>
		</cfif>

		<cfreturn NOT NOT ReFind("[0-9]{2}/[0-9]{2}/[0-9]{#ARGUMENTS.YearLength#}", ARGUMENTS.str) />
	</cffunction>
	
	<cffunction name="dateOfBirth" output="false" hint="checks format of a DOB">
		<cfreturn date(ARGUMENTS.str, 4, dateAdd("yyyy", -120, now()), now()) />
	</cffunction>
	
	<cffunction name="email" output="false" hint="check for valid email address">
		<cfargument name="str" required="true" hint="the string to test" />
		<cfreturn ReFindnocase("[a-z0-9!##$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!##$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", ARGUMENTS.str) />
	</cffunction>
	
	<cffunction name="getVersion" output="false" hint="returns the version of this instance of validation.cfc"><cfreturn VARIABLES.Version /></cffunction>
	
	<!--- Deprecated Methods Below. --->
	<cffunction name="validateDate" output="false" hint="check date for validity" returntype="boolean">
		<cfreturn date(argumentCollection=ARGUMENTS) />
	</cffunction>
	
	<cffunction name="validateDateOfBirth" hint="check date is valid DOB of format (dd/mm/yyyy)" returntype="boolean">
		<cfargument name="str" required="true" hint="the DOB to test" />
		<cfreturn dateOfBirth(argumentCollection=ARGUMENTS) />
	</cffunction>
		
</cfcomponent>