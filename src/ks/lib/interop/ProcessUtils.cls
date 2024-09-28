/// Business process utilities
Class ks.lib.interop.ProcessUtils
{

/// <p>send <b>request</b> asynchronously to all targets in the comma-separated list of configuration item names <b>targetConfigNames, by passing 
/// repeatedly invoking <method>Ens.BusinessOperation.SendRequestAsync</method>, passing <b>responseRequired</b> and <b>completionKey</b>.
ClassMethod SendRequestAsync(process As Ens.BusinessProcess, targetConfigNames As Ens.DataType.ConfigName, request As Ens.MessageBody, responseRequired As %Boolean = 1, completionKey As %String = "", description As %String = "") As %Status
{
 	#Dim sc,srStatus as %Status
	#Dim ex as %Exception.AbstractException
	
	#Dim items
	#Dim newRequest as Ens.MessageBody
	
	s sc = $$$OK
	try {
	  $$$TOE(sc,##class(Ens.DataType.ConfigName).ParseConfigNameSpec(targetConfigNames, ",", .items))
	  for i=1:1:items {
		s newRequest = request.%ConstructClone(1)
   		s srStatus=process.SendRequestAsync(items(i),newRequest,responseRequired,completionKey,description)
   		s:$$$ISERR(srStatus) sc=$$$ADDSC(sc,srStatus)		  
	  }	  
	} catch (ex) {
		s sc = ex.AsStatus()
	}
    return sc
}

}
