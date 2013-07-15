component
{
	this.sessionManagement = true;
	this.sessionTimeout = CreateTimeSpan(0, 0, 15, 0);
	this.ApplicationTimeout = CreateTimeSpan(7,0,0,0);
		
	// Path to look for Custom Tags for this application
	this.customtagpaths 	=  GetDirectoryFromPath(GetCurrentTemplatePath()) & 'customtag';
	//this.debuggingipaddress = "127.0.0.1";
	this.enableRobustException = true;
	setLocale("English (UK)");

	this.name = "NWBPayments#hash(CGI.HTTP_HOST)#";
	this.ormenabled = true;
	this.ormsettings = {
		cfclocation = '/cfc/nwbrown/'
	};
	
	if (isLocal()) {
		this.datasource = "nwbpayments";
		this.backofficedatasource = "NWB_PT3-Test";
	} else {
		this.datasource = "nwbpayments";
		this.backofficedatasource = "NWB_PT3-LIVE";
		//this.backofficedatasource = "NWB_PT3-Test";
	}
	
	function onApplicationStart() {
		application.datasource = this.datasource;
		application.backofficedatasource = this.backofficedatasource;
		application.adminIPs = "81.110.137.141,82.71.19.52"; // list of ip addresses allow to access the system
		application.sessionDuration = 15; // how long (in minutes) until the session expires
		
		// reload all the orm stuff...
		ORMReload();
		ORMFlush();
		
		application.local = isLocal();
	}
	
	function onRequestStart() {
		if (isDefined('url.reinit')) {
			onApplicationStart();
			return false;
		}
		
		// ensure https if live
		if (1 eq 2 AND !isLocal() AND CGI.https neq "on") {
			if (len(CGI.query_string)) {
				location(url='https://' & CGI.HTTP_HOST & CGI.script_name & '?' & CGI.query_string, addtoken='no');
			} else {
				location(url='https://' & CGI.HTTP_HOST & CGI.script_name, addtoken='no');
			}
		}
		
		// only allow access from NWB ip addresses (and accent)
		if (!isLocal() AND !listFind(application.adminIPs, cgi.remote_addr) AND !isDefined('URL.paymentnotify')) {
			throw('Access is not allowed from this IP address (#cgi.remote_addr#)');
		}
		
		REQUEST.URLProtocol = (CGI.HTTPS is "on" ? 'https' : 'http');
		REQUEST.js = { top = ArrayNew(1), bottom = ArrayNew(1) };
        REQUEST.css = ArrayNew(1);
		
		//ORMReload();
	}
	
	function onSessionStart() {
		session.startedAt = now();
	}

	function onRequest(file) {
		include "/include/prep.cfm";
		include ARGUMENTS.file;
	}
	
	function onError(exception) {
		if (isLocal()) {
			throw(object=arguments.exception);
		} else {
			include "/error.cfm";
		}
	}
	
	function isLocal() {
		return findNoCase(".vm", CGI.HTTP_HOST) OR findNoCase(".accentdesign.co.uk", CGI.HTTP_HOST);
	}
	
}