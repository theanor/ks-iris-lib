/// <class>EnsLib.HL7.Message</class> archive operation
Class ks.lib.archive.bo.HL7Operation Extends AbstractOperation
{

Property FileSpec As %String(MAXLEN = 128) [ InitialExpression = "%Y%m%d%H%M%S%N%!#+(.000)-%f.hl7" ];

Property FileNameExpressions As %String(MAXLEN = 32) [ InitialExpression = "Body.Name-BodyId" ];

/// extract hl7 message stream
Method MessageStream(header As Ens.MessageHeader, message As EnsLib.HL7.Message, Output messageStream As %Stream.Object) As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException

    
    try {
        s messageStream = ##class(%Stream.TmpCharacter).%New()
        $$$TOE(sc,message.OutputToLibraryStream(messageStream))
    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

}
