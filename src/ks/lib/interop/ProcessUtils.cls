Class ks.lib.interop.ProcessUtils
{

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
    q sc
}

}
