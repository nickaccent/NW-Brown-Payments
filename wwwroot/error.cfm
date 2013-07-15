<cfheader statuscode="500" statustext="Internal Server Error">
<cfinclude template="/include/error-logger.cfm" />

<cf_css>
	.message { float:left; }
    #timeout h1 { margin:5px 0 0 0;}
    #timeout p { margin:0;}
</cf_css>

<cf_page>

<div id="payment-portal-wrap">
	<section class="clearfix">
		<!--- <img class="left" src="/img/PaymentPortal-timeout.png" alt="clock icon" /> --->
		<div class="message">
        	<h1>Sorry!</h1>
			<p>An error has occurred with the payments system. The error will be logged and technical department notified.</p>
        </div>
        
	</section>
</div>
</cf_page>