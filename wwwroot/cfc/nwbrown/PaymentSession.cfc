<cfcomponent persistent="true">
	<cfproperty name="ID" column="PaymentSessionID" fieldType="id" generator="native" type="numeric" ormType="int" />
	<cfproperty name="WebPaymentID" type="numeric" />
	<cfproperty name="TransactionDate" type="date" />
	<cfproperty name="Payee" type="string" maxlength="100" />
	<cfproperty name="Address1" type="string" maxlength="100" />
	<cfproperty name="Address2" type="string" maxlength="100" />
	<cfproperty name="Address3" type="string" maxlength="100" />
	<cfproperty name="Address4" type="string" maxlength="100" />
	<cfproperty name="Postcode" type="string" maxlength="100" />
	<cfproperty name="Premium" type="numeric"/>
	<cfproperty name="Reference" type="string" maxlength="50" default="" />
	<cfproperty name="StaffMember" type="string" maxlength="50" />
	<cfproperty name="createdAt" type="date" />
	<cfproperty name="backOfficeNotifyRequestTime" type="date" />
	<cfproperty name="backOfficeNotifySuccessTime" type="date" />
	<cfproperty name="IsCompleted" type="boolean" persistent="false" />
	
	<cfproperty name="BackOfficeApplication" fieldType="many-to-one" fkcolumn="BackOfficeApplicationID" cfc="BackOfficeApplication" />
	<cfproperty name="PaymentRequests" singularname="PaymentRequest" fieldType="one-to-many" fkcolumn="PaymentSessionID" cfc="PaymentRequest" />
	
	<cffunction name="getIsCompleted" output="false" hint="returns true if a paid payment requets is found">
		<cfloop array="#getPaymentRequests()#" index="thisPaymentReq">
			<cfif thisPaymentReq.getHasBeenPaid()>
				<cfreturn true />
			</cfif>
		</cfloop>
		<cfreturn false />
	</cffunction>
	
	<cffunction name="getAge" output="false" hint="">
		<cfargument name="units" default="n" />
		<cfif getCreatedAt() is "">
			<cfreturn 9999 />
		<cfelse>
			<cfreturn dateDiff(ARGUMENTS.units, getCreatedAt(), now()) />
		</cfif>
	</cffunction>
	
	<cffunction name="notifyBackOffice" output="false" hint="tries to notify fit/pt3 of that the payment was successful">
		<!--- if not paid, die --->
		<cfif !getIsCompleted()>
			<cfthrow type="NWBrown.NotCompletedError" message="This payment session has not been completed." />
		</cfif>
		<!--- log that notify has been requested --->
		<cfset setBackOfficeNotifyRequestTime(now()) />
		<cfset entitySave(this) />
		<!--- connect to backoffice --->
		<cfset local.NWBWebPayment = new cfc.NWBrown.BackOfficeWebPayment(
			WebPaymentID = getWebPaymentID(), 
			BackOfficeApplication = getBackOfficeApplication()
		) />
		<!--- mark transaction as success --->
		<cfset local.NWBWebPayment.complete() />
		<!--- log that back office notification is complete --->
		<cfset setBackOfficeNotifySuccessTime(now()) />
		<cfset entitySave(this) />
	</cffunction>
</cfcomponent>