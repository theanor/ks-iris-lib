/// HL7 file outbound adapter, using <class>ks.lib.file.ba.UNCOutboundAdapter</class>
/// This adapter also adds expression parsing to <method>CreateFilename</method> : see <method>ks.lib.hl7.Utils.ParseExpressions</method>
Class ks.lib.hl7.ba.FileOutboundAdapter Extends ks.lib.file.ba.UNCOutboundAdapter
{

Method CreateFilename(ByRef pFileName As %String, ByRef pSpec As %String, ByRef pIsVMS As %Boolean, ByRef pDirectory As %String, ByRef pLocal As %Boolean) As %String
{
	#Dim sc as %Status
	#Dim ex as %Exception.AbstractException
	
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
