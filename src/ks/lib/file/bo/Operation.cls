Class ks.lib.file.bo.Operation Extends (Commons, EnsLib.File.PassthroughOperation)
{

Method OnMessage(pRequest As Ens.StreamContainer, Output pResponse As %Persistent) As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException

    #Dim fileName as %String
    
    try {
        $$$TOE(sc,##super(pRequest,.pResponse))
        $$$TOE(sc,..PutSemaphoreFile(..Adapter.CreateFilename(##class(%File).GetFilename(pRequest.OriginalFilename),..Filename)))
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    q sc
}

}
