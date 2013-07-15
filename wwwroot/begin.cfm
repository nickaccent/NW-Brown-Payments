<cfparam name="URL.WebpaymentID" default="0" type="numeric" />
<cfparam name="URL.BackOfficeApplicationID" default="" type="string" />

<!--- If payment id not provided, or processing application, chuck back to nondescript homepage (or throw warning, whatever you fancy) --->
<cfif !URL.WebPaymentID OR URL.BackOfficeApplicationID is "">
	<cflocation url="index.cfm" />
</cfif>

<cfset thisBackOfficeApplication = EntityLoad("BackOfficeApplication", URL.BackOfficeApplicationID, true) />

<cfset VARIABLES.NWBWebPayment = new cfc.NWBrown.BackOfficeWebPayment(WebPaymentID = URL.WebpaymentID, BackOfficeApplication = thisBackOfficeApplication) />

<!--- Begin payment session --->
<cfset VARIABLES.PaymentSession = entityNew("PaymentSession") />
<cfset VARIABLES.PaymentSession.setWebpaymentID(URL.WebpaymentID) />
<cfset VARIABLES.PaymentSession.setPayee(NWBWebPayment.getPayee()) />
<cfset VARIABLES.PaymentSession.setAddress1(NWBWebPayment.getAddress1()) />
<cfset VARIABLES.PaymentSession.setAddress2(NWBWebPayment.getAddress2()) />
<cfset VARIABLES.PaymentSession.setAddress3(NWBWebPayment.getAddress3()) />
<cfset VARIABLES.PaymentSession.setAddress4(NWBWebPayment.getAddress4()) />
<cfset VARIABLES.PaymentSession.setPostcode(NWBWebPayment.getPostcode()) />
<cfset VARIABLES.PaymentSession.setPremium(NWBWebPayment.getPremium()) />
<cfset VARIABLES.PaymentSession.setReference(NWBWebPayment.getReference()) />
<cfset VARIABLEs.PaymentSession.setCreatedAt(now()) />
<cfset VARIABLES.PaymentSession.setBackOfficeApplication(thisBackOfficeApplication) />
<cfset entitySave(VARIABLES.PaymentSession) />

<!--- Create first payment request --->
<cfset VARIABLES.paymentRequest = entityNew("PaymentRequest") />
<cfset VARIABLES.paymentRequest.setPayee(NWBWebPayment.getPayee()) />
<cfset VARIABLES.paymentRequest.setAddress1(NWBWebPayment.getAddress1()) />
<cfset VARIABLES.paymentRequest.setAddress2(NWBWebPayment.getAddress2()) />
<cfset VARIABLES.paymentRequest.setAddress3(NWBWebPayment.getAddress3()) />
<cfset VARIABLES.paymentRequest.setAddress4(NWBWebPayment.getAddress4()) />
<cfset VARIABLES.paymentRequest.setPostcode(NWBWebPayment.getPostcode()) />
<cfset VARIABLES.paymentRequest.setAmount(NWBWebPayment.getPremium()) />
<cfset paymentSession.addPaymentRequest(VARIABLES.paymentRequest) />
<cfset entitySave(VARIABLES.paymentRequest) />

<!--- <cflocation url="index.cfm?PaymentSessionID=#VARIABLES.PaymentSession.getID()#" addtoken="no" /> --->
<cflocation url="paymentRequest.cfm?ID=#VARIABLES.paymentRequest.getID()#" addtoken="no" />