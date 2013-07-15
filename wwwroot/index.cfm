<cflocation url="timeout.cfm" addtoken="no" />

<!---
<cfparam name="URL.PaymentSessionID" type="numeric" />
<cfset PaymentSession = entityLoad("PaymentSession", URL.PaymentSessionID, true) />

<cfloop list="payee,address1,address2,address3,address4,postcode,amount" index="f">
	<cfif f eq "amount">
		<cfset fieldValue = PaymentSession.getPremium() />
	<cfelse>
		<cfset fieldValue = evaluate("PaymentSession.get#f#()") />
	</cfif>	
	<Cfparam name="FORM.#f#" default="#( isNull(fieldValue) ? '' : fieldValue )#" />
</cfloop>

<!--- If continued, create payment request, and jump to sagepay --->
<cfif VARIABLES.Submit>
	<cfset VARIABLES.paymentRequest = entityNew("PaymentRequest") />
	<cfset VARIABLES.paymentRequest.setPayee(FORM.Payee) />
	<cfset VARIABLES.paymentRequest.setAddress1(FORM.Address1) />
	<cfset VARIABLES.paymentRequest.setAddress2(FORM.Address2) />
	<cfset VARIABLES.paymentRequest.setAddress3(FORM.Address3) />
	<cfset VARIABLES.paymentRequest.setAddress4(FORM.Address4) />
	<cfset VARIABLES.paymentRequest.setPostcode(FORM.Postcode) />
	<cfset VARIABLES.paymentRequest.setAmount(FORM.Amount) />
	<cfset paymentSession.addPaymentRequest(VARIABLES.paymentRequest) />
	<cfset entitySave(VARIABLES.paymentRequest) />
	<cflocation url="paymentRequest.cfm?id=#paymentRequest.getID()#" addtoken="no" />
</cfif>

<cf_js position="top">
  	<!--- Validation http://bassistance.de/jquery-plugins/jquery-plugin-validation/ --->
	$.validator.setDefaults({
		//submitHandler: function() { alert("submitted!"); }
	});
	$().ready(function () {
		// validate the comment form when it is submitted
		$("#payment-portal").validate();
	});
</cf_js>

<cf_page title="Payment Portal | Make Payment">

<!---<div id="payment-portal-wrap">
	<section>
		<h1>Make a Payment</h1>
		<cfoutput>
		<h2>Payment Details</h2>
		<div class="form-wrap clearfix">
			<ol class="no-bull details">
				<li class="beta">Your Total</li>
				<li class="alpha">&pound;#decimalFormat(PaymentSession.getPremium())#</li>
			</ol>
			<ol class="no-bull details">
				<li class="beta">Your Reference</li>
				<li class="alpha">#PaymentSession.getReference()#</li>
			</ol>
		</div>
	
		<h2>Billing Details</h2>
		<form method="post" action="" id="payment-portal">
		<div class="form-wrap">
			<fieldset>
				<ol class="no-bull">
					<li>
						<label for="payee">Payee</label>
						<input type="text" name="payee" id="payee" class="medium required" value="#form.payee#" />
					</li>
					<li>
						<label for="address">Address</label>
						<input type="text" name="address1" id="address" class="medium required" value="#form.address1#" />
					</li>
					<li>
						<label>&nbsp;</label>
						<input type="text" name="address2" class="medium required" value="#form.address2#" />
					</li>
					<li>
						<label>&nbsp;</label>
						<input type="text" name="address3" class="medium required" value="#form.address3#" />
					</li>
					<li>
						<label>&nbsp;</label>
						<input type="text" name="address4" class="medium required" value="#form.address4#" />
					</li>
					<li>
						<label for="postcode">Postcode</label>
						<input type="text" name="postcode" id="postcode" class="medium required" value="#form.postcode#" />
					</li>
				</ol>
			</fieldset>
		</div>
			<!---<fieldset>
				<ul>
					<li>
						<label>Amount to be paid:</label>
						<input type="text" name="amount" value="#form.amount#" />
					</li>
				</ul>
			</fieldset>--->
			
			<fieldset class="right">
				<input type="button" name="cancel" class="secondary" value="Cancel" />
				<input type="submit" name="continue" class="primary" value="Continue to SagePay" />
				<!---<button type="button">Cancel</button>--->
			</fieldset>
		</form>
		</cfoutput>
	</section>
</div>--->

<div id="payment-portal-wrap">
	<section>
		<h1>Make a Payment</h1>
		<cfoutput>
		<h2>Payment Details</h2>
		<div class="form-wrap clearfix">
			<ol class="no-bull details">
				<li class="beta">Your Total</li>
				<li class="alpha">&pound;#decimalFormat(PaymentSession.getPremium())#</li>
			</ol>
			<ol class="no-bull details">
				<li class="beta">Your Reference</li>
				<li class="alpha">#PaymentSession.getReference()#</li>
			</ol>
		</div>
	
		<h2>Billing Details</h2>
		<form method="post" action="" id="payment-portal" name="payment-portal">
		<div class="form-wrap">
			<fieldset>
				<ol class="form">
					<li>
						<label for="payee">Payee</label>
						<input type="text" name="payee" id="payee" class="medium required" value="#form.payee#" />
					</li>
					<li class="address">
						<label for="address">Address</label>
						<input type="text" name="address1" id="address" class="medium required" value="#form.address1#" />
						<input type="text" name="address2" class="medium required" value="#form.address2#" />
						<input type="text" name="address3" class="medium required" value="#form.address3#" />
						<input type="text" name="address4" class="medium" value="#form.address4#" />
					</li>
					<li>
						<label for="postcode">Postcode</label>
						<input type="text" name="postcode" id="postcode" class="medium required" value="#form.postcode#" />
					</li>
				</ol>
			</fieldset>
		</div>
			<!---<fieldset>
				<ul>
					<li>
						<label>Amount to be paid:</label>
						<input type="text" name="amount" value="#form.amount#" />
					</li>
				</ul>
			</fieldset>--->
			
			<fieldset class="right">
				<input type="button" name="cancel" class="secondary" value="Cancel">
				<input type="submit" name="continue" class="primary" value="Continue to SagePay">
				<!---<button type="button">Cancel</button>--->
			</fieldset>
		</form>
		</cfoutput>
	</section>
</div>
</cf_page>
--->