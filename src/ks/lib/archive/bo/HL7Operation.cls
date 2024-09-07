Class ks.lib.archive.bo.HL7Operation Extends AbstractOperation
{

Property FileSpec As %String(MAXLEN = 128) [ InitialExpression = "%Y%m%d%H%M%S%N%!#+(.000)-%f.hl7" ];

Property FileNameExpressions As %String(MAXLEN = 32) [ InitialExpression = "Body.Name-BodyId" ];

Method MessageStream(header As Ens.MessageHeader, message As EnsLib.HL7.Message, Output messageStream As %Stream.Object, ByRef tag As %String) As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException

    
    try {
        s messageStream = ##class(%Stream.TmpCharacter).%New()
        $$$TOE(sc,message.OutputToLibraryStream(messageStream))
        s tags = $listbuild(message.Name,message.%Id())
    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

}
