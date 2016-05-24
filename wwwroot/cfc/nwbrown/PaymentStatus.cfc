<cfcomponent persistent="true">
	<cfproperty name="ID" fieldType="id" generator="native" column="PaymentStatusID" type="numeric" ormType="int" />
	<cfproperty name="Title" column="PaymentStatusTitle" />
</cfcomponent>