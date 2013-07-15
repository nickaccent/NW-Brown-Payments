<cfset paymentRequest = entityLoad("paymentRequest", URL.ID, true) />

<cfscript>
	// if not paid, try and pay now
  paymentBegin = SagePay.register(
	PaymentRequestID=paymentRequest.getID(), Profile="low", AccountType="M",
	RedirectionURL="#REQUEST.URLProtocol#://#CGI.HTTP_HOST#/complete.cfm",
	NotificationURL="#REQUEST.URLProtocol#://#CGI.HTTP_HOST##CGI.SCRIPT_NAME#?paymentRequestID=#paymentRequest.getID()#&paymentnotify",
	BillingSurname=paymentRequest.getLastName(), BillingFirstnames=paymentRequest.getFirstName(), 
	BillingAddress1=(len(trim(paymentRequest.getAddress1())) ? paymentRequest.getAddress1() : 'Unknown'), BillingAddress2=paymentRequest.getAddress2(), BillingCity=(len(trim(paymentRequest.getAddress3()&paymentRequest.getAddress4())) ? paymentRequest.getAddress3() & ' ' & paymentRequest.getAddress4() : 'Unknown'), BillingPostcode=paymentRequest.getPostcode(), BillingCountry="GB",
	DeliverySurname=paymentRequest.getLastName(), DeliveryFirstnames=paymentRequest.getFirstName(), 
	DeliveryAddress1=(len(trim(paymentRequest.getAddress1())) ? paymentRequest.getAddress1() : 'Unknown'), DeliveryAddress2=paymentRequest.getAddress2(), DeliveryCity=(len(trim(paymentRequest.getAddress3()&paymentRequest.getAddress4())) ? paymentRequest.getAddress3() & ' ' & paymentRequest.getAddress4() : 'Unknown'), DeliveryPostcode=paymentRequest.getPostcode(), DeliveryCountry="GB",
	Description="Payment #paymentRequest.getPaymentSession().getReference()#", Amount=paymentRequest.getAmount(), VendorTxCode=paymentRequest.getPaymentSession().getReference()
  );
</cfscript>

<cf_page title="Payment Portal | Payment Request">

<div id="payment-portal-wrap">
	<section>
		<h1>Take Payment</h1>
		<div class="form-wrap clearfix">
			<ol class="no-bull details">
				<li class="beta">Your Total</li>
				<li class="alpha"><cfoutput>&pound;#decimalFormat(paymentRequest.getAmount())#</cfoutput></li>
			</ol>
			<cfoutput>
				<ol class="no-bull details">
					<li class="beta">Your Reference</li>
					<li class="alpha">#paymentRequest.getPaymentSession().getReference()#</li>
				</ol>
			</cfoutput>
		</div>
		<p>Some additional guidance to the operator could be entered here.</p>
		<cfif paymentBegin.Status is "OK">
			<cfoutput><iframe src="#paymentBegin.nextUrl#" width="100%" height="600" id="sagepay" frameBorder="0"></iframe></cfoutput>
		<cfelse>
			<h2>Sorry, we couldn't connect to our payment provider.</h2>
			<p>Technical information is shown below which may give a clue as to why this was.</p>
			<cfdump var="#paymentBegin#" />
		</cfif>
	
		
	</section>
</div>

</cf_page>