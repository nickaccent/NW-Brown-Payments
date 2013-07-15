<!doctype html>
<html class="no-js" lang="en"> 
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

  <title><cfoutput>#ATTRIBUTES.title#</cfoutput> | NW Brown</title>
  <meta name="description" content="<cfoutput>#ATTRIBUTES.description#</cfoutput>">
  <meta name="keywords" content="<cfoutput>#ATTRIBUTES.keywords#</cfoutput>">
  <meta name="author" content="">

  <meta name="viewport" content="width=device-width,initial-scale=1">
	
  <link rel="shortcut icon" href="/favicon.ico" />
  <link rel="apple-touch-icon" href="/apple-touch-icon.png">
  <link rel="alternate" type="application/rss+xml" title="NW Brown Group Feed" href="/rss.cfm">

	<!--- If operating in local mode, show test background --->
	<cfset isLocal = CALLER.this.isLocal />
	<cfif isLocal()>
		<style type="text/css">
			body {background-image: url('/img/testbackground.gif');}
		</style>
	</cfif>
  
  <!--[if ! lte IE 6]><!-->
  <link rel="stylesheet" href="/css/styles.css">
  <cfoutput><cfloop array="#REQUEST.css#" index="thisCssBlock">#thisCssBlock#</cfloop></cfoutput>
  <!--<![endif]-->

  <!--[if lte IE 6]>
  <link rel="stylesheet" type="text/css" href="/css/ie6.1.1.css" />
  <![endif]-->

  <!--- <script type="text/javascript" src="http://use.typekit.com/kej7atp.js"></script>
  <script type="text/javascript">try{Typekit.load();}catch(e){}</script> --->
  <script src="/js/modernizr-2.0.6.js"></script>
  <script src="/js/jquery-1.7.2.min.js"></script>
  <script src="/js/jquery.validate.min.js"></script>
  <cfoutput><cfloop array="#REQUEST.js.top#" index="thisScriptTag">#thisScriptTag#</cfloop></cfoutput>
  
</head>
<body>