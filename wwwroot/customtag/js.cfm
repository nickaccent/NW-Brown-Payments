<!--- Includes a javascript file but with change detection --->
<cfsilent>
	<cfparam name="ATTRIBUTES.src" default="" />
	<cfparam name="ATTRIBUTES.position" default="bottom" />
	
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
		<cfsavecontent variable="thisScriptTag">
			<cfoutput>
				<script 
					<cfif !isNull(src)>
						src="#src.file#?v=#DateFormat(fileDate, "yyyymmdd")&TimeFormat(fileDate,"hhmmss")#&#src.query_string#"
					</cfif>
					<cfloop collection="#ATTRIBUTES#" item="thisAttribute">
						<cfif thisAttribute neq "position">#lCase(thisAttribute)#="#ATTRIBUTES[thisAttribute]#"</cfif>
					</cfloop>
				>#thisTag.generatedContent#</script>
			</cfoutput>
		</cfsavecontent>
		
		<Cfif isNull(src) OR (!isNull(src) && !arrayFind(REQUEST.js[ATTRIBUTES.position], thisScriptTag))>
			<cfset ArrayAppend(REQUEST.js[ATTRIBUTES.position], thisScriptTag) />
		</cfif>
		
	</cfif>
	
	<cfset thisTag.generatedContent = "" />
</cfsilent>