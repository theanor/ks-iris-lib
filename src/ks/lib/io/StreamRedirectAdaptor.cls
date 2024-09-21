/// extend this class and use <method>EnableRedirection</method> to redirect I/O to a stream
Class ks.lib.io.StreamRedirectAdaptor
{

/// enable redirection to <b>stream</b>
ClassMethod EnableRedirection(stream As %Stream.Object) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim %outputStream as %Stream.Object
    #Dim %savedIO,%savedMnemonic,%savedState as %String
    
    s sc = $$$OK
    try {
      s %outputStream = stream
      s %savedIO = $IO
      s %savedMnemonic = ##class(%Library.Device).GetMnemonicRoutine()
      s %savedState = ##class(%Library.Device).ReDirectIO()
      use $IO::("^"_$ZNAME)
      d ##class(%Library.Device).ReDirectIO(1)
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

/// disable current redirection (must be balanced with <method>EnableRedirection</method>)
ClassMethod DisableRedirection() As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    
    s sc = $$$OK
    try {
     if $data(%savedIO) && $data(%savedState) && $data(%savedMnemonic) {
       if %savedMnemonic="" {
         use %savedIO
       } else {
         use %savedIO::("^"_%savedMnemonic)
       }
       d ##class(%Library.Device).ReDirectIO(%savedState)
     } else {
        throw ##class(%Exception.General).%New("redirection not enabled")
     }
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

ClassMethod DeviceEntryPoints() [ Private, ProcedureBlock = 0 ]
{
    return
rchr(c)      return
rstr(sz,to)  return
wchr(s)      d:$isobject(%outputStream) %outputStream.Write(s) return
wstr(s)      d:$isobject(%outputStream) %outputStream.Write(s) return
wff()        d:$isobject(%outputStream) %outputStream.Write($char(12)) return
wnl()        d:$isobject(%outputStream) %outputStream.WriteLine("") return
wtab(s)      d:$isobject(%outputStream) %outputStream.Write($char(9)) return
}

}
