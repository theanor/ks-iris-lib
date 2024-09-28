/// CAVEAT : this adapter is compatible only with Windows plaforms
/// This file inbound adapter connects to the <property>FilePath</property> using the user name and password associated with <property>Credentials</property> (see <class>Ens.Config.Credentials</class>)
/// It extends <class>EnsLib.File.InboundAdapter</class>
Class ks.lib.file.ba.UNCInboundAdapter Extends EnsLib.File.InboundAdapter
{

Parameter SETTINGS = "Credentials:Basic:credentialsSelector,DeleteFromServer,SortedBy";

Property Credentials As %String(MAXLEN = 64);

Property SortedBy As %String(VALUELIST = ",DateModified,ItemName,Name,Size");

Method OnInit() As %Status
{
	 
	 #Dim sc As %Status
	 #Dim ex As %Exception.AbstractException
	 #Dim path As %String
	 
	 s sc = $$$OK
	 try {

  	   if ##class(%File).DirectoryExists(..FilePath) {
			$$$TRACE("FilePath exists, need no connection")
	   } else 
	   {
		 if $isobject(..%CredentialsObj) {
		   s path = $zstrip(..FilePath,">","\")  // sanitize UNC path
	   	   $$$TRACE("connecting "_path)
	       $$$TOE(sc,##class(ks.lib.file.Utils).ConnectUNCPathAs(path,..%CredentialsObj.Username,..%CredentialsObj.Password))	   
  	       $$$TRACE("file path exists: "_##class(%File).DirectoryExists(path))		 		
		 } else {
           throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR("cannot connect with empty credentials"))
		 }
	   }
	 } catch(ex)
	 {
	  s sc = ex.AsStatus() 	 
	 }
	 
	 return:$$$ISERR(sc) sc
	 return ##super()
}

ClassMethod FileListExecute(ByRef QHandle As %Binary, adapter As Ens.Adapter, directory As %String, wildcards As %String, dirsOrNoDirs As %Boolean = 0, semaphoreSpec As %String = "") As %Status
{
	s QHandle=adapter
    s QHandle("dirsOrNoDirs")=dirsOrNoDirs
	s QHandle("semaphoreSpec")=semaphoreSpec
	s:'$IsObject(QHandle.%innerRS) QHandle.%innerRS=##class(%ResultSet).%New("%File:FileSet")
	$$$ASSERT($IsObject(QHandle.%innerRS))
	return QHandle.%innerRS.Execute(directory,wildcards,adapter.SortedBy,dirsOrNoDirs)
}

}
