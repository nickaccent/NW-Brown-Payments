<cfset paymentRequest = entityLoad("paymentRequest", URL.ID, true) />
<cfset SagePay = new cfc.AccentDesign.SagePayConnector.SagePayGateway(
	AssociatedTableName="PaymentRequest",
	Vendor=paymentRequest.getPaymentSession().getBackOfficeApplication().getVendorName(), 
	Mode=(application.local ? 'test' : 'live'), 
	datasource=application.datasource
) />

<cfif isDefined('URL.debug')>
	<cfdump var="#paymentRequest#" abort="true" />
</cfif>

<cfscript>
	// if not paid, try and pay now
  paymentBegin = SagePay.register(
	PaymentRequestID=paymentRequest.getID(), Profile="low", AccountType="M",
	RedirectionURL="#REQUEST.URLProtocol#://#CGI.HTTP_HOST#/complete.cfm",
	NotificationURL="#REQUEST.URLProtocol#://#CGI.HTTP_HOST##CGI.SCRIPT_NAME#?paymentRequestID=#paymentRequest.getID()#&paymentnotify",
	BillingSurname=left(paymentRequest.getLastName(), 35), BillingFirstnames=left(paymentRequest.getFirstName(), 20),
	BillingAddress1=(len(trim(paymentRequest.getAddress1())) ? left(paymentRequest.getAddress1(),100) : 'Unknown'), BillingAddress2=left(paymentRequest.getAddress2(),100), BillingCity=(len(trim(paymentRequest.getAddress3()&paymentRequest.getAddress4())) ? left(paymentRequest.getAddress3() & ' ' & paymentRequest.getAddress4(), 40) : 'Unknown'), BillingPostcode=(trim(paymentRequest.getPostcode()) eq '' ? 'NA' : left(paymentRequest.getPostcode(), 10)), BillingCountry="GB",
	DeliverySurname=left(paymentRequest.getLastName(), 35), DeliveryFirstnames=left(paymentRequest.getFirstName(), 20), 
	DeliveryAddress1=(len(trim(paymentRequest.getAddress1())) ? left(paymentRequest.getAddress1(),100) : 'Unknown'), DeliveryAddress2=left(paymentRequest.getAddress2(),100), DeliveryCity=(len(trim(paymentRequest.getAddress3()&paymentRequest.getAddress4())) ? left(paymentRequest.getAddress3() & ' ' & paymentRequest.getAddress4(), 40) : 'Unknown'), DeliveryPostcode=(trim(paymentRequest.getPostcode()) eq '' ? 'NA' : left(paymentRequest.getPostcode(), 10)), DeliveryCountry="GB",
	Description="Payment #paymentRequest.getPaymentSession().getReference()#", Amount=paymentRequest.getAmount(), 
	VendorTxCode=paymentRequest.getPaymentSession().getReference()
  );
</cfscript>


<cf_css>
	h1 {margin-bottom:5px; }
	h1 span { 
    	float:right; 
        
        background:#9A0029;
        padding:2px 8px;
    }
    h1 span.alpha {color:#F2F2F2;} 
    
</cf_css>

<!--- Session Timeout functionality --->
<cf_js>
	sessionTimeRemaining = (15*60)-<cfoutput>#jsStringFormat(paymentRequest.getPaymentSession().getAge('s'))#</cfoutput>;
	sessionTimeRemainingCheck = function() {
		if (sessionTimeRemaining > 0) {
			sessionTimeRemaining = sessionTimeRemaining-1;
		} else {
			// Don't check any more
			clearInterval(sessionTimeRemainingCheck);
			// chuck the user to the session timeout page
			window.location = '/timeout.cfm';
		}
		// Update Time Remaining Display
		$('#timeLeft').text(formatTime(sessionTimeRemaining));
	}
	
	formatTime = function(seconds) {
		var m,s;
		if (seconds>0) {
			m = Math.floor(seconds/60);
			s = seconds-(m*60);
			return '' + m + ':' + (s<=9?'0':'') + s;
		} else {
			return '0';
		}
	}
	
	$(document).ready(function(){
		// Show Time Remaining
		$('#timeLeft').text(formatTime(sessionTimeRemaining));
		// Check & Update the time remaining each second
		setInterval(sessionTimeRemainingCheck, 1000);
    });
</cf_js>

<!--- if the session has been open for more than 14mins 59secs, chuck to session timeout page --->
<cfif paymentRequest.getPaymentSession().getAge() GTE 15>
	<cflocation url="timeout.cfm" addtoken="no" />
</cfif>

<cf_page title="Payment Portal | Payment Request">

<div id="payment-portal-wrap">
	<section>
		<h1>
        	Take Payment 
            <!---<span><cfoutput>#paymentRequest.getPaymentSession().getReference()#</cfoutput></span>--->
            <span class="alpha"><cfoutput>&pound;#decimalFormat(paymentRequest.getAmount())#</cfoutput></span>
        </h1>       
		
		<div id="timeLeftContainer">
			Session Will Time Out In:
			<span id="timeLeft"></span>
		</div>
        
		<cfif paymentBegin.Status is "OK">
			<cfoutput><iframe src="#paymentBegin.nextUrl#" width="100%" height="500" id="sagepay" frameBorder="0"></iframe></cfoutput>
		<cfelse>
			<h2>Sorry, we couldn't connect to our payment provider.</h2>
			<p>Technical information is shown below which may give a clue as to why this was.</p>
			<cfdump var="#paymentBegin#" />
		</cfif>
	
		
	</section>
</div>

</cf_page>