Class ks.lib.file.ba.UNCOutboundAdapter Extends EnsLib.File.OutboundAdapter
{

Parameter SETTINGS = "Credentials:Basic:credentialsSelector,SharePath:Basic";

Property Credentials As %String;

Property SharePath As %String(MAXLEN = 128);

Method OnInit() As %Status
{
	 
	 #Dim sc As %Status
	 #Dim ex As %Exception.AbstractException	 
	 s sc = $$$OK
	 try {
	   if $isobject(..%CredentialsObj) && (..SharePath '= "") {
	     $$$TOE(sc,##class(ks.lib.file.Utils).ConnectUNCPathAs(..SharePath,..%CredentialsObj.Username,..%CredentialsObj.Password))	   
	   }
	 } catch(ex)
	 {
	  s sc = ex.AsStatus() 	 
	 }
	 
	 q ##super()
}

Method FilePathGet() As %String
{
	s directory = ##class(Ens.Util.Time).FormatDateTime(i%FilePath)
    if '##class(%File).DirectoryExists(directory) {
      if '##class(%File).CreateDirectoryChain(directory,.rc) {
        $$$LOGERROR("attempt to create archive directory chain failed : "_directory_" (return code : "_rc_")")
      }
	}
	return directory
}

}
