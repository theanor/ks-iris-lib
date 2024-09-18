Class ks.lib.hl7.bo.FileOperation Extends (EnsLib.HL7.Operation.FileOperation, ks.lib.file.bo.Commons)
{

Parameter SETTINGS = "IgnoreNullMessages";

Parameter ADAPTER = "ks.lib.hl7.ba.FileOutboundAdapter";

/// If this is true, incoming null messages (header with no message body classname) will be ignored and operaton will log info instead of error and set message status to 'completed'
Property IgnoreNullMessages As %Boolean [ InitialExpression = 1 ];

Property Adapter As ks.lib.hl7.ba.FileOutboundAdapter;

Method MessageHeaderHandler(pRequestHeader As Ens.MessageHeader, Output pResponseHeader As Ens.MessageHeader) As %Status
{
  if (pRequestHeader.MessageBodyClassName="") && ..IgnoreNullMessages {
    d pRequestHeader.SetStatus($$$eMessageStatusCompleted)
    s sc = $$$OK
    $$$TRACE("ignored incoming empty (no message body class name) message")
  } else {
    s sc = ##super(pRequestHeader,.pResponseHeader)
  }
  return sc
}

Method outputDocument(pFilename As %String, pDocument As EnsLib.HL7.Message, pSeparators As %String, pDoFraming As %Integer) As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException
   
    try {
        $$$TOE(sc,##super(pFilename,pDocument,pSeparators,pDoFraming))
        $$$TOE(sc,..PutSemaphoreFile(pFilename))
    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

}
