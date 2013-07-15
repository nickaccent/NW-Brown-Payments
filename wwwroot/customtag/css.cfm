<!--- Includes a css file but with change detection --->
<cfsilent>
	<cfparam name="ATTRIBUTES.src" default="" />

	<cfif val(len(trim(ATTRIBUTES.src)))>
		<cfset src = { file = ListFirst(ATTRIBUTEs.src, "?"), query_string = "" } />
		<cfif ListLen(ATTRIBUTES.src, "?") GT 1>
			<cfset src.query_string = ListLast(ATTRIBUTES.src, "?") />
		</cfif>
		<!--- Get last modified date of file --->
		<cfset fileUrl = ExpandPath(src.file) />
		<cfset fileObj = createObject("java","java.io.File").init(fileUrl) />
		<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified()) />
	</cfif>
	<cfset StructDelete(ATTRIBUTES, "src") />

	<cfif thisTag.executionMode is "end">	       
		<cfsavecontent variable="thisStyleTag">
        	<cfoutput>
				<cfif !isNull(src)>
					<link rel="stylesheet" type="text/css" href="#src.file#?v=#DateFormat(fileDate, "yyyymmdd")&TimeFormat(fileDate,"hhmmss")#&#src.query_string#" <cfloop collection="#ATTRIBUTES#" item="thisAttribute">#lCase(thisAttribute)#="#ATTRIBUTES[thisAttribute]#" </cfloop>>
				<cfelse>
					<style type="text/css" <cfloop collection="#ATTRIBUTES#" item="thisAttribute">#lCase(thisAttribute)#="#ATTRIBUTES[thisAttribute]#" </cfloop>>
					#thisTag.generatedContent#
					</style>
				</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfset ArrayAppend(REQUEST.css, thisStyleTag) />
	</cfif>
	
	<cfset thisTag.generatedContent = "" />
</cfsilent>