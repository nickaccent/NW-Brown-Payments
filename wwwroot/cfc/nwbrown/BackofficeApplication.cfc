<cfcomponent persistent="true">
	<cfproperty name="ID" column="BackOfficeApplicationID" fieldType="id" />
	<cfproperty name="Title" column="BackOfficeApplicationTitle" />
	<cfproperty name="LiveDatasource" column="BackOfficeApplicationLiveDatasource" />
	<cfproperty name="TestDatasource" column="BackOfficeApplicationTestDatasource" />
	<cfproperty name="VendorName" column="BackOfficeApplicationVendorName" />
	
	<cffunction name="getDatasource" output="false" hint="based on whether the application is in local or live mode, return the appropriate datasource">
		<cfreturn ( application.local ? getTestDatasource() : getLiveDatasource() ) />
	</cffunction>
</cfcomponent>