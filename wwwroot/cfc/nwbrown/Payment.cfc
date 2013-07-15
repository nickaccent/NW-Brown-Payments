<cfcomponent persistent="true">
	<cfproperty name="ID" fieldType="id" generator="native" column="PaymentID" />
	<cfproperty name="PaymentStatus" fieldType="many-to-one" fkcolumn="PaymentStatusID" cfc="PaymentStatus" />
	<cfproperty name="VPSProtocol" />
	<cfproperty name="Status" />
	<cfproperty name="StatusDetail" />
	<cfproperty name="TxType" />
	<cfproperty name="VPSTxID" />
	<cfproperty name="VendorTxCode" />
</cfcomponent>