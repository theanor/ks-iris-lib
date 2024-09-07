Class ks.lib.hl7.ba.FileOutboundAdapter Extends ks.lib.file.ba.OutboundAdapter
{

Method CreateFilename(pFileName As %String, pSpec As %String, pIsVMS As %Boolean, pDirectory As %String, pLocal As %Boolean) As %String
{
	#Dim sc as %Status
	#Dim ex as %Exception.AbstractException
	#Dim fileName as %String
	
	s sc = $$$OK
	try {
  	  if $isobject(..BusinessHost.%RequestHeader) &&
	     $classmethod(..BusinessHost.%RequestHeader.MessageBodyClassName,"%Extends","EnsLib.HL7.Message") {
	    s msg = ##class(EnsLib.HL7.Message).%OpenId(..BusinessHost.%RequestHeader.MessageBodyId)
	    if $isobject(msg) {		  
	  	  s pSpec = ##class(ks.lib.hl7.Utils).ParseExpressions(msg,pSpec,.sc)
		  $$$TRACE("spec after HL7 expressions parsing : "_pSpec)
	    }
	  } 
	}
	catch (ex) {
	  // do nothing, fall back to ##super
	}	
	return ##super(.pFileName,.pSpec,.pIsVMS,.pDirectory,.pLocal)
}

}
