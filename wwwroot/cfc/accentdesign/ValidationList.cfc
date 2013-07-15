<cfcomponent displayname="validationList" namespace="Validation" hint="Stores a list of validation errors" output="false">

	<cfset this.errors = QueryNew("displayorder, fieldName, message", "integer, Varchar, Varchar")>

	<cffunction access="public" name="getErrors" displayname="getErrors" description="Gets the query of errors" output="false" returntype="query">
		<cfreturn this.errors>
	</cffunction>

	<cffunction access="public" name="add" displayname="add" description="Adds a new error to the lsit" output="false" returntype="boolean">
		<cfargument name="fieldName" type="string" required="true" />
		<cfargument name="message" displayName="message" type="string" hint="The error message to be stored" required="false" />
		
		<!--- add new row to errors list --->
		<cfset QueryAddRow(this.errors)>
		<cfset QuerySetCell(this.errors, "displayOrder", this.errors.recordcount + 1)>
		<cfset QuerySetCell(this.errors, "fieldName", arguments.fieldName)>
		<cfset QuerySetCell(this.errors, "message", arguments.message)>
			
		<cfreturn true>
	</cffunction>

	<cffunction access="public" name="merge" displayname="combine" description="combine another error list into this one" output="false">
		<cfargument name="secondList" type="validationList" required="true">
		<cfset var errorsToAdd = secondList.getErrors()>

		<!--- merge errors from other object into this --->
		<cfquery name="this.errors" dbtype="query">
			SELECT * FROM this.errors
			UNION
			SELECT * FROM errorsToAdd
			ORDER BY DisplayOrder
		</cfquery>
	</cffunction>

	<cffunction access="public" name="hasErrors" displayname="hasErrors" description="Whether or not there are any errors so far." output="false" returntype="boolean">
		<cfreturn (this.errors.recordCount is not 0)>
	</cffunction>
	
	<cffunction access="public" name="getHtmlErrorBox" description="Provides a simply laid out list of errors">
		<cfset var html = "">
		<cfset var orderedErrors = "">
		
		<cfif this.hasErrors()>
			<cfquery name="orderedErrors" dbtype="query">
				SELECT * FROM this.errors
				ORDER BY DisplayOrder
			</cfquery>
			<cfsavecontent variable="html">
			<div class="error">
				<p><strong>Please review the following problems:</strong></p>
				<ul>
				<cfoutput query="this.errors"><li>#message#</li></cfoutput>
				</ul>
			</div>
			</cfsavecontent>
		</cfif>
		<cfreturn html>
	</cffunction>
	
	<cffunction access="public" name="clear" output="false">
		<cfset this.errors = QueryNew("displayorder, fieldName, message", "integer, Varchar, Varchar") /> 
	</cffunction>

</cfcomponent>