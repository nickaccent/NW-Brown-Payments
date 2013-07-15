<cfparam name="URL.PaymentRequestID" type="numeric" />

<cfset thisPaymentRequest = entityLoad("PaymentRequest", URL.PaymentRequestID, true) />

<cf_css>
	
    #payment-portal-wrap section { background:#FFF; padding:8px 16px; }
    h1 { margin-bottom:5px; margin-top:5px; }
    
    <cfif thisPaymentRequest.getHasBeenPaid()>
    	body { background: #C5F0AC url('/img/bg-striped.png'); }
        #payment-portal-wrap section { border:1px solid #A6DE85;}
    <cfelse>
    	body { background: #FB6341 url('/img/bg-striped-fail.png'); }
        #payment-portal-wrap section { border:1px solid #FB0009;}
    </cfif>
    
    p { margin: 0 0 10px 0;}
    .success h1 {color:#335D2B;}
    .fail h1, .fail h2 {color:#B32100;}
   
    .alpha { text-align:center; }
    .beta { margin-bottom:0;}
    
    form fieldset { }
    table { margin-bottom:20px;}
    th { white-space:nowrap; text-align:left; padding:0 0 5px 15px;}
    td { padding:10px 0 10px 15px; background:#F5F5F5;}
    th:first-child { padding-left:0;}
    input[type='submit'] { margin-bottom:5px;}
</cf_css>

<cf_page>
	<script>if(top != self) top.location = document.location;</script>
<div id="payment-portal-wrap" class="<cfif thisPaymentRequest.getHasBeenPaid()>success<cfelse>fail</cfif>">
    
	<section>
	
	<cfif thisPaymentRequest.getHasBeenPaid()>
    	<h1>Successful</h1>
		<cfoutput>
			<p class="beta">Your payment was successful. This transaction will be logged in SagePay with vendor tx code</p>
            <p class="alpha">#thisPaymentRequest.getSuccessfulPayment().getVendorTxCode()#</p>
			<p><em>Please feel free to close this window whenever you wish.</em></p>
		</cfoutput>
	<cfelse>
    
    	<h1>Error</h1>
		<p class="beta">Payment was not successful at this point.</p>
		<form id="payment-portal" action="<cfoutput>paymentRequest.cfm?id=#URL.PaymentRequestID#</cfoutput>" method="post">
			<!---<h2>Payment Attempts</h2>--->
			<fieldset>
				<table>
					<tr>
						<th>Payment ID</th>
						<th>Type</th>
						<th>Vendor Code</th>
						<th>Status</th>
					</tr>
					<cfoutput>
					<cfloop array="#thisPaymentRequest.getPayments()#" index="local.thisPayment">
						<tr>
							<td>#local.thisPayment.getID()#</td>
							<td>#local.thisPayment.getTxType()#</td>
							<td>#local.thisPayment.getVendorTxCode()#</td>
							<td>#local.thisPayment.getStatus()# - #local.thisPayment.getStatusDetail()#</td>
						</tr>
					</cfloop>
					</cfoutput>
				</table>
				
                <cfoutput>
					<input type="submit" class="primary"
						onclick="window.location = '';"
						value="Go back to Sagepay &amp; Try Again"
					/>
					<!---
					<input type="button" class="secondary"
						onclick="window.location = 'index.cfm?paymentrequestid=#URL.PaymentRequestID#&paymentsessionid=#thisPaymentRequest.getPaymentSession().getID()#';"
						value="Edit Payee Details &amp; Try Again"
					/>
					--->
					
					<p><em>Please close this window if you do not wish to try again at this time.</em></p>
				</cfoutput>
                
			</fieldset>

			
		</form>
	</cfif>
	</section>
</div>
</cf_page>