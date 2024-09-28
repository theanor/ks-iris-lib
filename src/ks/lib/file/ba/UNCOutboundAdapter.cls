/// CAVEAT : this adapter is compatible only with Windows plaforms
/// This file inbound adapter connects to the <property>SharePath</property> using the user name and password associated with <property>Credentials</property> (see <class>Ens.Config.Credentials</class>)
/// It extends <class>EnsLib.File.InboundAdapter</class>
Class ks.lib.file.ba.UNCOutboundAdapter Extends EnsLib.File.OutboundAdapter
{

Parameter SETTINGS = "Credentials:Basic:credentialsSelector,SharePath:Basic";

/// Credentials used to access share
Property Credentials As %String;

/// Output UNC share path
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
