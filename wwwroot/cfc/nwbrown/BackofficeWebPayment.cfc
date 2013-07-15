<cfcomponent displayname="WebPayment" extends="cfc.AccentDesign.GenericBean" accessors="true" output="false" persistent="false">
	
	<cfproperty name="ID" type="numeric" />
	<cfproperty name="TransactionDate" type="date" />
	<cfproperty name="Payee" type="string" maxlength="100" />
	<cfproperty name="Address1" type="string" maxlength="100" />
	<cfproperty name="Address2" type="string" maxlength="100" />
	<cfproperty name="Address3" type="string" maxlength="100" />
	<cfproperty name="Address4" type="string" maxlength="100" />
	<cfproperty name="Postcode" type="string" maxlength="100" />
	<cfproperty name="Premium" type="numeric" />
	<cfproperty name="Reference" type="string" maxlength="50" />
	<cfproperty name="StaffMember" type="string" maxlength="50" />
	<cfproperty name="TransactionCompleted" type="boolean" />
	<cfproperty name="TransactionCompletedDate" type="date" />
	
	<cfproperty name="BackOfficeApplication" type="cfc.NWBrown.BackOfficeApplication" />
	<cfproperty name="PaymentSession" type="cfc.NWBrown.PaymentSession" />
	
	<cffunction name="init" output="false">
		<cfargument name="WebpaymentID" />
		<cfargument name="BackOfficeApplication" />
		
		<cfset VARIABLES.BackOfficeApplication = ARGUMENTS.BackOfficeApplication />
		
		<cfstoredproc datasource="#VARIABLES.BackOfficeApplication.getDatasource()#" procedure="WEB_sp_GetSagePayTransaction">
			<cfprocparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.WebPaymentID#" />
			<cfprocresult name="LOCAL.payment" />
		</cfstoredproc>
		
		<cfif !LOCAL.payment.recordCount>
			<cfthrow type="NWBrown.PaymentNotFound"
				message="Payment Not Found"
				detail="This payment was not found in the system." />
		</cfif>
		
		<cfset VARIABLES.ID = ARGUMENTS.WebpaymentID />
		<cfset populate(LOCAL.payment) />
						
		<cfreturn this />
	</cffunction>
	
	<cffunction name="complete" output="false">
		<cfstoredproc datasource="#VARIABLES.BackOfficeApplication.getDatasource()#" procedure="WEB_sp_CompleteSagePayTransaction">
			<cfprocparam cfsqltype="cf_sql_integer" value="#VARIABLES.ID#" />
		</cfstoredproc>
		<cfreturn true />
	</cffunction>
	
</cfcomponent>