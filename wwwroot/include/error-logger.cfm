<!---
	Error Logging Include
	- This should become the "standard" error logger for all Accent Websites, and should be called in the error handler template for all sites.

	Params:
		- The ERROR Struct passed to the error handler when ColdFusion has generated an error.
		
	NOTE: This has been altered specifically for WNF - so don't use on other sites!
--->
<cfset timemask = "h:mmtt">
<cfset datemask = "d/m/yyyy">

<!--- Whether or not the error was submitted sucessfully --->
<cfset success = false>

<!--- Ensure variables are always set - these could already be defined in application.cfm --->
<cfif NOT IsDefined('mailserver')>
	<cfset mailserver="localhost">
</cfif>
<cfif NOT IsDefined('errorLoggerUrl')>
	<cfset errorLoggerUrl="http://errors.accentdesign.co.uk/">
</cfif>
<cfif NOT IsDefined('errorKeyphrase')>
	<cfset errorKeyphrase="whisky">
</cfif>
<!--- Will contain the contents of the form scope, encoded in json --->
<cfset jsonFormData = "">
<!--- Will contain the contents of the session scope, encoded in json --->
<cfset jsonSessionData = "">
<cfset jsonCGIData = "" />
<!--- set requested page as friendly url version, unless there isnt one --->
<cfset requestPage = ( CGI['UNENCODED_URL'] neq '' ? CGI['UNENCODED_URL'] : CGI.SCRIPT_NAME ) />

<!--- Compile Error String Variable --->
<cfsavecontent variable="errorString">
<cfoutput>ErrorSite%%#CGI.HTTP_HOST#|
ErrorDate%%#now()#|
ErrorMessage%%#ARGUMENTS.Exception.Cause.Message#|
ErrorDetail%%#ARGUMENTS.Exception.Cause.Detail#|
ErrorPage%%#requestPage#|
ErrorQuerystring%%#CGI.Query_String#|
ErrorReferer%%#CGI.HTTP_Referer#|
RemoteBrowser%%#CGI.User_Agent#|
RemoteIP%%#CGI.Remote_Addr#</cfoutput>
</cfsavecontent>

<!--- Encode contents of form scope into json, to be stored in the database --->
<!--- Catch any errors, if for some reason this fails, error should still be logged --->
<cftry>
	<cfset jsonFormData = SerializeJSON(FORM) />
	<cfcatch></cfcatch>
</cftry>
<!--- Encode contents of form scope into json, to be stored in the database --->
<!--- Catch any errors, if for some reason this fails, error should still be logged --->
<cftry>
	<cfset jsonSessionData = SerializeJSON(SESSION) />
	<cfcatch></cfcatch>
</cftry>
<cftry>
	<cfset jsonCGIData = SerializeJSON(CGI) />
	<cfcatch></cfcatch>
</cftry>
<cftry>
	<cfset jsonExceptionData = SerializeJSON(ARGUMENTS.Exception) />
	<cfcatch></cfcatch>
</cftry>

<cftry>
	<!--- Post the error string to the error logger backend. --->
	<cfhttp url="#errorLoggerUrl#errorLogger.cfm" method="post">
		<cfhttpparam name="keyPhrase" 	value="#errorKeyphrase#" type="formfield">
		<cfhttpparam name="errorString" value="#errorString#" type="formfield">
		<cfhttpparam name="FORMData" 	value="#jsonFormData#" type="formfield">
		<cfhttpparam name="SESSIONData" value="#jsonSessionData#" type="formfield">
		<cfhttpparam name="CGIData" 	value="#jsonCGIData#" type="formfield">
		<cfhttpparam name="ExceptionData" value="#jsonExceptionData#" type="formfield">
	</cfhttp>	
	<cfif CFHTTP.FileContent is "SUCCESS" AND CFHTTP.StatusCode is "200 OK">
		<cfset success = true>
	</cfif>
	<cfcatch>
		<cfset success = false>
	</cfcatch>
</cftry>

<!--- If all goes horribly wrong, resort to the usual way which has always worked in the past. --->
<cfif NOT success>
	<cfmail server="#mailserver#" port="25"
	  to="errors@accentdesign.co.uk"
	  from="errors@accentdesign.co.uk"
	  subject="ERROR: #CGI.HTTP_HOST#, #LSTimeFormat(Now(), "#timemask#")# #LSDateFormat(Now(), "#datemask#")#"
	>#errorString#</cfmail>
</cfif>