<cfcomponent displayname="provides common functions to all bean-style objects" output="false">
	
	<cffunction name="init" output="false">
		<cfset var meta = getMetaData(this) />
		<!--- Initialize all variables with default values --->
		<cfloop array="#meta.properties#" index="thisProp">
			<cfif NOT structKeyExists(VARIABLES, thisProp.name)>
				<cfif structKeyExists(thisProp, "default")>
					<cfset VARIABLES[thisProp.name] = thisProp.default />
				<cfelse>
					<cfif structKeyExists(thisProp, "type") AND thisProp.type is "boolean">
						<cfset VARIABLES[thisProp.name] = "false" />
					<cfelse>
						<cfset VARIABLES[thisProp.name] = "" />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn this />
	</cffunction>
	
	<!---
	<cffunction name="set" hint="set multiple properties within a cfc in one go from URL/FORM params with the same names.">
		<cfset var data = ArrayNew(1) />
		<cfset var props = ArrayNew(1) />
		
		<cfif NOT ArrayLen(ARGUMENTS)>
			<cfreturn false />
		</cfif>
		
		<cfloop array="#ARGUMENTS#" index="thisProperty">
			<cfset props = ArrayAppend(props, thisProperty) />
		</cfloop>
		
		<cfreturn populate(data=data, propList=props) />
	</cffunction>
	--->

	<cffunction name="isNew" returntype="boolean" output="false" hint="whether the item has been saved before.">
		<cfreturn getID() is 0 or getID() is "" />
	</cffunction>

	<cffunction name="populate" access="public" returntype="any" output="false" hint="Populates the object with values from the arguments">
		<cfargument name="data" type="any" required="yes" />
		<cfargument name="propList" type="any" required="no" default="#ArrayNew(1)#" />
		
		<cfset variables.Metadata = getMetadata(this) />
		<cfparam name="variables.Metadata.cleanseInput" default="false" />
		
		<cfloop array="#variables.Metadata.properties#" index="local.theProperty">
			<cftry>
				<!--- If a propList was passed in, use it to filter --->
				<cfif NOT ArrayLen(arguments.propList) OR ArrayContains(arguments.propList,local.theProperty.name)>
					<!--- Do columns --->
					<cfif NOT StructKeyExists(local.theProperty,"fieldType") OR local.theProperty.fieldType EQ "column">
						<cfif StructKeyExists(arguments.data,local.theProperty.name)>
							<!--- The property has a matching argument --->
							<cfset local.varValue = arguments.data[local.theProperty.name] />
							<!--- For nullable fields that are blank, set them to null --->
							<cfif (NOT StructKeyExists(local.theProperty,"notNull") OR NOT local.theProperty.notNull) AND NOT Len(local.varValue)>
								<cfset _setPropertyNull(local.theProperty.name) />
							<cfelse>
								<!--- Cleanse input? --->
								<cfparam name="local.theProperty.cleanseInput" default="#variables.Metadata.cleanseInput#" />
								<cfif local.theProperty.cleanseInput>
									<cfset local.varValue = _cleanse(local.varValue) />
								</cfif>
								<cfset _setProperty(local.theProperty.name,local.varValue) />
							</cfif>
						</cfif>
					<!--- do many-to-one --->
					<cfelseif local.theProperty.fieldType EQ "many-to-one">
						<cfif StructKeyExists(arguments.data,local.theProperty.fkcolumn)>
							<cfset local.fkValue = arguments.data[local.theProperty.fkcolumn] />
						<cfelseif StructKeyExists(arguments.data,local.theProperty.name)>
							<cfset local.fkValue = arguments.data[local.theProperty.name] />
						</cfif>
						<cfif StructKeyExists(local,"fkValue")>
							<cfset local.varValue = EntityLoadByPK(local.theProperty.name,local.fkValue) />
							<cfif IsNull(local.varValue)>
								<cfif NOT StructKeyExists(local.theProperty,"notNull") OR NOT local.theProperty.notNull>
									<cfset _setPropertyNull(local.theProperty.name) />
								<cfelse>
									<cfthrow detail="Trying to load a null into the #local.theProperty.name#, but it doesn't accept nulls." />
								</cfif>
							<cfelse>
								<cfset _setProperty(local.theProperty.name,local.varValue) />
							</cfif>
						</cfif>
					</cfif>
				</cfif>
				<cfcatch>
					<!--- <cfdump var="#cfcatch#" abort="true" /> --->
					<cfthrow message="#cfcatch.message# - #local.theProperty.name#" detail="#cfcatch.detail#" /><!---  - #arguments.data[local.theProperty.name]# --->
				</cfcatch>
			</cftry>
		</cfloop>
	</cffunction>

	<!--- This functionality is automagically built into CF9! (wish I'd found out sooner) --->
	<!---
	<cffunction name="onMissingMethod">
		<cfargument name="methodName" required="true" type="string" />
		<cfargument name="args" type="struct" />
		<cfset var fieldName = "" />
		
		<cfif left(ARGUMENTS.methodName, 3) is "set">
			<cfset fieldName = right(ARGUMENTS.methodName, len(ARGUMENTS.methodName-3)) />
			<cfset VARIABLES[fieldName] = ARGUMENTS.args[1] />	
		<cfelseif left(ARGUMENTS.methodName, 3) is "get">
			<cfset fieldName = right(ARGUMENTS.methodName, len(ARGUMENTS.methodName-3)) />
			<cfreturn VARIABLES[fieldName] />
		</cfif>
	</cffunction
	--->
	
	<!--- These private methods are used by the populate() method --->
	<cffunction name="_setProperty" access="private" returntype="void" output="false" hint="I set a dynamically named property">
		<cfargument name="name" type="any" required="yes" />
		<cfargument name="value" type="any" required="false" />
		<cfset var theMethod = this["set" & arguments.name] />
		<cfif IsNull(arguments.value)>
			<cfset theMethod(javacast('NULL', '')) />
		<cfelse>
			<cfset theMethod(arguments.value) />
		</cfif>
	</cffunction>
	
	<cffunction name="_setPropertyNull" access="private" returntype="void" output="false" hint="I set a dynamically named property to null">
		<cfargument name="name" type="any" required="yes" />
		<cfset _setProperty(arguments.name) />
	</cffunction>

	<cffunction name="_cleanse" access="private" returntype="any" output="false" hint="I cleanse input via HTMLEditFormat. My implementation can be changed to support other cleansing methods.">
		<cfargument name="data" type="any" required="yes" />
		<cfreturn HTMLEditFormat(arguments.data) />
	</cffunction>

	<cffunction name="_toSqlDate" access="private">
		<cfargument name="dateStr" />
		<cfif NOT ListLen(ARGUMENTS.dateStr, "/") eq 3>
			<cfreturn "" />
		</cfif>
		<cfif len(ListLast(ARGUMENTs.dateStr, "/")) eq 2>
			<cfreturn "20#ListLast(ARGUMENTs.dateStr, "/")#-#ListGetAt(ARGUMENTS.dateStr, 2, "/")#-#ListFirst(ARGUMENTS.dateStr, "/")#" />
		<cfelse>
			<cfreturn "#ListLast(ARGUMENTs.dateStr, "/")#-#ListGetAt(ARGUMENTS.dateStr, 2, "/")#-#ListFirst(ARGUMENTS.dateStr, "/")#" />
		</cfif>
	</cffunction>

</cfcomponent>