<cfcomponent accessors="true" output="false">

	<cfproperty name="ID" />
	<cfproperty name="TxType" />
	<cfproperty name="Status" />
	<cfproperty name="TxAuthCode" />
	<cfproperty name="VPSTxID" />
	
	<cffunction name="init" output="false">
		<cfargument name="PaymentID" required="true" />
		
		<cfset var thisPayment = "" />
		
		<cfquery name="thisPayment">
			SELECT TxType, Status, TxAuthCode, VPSTxID FROM Payment
			WHERE PaymentID = <cfqueryparam value="#ARGUMENTs.ID#" cfsqltype="cf_sql_integer" />
		</cfquery>
		
		<cfset VARIABLES.TxType = thisPayment.TxType />
		<cfset VARIABLES.Status = thisPayment.Status />
		<cfset VARIABLES.TxAuthCode = thisPayment.TxAuthCode />
		<cfset VARIABLES.VPSTxID = thisPayment.VPSTxID />
		
		<cfif !thisPayment.recordCount>
			<cfthrow message="Payment not found!" />
		</cfif>
		
		<cfset VARIABLES.ID = ARGUMENTs.PaymentID />
		
		<cfreturn this />		
	</cffunction>
	
	<cffunction name="isPayment" output="false">
		<cfreturn VARIABLES.TxType is "Deferred" OR VARIABLES.TxType is "Payment" />
	</cffunction>
	
	<cffunction name="isAuthorised" output="false">
		<cfreturn VARIABLES.TxAuthCode is not "" />
	</cffunction>
	
	<cffunction name="isSuccessfulPayment" output="false">
		<cfreturn isPayment() AND isAuthorised() />
	</cffunction>
	


</cfcomponent>
