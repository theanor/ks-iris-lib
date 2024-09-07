Class ks.lib.file.Utils
{

ClassMethod ConnectUNCPathAs(UNCPath As %String, username As %String, password As %String) As %Status
{
	
	#Dim sc as %Status
	#Dim ex as %Exception.AbstractException

	#Dim windir as %String
	
	s sc = $$$OK
	try {		
	   s windir = ##class(%SYSTEM.Util).GetEnviron("windir")
	   if windir="" throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR("WINDIR environment variable not found. Not running Windows ?"))
	   s zfret = $zf(-100,"/LOGCMD",##class(%File).NormalizeFilename("system32\net.exe",windir),"use",UNCPath,"/USER:"_username,password,"/persistent:no")	
	   if zfret '= 0 {
		 throw ##class(%Exception.General).%New("connection failed with return code "_zfret)
	   }
	} catch (ex) {
		s sc = ex.AsStatus()
	}
    q sc
}

}
