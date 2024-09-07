Class ks.lib.file.ba.UNCInboundAdapter Extends EnsLib.File.InboundAdapter
{

Parameter SETTINGS = "Credentials:Basic:credentialsSelector,DeleteFromServer,SortedBy";

Property Credentials As %String;

Property SortedBy As %String(VALUELIST = ",DateModified,ItemName,Name,Size");

Method OnInit() As %Status
{
	 
	 #Dim sc As %Status
	 #Dim ex As %Exception.AbstractException
	 #Dim zfret As %Integer
	 #Dim windir As %String
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
	 
	 q:$$$ISERR(sc) sc
	 q ##super()
}

ClassMethod FileListExecute(ByRef QHandle As %Binary, adapter As Ens.Adapter, directory As %String, wildcards As %String, dirsOrNoDirs As %Boolean = 0, semaphoreSpec As %String = "") As %Status
{
	Set QHandle=adapter
	Set QHandle("dirsOrNoDirs")=dirsOrNoDirs
	Set QHandle("semaphoreSpec")=semaphoreSpec
	Set:'$IsObject(QHandle.%innerRS) QHandle.%innerRS=##class(%ResultSet).%New("%File:FileSet")
	$$$ASSERT($IsObject(QHandle.%innerRS))
	Quit QHandle.%innerRS.Execute(directory,wildcards,adapter.SortedBy,dirsOrNoDirs)
}

}
