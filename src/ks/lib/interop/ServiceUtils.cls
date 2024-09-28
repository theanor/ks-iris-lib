/// Business service utilities
Class ks.lib.interop.ServiceUtils
{

/// Sends <b>message</b> to business service named <b>configName</b> in current namespace production, calling service <b>ProcessInput()</b> method
ClassMethod TriggerService(configName As %String, message As %RegisteredObject) As %Status
{
	 #Dim sc as %Status
	 #Dim ex as %Exception.AbstractException
	 #Dim service as Ens.BusinessService
	 
	 
	 s sc = $$$OK
	 try {
		 $$$TOE(sc,##class(Ens.Director).CreateBusinessService(configName,.service))
		 if ($IsObject(service)) {		 
		 $$$TOE(sc,service.ProcessInput(message,.result))		 
	     }		 
	 } catch (ex) {
	  s sc = ex.AsStatus()
	 }
	 return sc
}

/// <p>send <b>request</b> asynchronously to all targets in the comma-separated list of configuration item names <b>targetConfigNames, by passing 
/// repeatedly invoking <b>service.SendRequestAsync()</b>, passing optional <b>description</b> 
ClassMethod SendRequestAsync(service As Ens.BusinessService, targetConfigNames As %String, request As Ens.MessageBody, description As %String = "") As %Status
{
 	#Dim sc,srStatus as %Status
	#Dim ex as %Exception.AbstractException
	
	#Dim items
	
	s sc = $$$OK
	try {
	  $$$TOE(sc,##class(Ens.DataType.ConfigName).ParseConfigNameSpec(targetConfigNames, ",", .items))
	  for i=1:1:items {
   		s srStatus=service.SendRequestAsync(items(i),request,description)
   		s:$$$ISERR(srStatus) sc=$$$ADDSC(sc,srStatus)		  
	  }	  
	} catch (ex) {
		s sc = ex.AsStatus()
	}
    return sc
}

ClassMethod CreateService(serviceClass As %Dictionary.Classname, ByRef service As Ens.BusinessService) As %Status
{
	#Dim sc as %Status = $$$OK
	#Dim ex as %Exception.AbstractException

	#Dim productionName As %Dictionary.Classname
	#Dim production As Ens.Config.Production
	#Dim item As Ens.Config.Item
		
	try {
		s productionName = ##class(Ens.Director).GetActiveProductionName()
		s production = ##class(Ens.Config.Production).%OpenId(productionName)
		for i=1:1:production.Items.Size
		 {
	      s item = production.Items.GetAt(i)
		  if $CLASSMETHOD(item.ClassName,"%Extends","Ens.BusinessService") && (item.ClassName=serviceClass) {
			$$$TOE(sc,##class(Ens.Director).CreateBusinessService(item.Name,.service))
			q
		  }
		 }		
	} catch (ex) {
	  s sc = ex.AsStatus()
	}
	return sc
}

}
