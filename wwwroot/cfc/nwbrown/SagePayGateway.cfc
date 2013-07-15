<!--- 
  SagePay VSP Server Functions
  
  - For use when using the SERVER integration method with SAgePay, rather than FORM
  - This is necessary when you need to process a MOTO (Telephone) order via a website interface,
    as FORM mode doesn't support it.
  
 --->

<cfcomponent displayname="SagePayGateway" hint="Manages interactions between SagePay and the FreedomInsure Website">
	<cfproperty name="Mode" default="Simulator" type="string" hint="SagePay Mode (Live,Test,Simulator)" />
	<cfproperty name="Vendor" type="string" hint="The vendor name." />
	<cfset VARIABLES.VPSProtocol = 2.23 />

	<!--- Server URLS --->
	<cfset VARIABLES.URLS = { Simulator = structNew(), Test = structNew(), Live = structNew() } />
	<cfset VARIABLES.URLS.Live = {
		register = "https://live.sagepay.com/gateway/service/vspserver-register.vsp",
		refund = "https://live.sagepay.com/gateway/service/refund.vsp",
		abort = "https://live.sagepay.com/gateway/service/abort.vsp",
		cancel = "https://live.sagepay.com/gateway/service/cancel.vsp",
		release = "https://live.sagepay.com/gateway/service/release.vsp",
		repeat = "https://live.sagepay.com/gateway/service/repeat.vsp",
		void = "https://live.sagepay.com/gateway/service/void.vsp",
		directrefund = "https://live.sagepay.com/gateway/service/directrefund.vsp",
		authorise = "https://live.sagepay.com/gateway/service/authorise.vsp",
		manualpayment = "https://live.sagepay.com/gateway/service/manualpayment.vsp"
	} />
	<cfset VARIABLES.URLS.Test = {
		register = "https://test.sagepay.com/gateway/service/vspserver-register.vsp",
		refund = "https://test.sagepay.com/gateway/service/refund.vsp",
		abort = "https://test.sagepay.com/gateway/service/abort.vsp",
		cancel = "https://test.sagepay.com/gateway/service/cancel.vsp",
		release = "https://test.sagepay.com/gateway/service/release.vsp",
		repeat = "https://test.sagepay.com/gateway/service/repeat.vsp",
		void = "https://test.sagepay.com/gateway/service/void.vsp",
		directrefund = "https://test.sagepay.com/gateway/service/directrefund.vsp",
		authorise = "https://test.sagepay.com/gateway/service/authorise.vsp",
		manualpayment = "https://test.sagepay.com/gateway/service/manualpayment.vsp"
	} />
	<cfset VARIABLES.URLS.Simulator = {
		register = "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorRegisterTx",
		refund = "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorRefundTx",
		abort = "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorabortTx",
		cancel = "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorcancelTx",
		release = "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorReleaseTx",
		repeat = "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorrepeatTx",
		void = "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorvoidTx",
		directrefund = "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendordirectrefundTx",
		authorise = "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorauthoriseTx",
		manualpayment = "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendormanualpaymentTx"
	} />
	
	<cffunction name="init" output="false">
		<cfargument name="Vendor" required="true" />
		<cfargument name="Mode" required="true" />
		<cfargument name="Datasource" required="true" />
		
		<cfset VARIABLES.Vendor = ARGUMENTS.Vendor />
		<cfset VARIABLES.Mode = ARGUMENTS.Mode />
		<cfset VARIABLES.Datasource = ARGUMENTS.Datasource />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="register" hint="Register a payment or action on an existing payment with SagePay" output="false">
		<cfargument name="PaymentRequestID" required="true" type="numeric" hint="this is the Foreign Key of whatever sagepay is going to be connected to" />
		<cfargument name="RedirectionURL">
		<cfargument name="TxType" default="Payment">
		<cfargument name="VendorTxCode">
		<cfargument name="Amount">
		<cfargument name="Currency" default="GBP">
		<cfargument name="Description" default="">
		<cfargument name="NotificationURL">
		<cfargument name="BillingSurname">
		<cfargument name="BillingFirstNames">
		<cfargument name="billingaddress1">
		<cfargument name="billingaddress2">
		<cfargument name="billingcity">
		<cfargument name="billingstate">
		<cfargument name="billingpostcode">
		<cfargument name="Billingcountry" default="GB">
		<cfargument name="BillingPhone">
		<cfargument name="DeliverySurname">
		<cfargument name="DeliveryFirstnames">
		<cfargument name="deliveryaddress1">
		<cfargument name="deliveryaddress2">
		<cfargument name="deliverycity">
		<cfargument name="deliverystate">
		<cfargument name="deliverypostcode">
		<cfargument name="DeliveryCountry" default="GB">
		<cfargument name="deliveryphone">
		<cfargument name="AllowGiftAid" default="0">
		<cfargument name="ApplyAVSCV2" default="0">
		<cfargument name="Apply3DSecure" default="0">
		<cfargument name="AccountType" default="E"> <!--- E for Ecommerce, M for Mail order --->
		<cfargument name="Profile" default="Normal"> <!--- Normal or low (in iframe within site) --->
		
		<cfset var SagePayURL = "" />
		<cfset var SagePayResponse = {} />
		
		<!--- Set the URL you will be sending the request to, when 'registering' a payment mode=register, most others correspond to their txtype --->
		<cfif ARGUMENTS.TxType is "payment" OR ARGUMENTS.TxType is "deferred">
			<cfset SagePayURL = VARIABLES.URLS[VARIABLES.Mode]['register'] />
		<cfelse>
			<cfset SagePayURL = VARIABLES.URLS[VARIABLES.Mode][ARGUMENTS.TxType] />
		</cfif>

		<!--- insert a new payment record --->
		<!--- Start Transaction in the DB --->
		<cfquery datasource="#VARIABLES.datasource#" result="newPayment">
		  INSERT INTO Payment (PaymentRequestID, TxType, VPSProtocol)
		  VALUES (
		  	<cfqueryparam value="#ARGUMENTS.PaymentRequestID#" />,
			<cfif ARGUMENTS.TxType is "Payment" OR ARGUMENTS.TxType is "Deferred">
			  <cfqueryparam value="Register-#ARGUMENTS.TxType#">,
			<cfelse>
				<cfqueryparam value="#ARGUMENTS.TxType#">,
			</cfif>
			<cfqueryparam value="#VARIABLES.VPSProtocol#">
		  );
		  <!---
		  SELECT SCOPE_IDENTITY() AS PaymentID;
		  --->
		</cfquery>
		
		<cfset SagePayResponse.PaymentID = newPayment.generatedKey />
		<!--- Append PaymentID onto the VendorTxCode if you are registering a new payment --->
		<cfif ARGUMENTS.TxType is "Payment" OR ARGUMENTS.TxType is "Deferred">
			<cfset ARGUMENTS.VendorTxCode = ARGUMENTS.VendorTxCode & '-' & SagePayResponse.PaymentID />
		</cfif>
		<!--- Also append payment id to the urls too --->
		<cfif structKeyExists(ARGUMENTS, "NotificationURL")>
			<cfif find('?', ARGUMENTS.NotificationURL)>
				<cfset ARGUMENTS.NotificationURL = ARGUMENTS.NotificationURL & '&PaymentID=' & SagePayResponse.PaymentID />
			<cfelse>
				<cfset ARGUMENTS.NotificationURL = ARGUMENTS.NotificationURL & '?PaymentID=' & SagePayResponse.PaymentID />
			</cfif>
		</cfif>
		<cfif structKeyExists(ARGUMENTS, "RedirectionURL")>
			<cfif find('?', ARGUMENTS.RedirectionURL)>
				<cfset ARGUMENTS.RedirectionURL = ARGUMENTS.RedirectionURL & '&PaymentID=' & SagePayResponse.PaymentID />
			<cfelse>
				<cfset ARGUMENTS.RedirectionURL = ARGUMENTS.RedirectionURL & '?PaymentID=' & SagePayResponse.PaymentID />
			</cfif>
		</cfif>

		<!--- Make request to SagePay --->
		<cfhttp method="post" url="#SagePayURL#" port="80" result="response">
			<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0"> 

			<cfhttpparam name="VPSProtocol" type="FormField" value="#VARIABLES.VPSProtocol#">
			<cfhttpparam name="VENDOR" type="FormField" value="#VARIABLES.VENDOR#">
			<cfhttpparam name="TXTYPE" type="FormField" value="#arguments.TXTYPE#">
			<cfhttpparam name="VENDORTXCODE" type="FormField" value="#arguments.VENDORTXCODE#">
		  
			<cfif ARGUMENTS.TxType is "Payment" OR ARGUMENTS.TxType is "Deferred">
				<cfhttpparam name="RedirectionURL" type="FormField" value="#arguments.RedirectionURL#">
				<cfhttpparam name="DELIVERYSURNAME" type="FormField" value="#arguments.DELIVERYSURNAME#">
				<cfhttpparam name="DELIVERYFIRSTNAMES" type="FormField" value="#arguments.DELIVERYFIRSTNAMES#">
				<cfif StructKeyExists(arguments,"DeliveryPhone")><cfhttpparam name="DELIVERYPHONE" type="FormField" value="#arguments.DELIVERYPHONE#"></cfif>
				<cfif StructKeyExists(arguments,"BillingPhone")><cfhttpparam name="BILLINGPHONE" type="FormField" value="#arguments.BILLINGPHONE#"></cfif>
				<cfhttpparam name="DELIVERYADDRESS1" type="FormField" value="#arguments.DELIVERYADDRESS1#">
				<cfif StructKeyExists(arguments,"DeliveryAddress2")><cfhttpparam name="DELIVERYADDRESS2" type="FormField" value="#arguments.DELIVERYADDRESS2#"></cfif>
				<cfhttpparam name="DELIVERYPOSTCODE" type="FormField" value="#arguments.DELIVERYPOSTCODE#">
				<cfif StructKeyExists(arguments,"DELIVERYSTATE")><cfhttpparam name="DELIVERYSTATE" type="FormField" value="#arguments.DELIVERYSTATE#"></cfif>
				<cfhttpparam name="DELIVERYCOUNTRY" type="FormField" value="#arguments.DELIVERYCOUNTRY#">

				<cfhttpparam name="BILLINGSURNAME" type="FormField" value="#arguments.BILLINGSURNAME#">
				<cfhttpparam name="BILLINGFIRSTNAMES" type="FormField" value="#arguments.BILLINGFIRSTNAMES#">
				<cfhttpparam name="BILLINGADDRESS1" type="FormField" value="#arguments.BILLINGADDRESS1#">
				<cfif StructKeyExists(arguments,"BILLINGADDRESS2")><cfhttpparam name="BILLINGADDRESS2" type="FormField" value="#arguments.BILLINGADDRESS2#"></cfif>
				<cfhttpparam name="BILLINGCITY" type="FormField" value="#arguments.BILLINGCITY#">
				<cfhttpparam name="BILLINGCOUNTRY" type="FormField" value="#arguments.BILLINGCOUNTRY#">
				<cfhttpparam name="BILLINGPOSTCODE" type="FormField" value="#arguments.BILLINGPOSTCODE#">

				<cfhttpparam name="ALLOWGIFTAID" type="FormField" value="#arguments.ALLOWGIFTAID#">
				<cfhttpparam name="APPLYAVSCV2" type="FormField" value="#arguments.APPLYAVSCV2#">
				<cfhttpparam name="ACCOUNTTYPE" type="FormField" value="#arguments.ACCOUNTTYPE#">
				<cfhttpparam name="APPLY3DSECURE" type="FormField" value="#arguments.APPLY3DSECURE#">

				<cfhttpparam name="CURRENCY" type="FormField" value="#arguments.CURRENCY#">
				<cfhttpparam name="AMOUNT" type="FormField" value="#arguments.AMOUNT#">      
				<cfhttpparam name="NOTIFICATIONURL" type="FormField" value="#arguments.NOTIFICATIONURL#">
				<cfif StructKeyExists(arguments,"BillingState")><cfhttpparam name="BILLINGSTATE" type="FormField" value="#arguments.BILLINGSTATE#"></cfif>
				<cfhttpparam name="DELIVERYCITY" type="FormField" value="#arguments.DELIVERYCITY#">
				<cfhttpparam name="DESCRIPTION" type="FormField" value="#arguments.DESCRIPTION#">
				<cfhttpparam name="PROFILE" type="FormField" value="#UCase(arguments.Profile)#">
			<cfelseif ARGUMENTS.TxType is "Release" OR ARGUMENTS.TxType is "Abort">
				<cfhttpparam name="VPSTxId" 		type="FormField" value="#arguments.VPSTxId#" />
				<cfhttpparam name="SecurityKey" 	type="FormField" value="#arguments.SecurityKey#" />
				<cfhttpparam name="TxAuthNo" 		type="FormField" value="#arguments.TxAuthNo#" />
				<cfif ARGUMENTS.TxType is "Release">
					<cfhttpparam name="ReleaseAmount" type="FormField" value="#arguments.AMOUNT#" />
				</cfif>
			</cfif>
		</cfhttp>

		<!--- Parse the response into a struct --->
		<cfloop list="#response.filecontent#" delimiters="#chr(10)##chr(13)#" index="thing">
			<cflog text="#response.filecontent#" file="TUI-SagePayResponses" type="Information" />
			<cfset responseLine = ListToArray(thing,"=")>
			<cfset Argument = responseLine[1]>
			<cfset temp     = ArrayDeleteAt(responseLine,1)>
			<cfset Value    = ArrayToList(responseLine,"=")>
			<cfscript>StructInsert(SagePayResponse, Argument, Value);</cfscript>
		</cfloop>

		<cfif Isdefined('SagePayResponse.Status')>
			<!--- Start Transaction in the DB --->
			<cfquery name="newPayment" datasource="#VARIABLES.datasource#">
				UPDATE Payment SET
					Status = <cfqueryparam value="#SagePayResponse.Status#">,
					StatusDetail = <cfqueryparam value="#SagePayResponse.StatusDetail#">,
					<cfif (SagePayResponse.Status is "OK" OR SagePayResponse.Status is "OK REPEATED") AND (ARGUMENTS.TxType is "Payment" OR ARGUMENTS.TxType is "Deferred")>
					  VPSTxId = <cfqueryparam value="#SagePayResponse.VPSTxId#">,
					  SecurityKey = <cfqueryparam value="#SagePayResponse.SecurityKey#">,
					  NextURL = <cfqueryparam value="#SagePayResponse.NextURL#">,
  					  TxType = <cfqueryparam value="Register-#ARGUMENTS.TxType#">,
  					<cfelseif (ARGUMENTS.TxType is "Payment" OR ARGUMENTS.TxType is "Deferred")>
						TxType = <cfqueryparam value="#ARGUMENTS.TxType#">,
					<cfelse>
						TxType = <cfqueryparam value="#ARGUMENTS.TxType#">,
					</cfif>
					VPSProtocol = <cfqueryparam value="#SagePayResponse.VPSProtocol#">
			  WHERE PaymentID = <cfqueryparam value="#SagePayResponse.PaymentID#" cfsqltype="cf_sql_integer" />
			</cfquery>
			<!--- If the response was invalid, dump all the arguments too --->
			<cfif SagePayResponse.Status is "INVALID">
				<cfset SagePayResponse.Params = ARGUMENTS />
			</cfif>
		<cfelse>
			<cfmail from="craig@accentdesign.co.uk" to="craig@accentdesign.co.uk" subject="Weyy">
			  URL:
			  <cfloop collection="#SagePayResponse#" item="key">#key# - #SagePayResponse[key]#</cfloop>
			</cfmail>
			<cfthrow message="Looks like there was a problem connecting to SagePay?">
		</cfif>
		<cfreturn SagePayResponse>
	</cffunction>
	
	<cffunction name="receiveResponse" hint="Stores the response returned from SagePay for any action that has occurred.">
	  <cfargument name="PaymentID" type="numeric" required="true">
	  <!--- No params required - looks directly at the FORM scope for the posted data --->
	  <cfset POSTData = StructCopy(FORM)>
	  
	  <cfquery name="thisPayment" datasource="#datasource#">
		SELECT PaymentID FROM Payment
		WHERE PaymentID = <cfqueryparam value="#ARGUMENTS.PaymentID#">
	  </cfquery>
	  
	  <cfif NOT thisPayment.recordCount>
		<cfthrow message="The payment id entered could not be found in the database.">
	  </cfif>

	  <!--- Save Status Updates to the Database --->  
	  <cfquery name="updatePaymentStatus" datasource="#datasource#">
		UPDATE Payment SET
		  TxType      = <cfqueryparam value="#POSTData.TxType#">,
		  VendorTxCode = <cfqueryparam value="#POSTData.VendorTxCode#">,
		  Status = <cfqueryparam value="#POSTData.Status#">,
		  <cfif IsDefined('POSTData.StatusDetail')>
		    StatusDetail = <cfqueryparam value="#POSTData.StatusDetail#">,
		  </cfif>
		  <cfif POSTData.Status is "OK">
			VPSTxId = <cfqueryparam value="#POSTData.VPSTxId#">,
			TxAuthNo = <cfqueryparam value="#POSTData.TxAuthNo#">,
			AVSCV2 = <cfqueryparam value="#POSTData.AVSCV2#">,
			AddressResult = <cfqueryparam value="#POSTData.AddressResult#">,
			PostcodeResult = <cfqueryparam value="#POSTData.PostcodeResult#">,
			CV2Result = <cfqueryparam value="#POSTData.CV2Result#">,
			GiftAid = <cfqueryparam value="#POSTData.GiftAid#">,
			[3DSecureStatus] = <cfqueryparam value="#POSTData.3DSecureStatus#">,
			<cfif POSTData.3DSecureStatus is "OK">
				CAVV = <cfqueryparam value="#POSTData.CAVV#">,      
			</cfif>
		  </cfif>
		  VPSProtocol = <cfqueryparam value="#POSTData.VPSProtocol#">
		WHERE PaymentID = <cfqueryparam value="#Arguments.PaymentID#">
	  </cfquery>
	  
	  <!--- Return the payment row from database, so that further action can be takening depending upon the status returned --->
	  <cfquery name="thisPayment" datasource="#datasource#">
		SELECT * FROM Payment
		WHERE PaymentID = <cfqueryparam value="#Arguments.PaymentID#" />
	  </cfquery>
	   
	  <cfreturn thisPayment> 
	</cffunction>
	
	<cffunction name="release" hint="Releases a specified payment">
		<cfreturn simpleAction(PaymentID=ARGUMENTS.PaymentID, Action="release") />
	</cffunction>
	
	<cffunction name="abort" hint="Aborts a specified payment">
		<cfreturn simpleAction(PaymentID=ARGUMENTS.PaymentID, Action="abort") />
	</cffunction>

	<cffunction name="simpleAction" hint="issues a simple command to sagepay i.e. release,abort,refund,etc" access="private">
		<cfargument name="PaymentID" type="numeric" default="0" />
		<cfargument name="Action" required="true" /><!--- release or abort --->
		<cfset var thisPayment = "" />
	
		<cfquery name="thisPayment" datasource="#datasource#">
			SELECT TxType, VendorTxCode, VPSTxId, SecurityKey, TxAuthNo, QuotePrice
			FROM Quote
				INNER JOIN Payment ON Payment.PaymentId = Quote.PaymentID
			WHERE Quote.PaymentID = <cfqueryparam value="#ARGUMENTS.PaymentID#" cfsqltype="cf_sql_integer" />
		</cfquery>
	
		<cfreturn sagePayServerRegister(
			RequestURL=ARGUMENTS.RequestURL,

			TxType=ARGUMENTS.Action,
			Vendor=ARGUMENTS.Vendor,
			VendorTxCode=thisPayment.VendorTxCode,
			VPSTxId=thisPayment.VPSTxId,
			SecurityKey=thisPayment.SecurityKey,

			TxAuthNo=thisPayment.TxAuthNo,
			Amount=thisPayment.QuotePrice		
		)   />
	</cffunction>

</cfcomponent>

<!---
<cfscript>
  sagePayServerRegister(
    Vendor=VSPServerVendorName, RequestURL=VSPServerSite, AccountType="M",
    RedirectionURL="http://www.nbcbirdandpest.co.uk/vspServerMailer.cfm",
    NotificationURL="http://www.nbcbirdandpest.co.uk/vspServerMailer.cfm",
    BillingSurname="Vincent", BillingFirstnames="Craig", BillingAddress1="94b St. Benedicts Street", BillingCity="Norwich", BillingPostcode="NR2 4AB", BillingCountry="GB",
    DeliverySurname="Vincent", DeliveryFirstnames="Craig", DeliveryAddress1="94b St. Benedicts Street", DeliveryCity="Norwich", DeliveryPostcode="NR2 4AB", DeliveryCountry="GB",
    Description="Test Payment through VSP Server.", Amount="1.00", VendorTxCode="accenttest5"
  );
</cfscript>
--->
