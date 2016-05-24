<cfcomponent persistent="true">
	<cfproperty name="ID" column="PaymentRequestID" fieldType="id" generator="native" type="numeric" ormType="int" />
	<cfproperty name="Payee" type="string" maxlength="100" />
	<cfproperty name="Address1" type="string" maxlength="100" />
	<cfproperty name="Address2" type="string" maxlength="100" />
	<cfproperty name="Address3" type="string" maxlength="100" />
	<cfproperty name="Address4" type="string" maxlength="100" />
	<cfproperty name="Postcode" type="string" maxlength="100" />
	<cfproperty name="Amount" type="numeric" />
	
	<cfproperty name="createdAt" type="timestamp" />
	<cfproperty name="updatedAt" type="timestamp" />
	
	<cfproperty name="HasBeenPaid" persistent="false" type="boolean" />
	<cfproperty name="SuccessfulPayment" persistent="false" />
	
	<cfproperty name="Payments" singularname="Payment" fieldType="one-to-many" fkcolumn="PaymentRequestID" cfc="Payment" />
	<cfproperty name="PaymentSession" fieldType="many-to-one" fkcolumn="PaymentSessionID" cfc="PaymentSession" />
	
	<cffunction name="getFirstName" output="false">
		<cfreturn listDeleteAt(getPayee(), listLen(getPayee(), " "), " ") />
	</cffunction>
	
	<cffunction name="getLastName" output="false">
		<Cfreturn listLast(getPayee(), " ") />
	</cffunction>
	
	<cffunction name="getHasBeenPaid" output="false" hint="returns true is success payment against this request">
		<cfloop array="#getPayments()#" index="thisPayment">
			<cfif thisPayment.getStatus() is "OK" AND thisPayment.getTxType() is "Payment">
				<cfreturn true />
			</cfif>
		</cfloop>
		<cfreturn false />		
	</cffunction>
	
	<cffunction name="getSuccessfulPayment">
		<cfloop array="#getPayments()#" index="thisPayment">
			<cfif thisPayment.getStatus() is "OK" AND thisPayment.getTxType() is "Payment">
				<cfreturn thisPayment />
			</cfif>
		</cfloop>
	</cffunction>
	
</cfcomponent>