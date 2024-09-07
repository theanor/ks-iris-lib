Class ks.lib.ftp.bo.Operation Extends (EnsLib.FTP.PassthroughOperation, ks.lib.file.bo.Commons)
{

Parameter ADAPTER = "EnsLib.FTP.OutboundAdapter";

Property Adapter As EnsLib.FTP.OutboundAdapter;

Method OnMessage(pRequest As Ens.StreamContainer, Output pResponse As %Persistent) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    
    s sc = $$$OK
    try {
        $$$TOE(sc,##super.OnMessage(pRequest,.pResponse))
        $$$TOE(sc,..PutSemaphoreFile(..Adapter.CreateFilename(##class(%File).GetFilename(pRequest.OriginalFilename),..Filename)))
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

}
