<!--- These would eventually live in application.cfc/onApplicationStart() in final cfc --->
<cfset VARIABLES.Utils				= new cfc.AccentDesign.Utils() />
<cfset VARIABLES.Validate	 		= new cfc.AccentDesign.Validation() />
<cfset VARIABLES.ValidationErrors 	= new cfc.AccentDesign.ValidationList() />
<!--- <cfset VARIABLES.SagePay			= APPLICATION.SagePay /> --->

<!--- filenames of each step of the process --->
<Cfset steps = ["/begin.cfm","/index.cfm","/paymentRequest.cfm","/complete.cfm"] />
<cfset URL.Step = arrayFindNoCase(steps, CGI.SCRIPT_NAME) />

<cfset VARIABLES.Initial 	= structIsEmpty(FORM) />
<cfset VARIABLES.Submit 	= isDefined('FORM.continue') OR isDefined('FORM.submitStep') />
<cfset VARIABLES.ViaXHR		= VARIABLES.Utils.getHTTPHeader('X-Requested-With') is "XMLHTTPRequest" />
<cfset VARIABLES.PaymentBegun = structKeyExists(SESSION, "PaymentSessionID") />
<cfset VARIABLES.StartNewPayment = URL.Step eq 1 />

<!--- The structure of response that will be returned via JSON in response to an XHR form submission --->
<cfset VARIABLES.Response = { SAVED = false, ERRORS = QueryNew("Fieldname, Message"), nextURL = steps[1] } />

<!--- Payment Callback --->
<cfif isDefined('URL.paymentnotify')>
	<cfparam name="URL.PaymentID" type="numeric" />
	<cfparam name="URL.PaymentRequestID" type="numeric" />
	
	<cfif URL.PaymentRequestID>	
		<!--- retrieve details of the payment request --->
		<cfset VARIABLES.PaymentRequest = entityLoadByPK("PaymentRequest", URL.PaymentRequestID) />
		
		<!--- load sagepay gateway for the appropriate account depending upon the system the original request came from --->
		<cfset SagePay = new cfc.AccentDesign.SagePayConnector.SagePayGateway(
			AssociatedTableName="PaymentRequest",
			Vendor=paymentRequest.getPaymentSession().getBackOfficeApplication().getVendorName(), 
			Mode=(application.local ? 'test' : 'live'), 
			datasource=application.datasource
		) />
	
		<!--- process the response from sagepay! --->
		<cfset VARIABLES.SagePay.receiveResponse(PaymentID=URL.PaymentID) />

		<!--- Send notification back to backend --->
		<Cfif VARIABLES.PaymentRequest.getHasBeenPaid()>
			<cfset VARIABLES.PaymentRequest.getPaymentSession().notifyBackOffice() />
		</cfif>
		
		<!--- Print out status message --->
		<cfscript>
			// SagePay-compatible line ending
			eol = eol = chr(13) & chr(10);
			// Clear any whitespace (SagePay doesn't like it)
			getPageContext().getOut().clearBuffer();
			// Let SagePay know we've received their response.
			writeOutput("Status=OK#eol#RedirectURL=#REQUEST.URLProtocol#://#CGI.HTTP_HOST#/complete.cfm?PaymentRequestID=#URL.PaymentRequestID##eol#StatusDetail=");
		</cfscript>
	</cfif>
	<cfabort />
</cfif>