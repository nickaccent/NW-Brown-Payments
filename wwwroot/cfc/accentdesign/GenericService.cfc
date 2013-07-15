<cfcomponent displayname="provides common functions to all bean-style objects" output="false">

	<cfset VARIABLES.ValidationErrors = new AccentDesign.ValidationList() />

	<cffunction name="get"></cffunction>

	<cffunction name="save"></cffunction>
	
	<cffunction name="delete"></cffunction>

	<cffunction name="validate" hint="validates the inputs against a fixed set of criteria, usually to be used before a save()" access="public" output="false" returntype="AccentDesign.ValidationList">
		<cfreturn VARIABLES.ValidationErrors />
	</cffunction>

</cfcomponent>