<!--- 
	Page Template
 --->
<cfsilent>
	<cfparam name="ATTRIBUTES.template" default="default" />
	<cfparam name="ATTRIBUTES.title" default="default" /><!--- Browser title --->
	<cfparam name="ATTRIBUTES.author" default="Accent Design Group" />
	<cfparam name="ATTRIBUTES.robots" default="all" />
	<cfparam name="ATTRIBUTES.keywords" default="" />
	<cfparam name="ATTRIBUTES.description" default="" />
    
    <cfparam name="ATTRIBUTES.Pageid" default="0" />
    <cfparam name="ATTRIBUTES.current" default="0" />
     
	<cfset pageContent = thisTag.generatedContent />
</cfsilent>
<cfif thisTag.ExecutionMode is "end">
	<cfcontent reset="true" />
	<cfsavecontent variable="pageTop"><cfinclude template="/include/top.cfm" /></cfsavecontent>
	<cfsavecontent variable="pageBottom"><cfinclude template="/include/bottom.cfm" /></cfsavecontent>
	<cfset thisTag.generatedContent = pageTop & pageContent & pageBottom />
</cfif>