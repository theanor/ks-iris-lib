Class ut.ks.lib.io.StreamRedirectAdaptorTest Extends (ks.lib.test.TestCase, ks.lib.io.StreamRedirectAdaptor)
{

Method TestHtmlDirective() As %Status
{
    #Dim sc,dSc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim stream as %Stream.TmpCharacter
    #Dim someVar as %String
      
    

    s sc = $$$OK

    try {
      s stream = ##class(%Stream.TmpCharacter).%New()
      $$$TOE(sc,..EnableRedirection(stream))
    } catch(ex) {
      return ex.AsStatus()
    }

    try {

      s someVar = "foo bar"

      &html<<p>hello,&nbsp;#(someVar)#</p>>

    } catch (ex) {
      s sc = ex.AsStatus()
    }

    s dSc = $$$OK
    try {
      $$$TOE(dSc,..DisableRedirection())      
    } catch (ex) {
      s dSc = ex.AsStatus()
    }
    d $$$AssertStatusOK(dSc)
    d $$$AssertTrue($isobject(stream))
    d $$$AssertTrue(stream.Size > 0)    
    d $$$LogMessage("output stream size : "_stream.Size)
    s expected = "<p>hello,&nbsp;"_someVar_"</p>"_$char(13,10)
    s data = stream.Read()
    d $$$AssertEquals(expected,data)
    d $$$AssertStatusOK(sc)
}

ClassMethod DeviceEntryPoints() [ ProcedureBlock = 0 ]
{
    return
rchr(c)      return
rstr(sz,to)  return
wchr(s)      d:$isobject(%outputStream) %outputStream.Write(s) return
wstr(s)      d:$isobject(%outputStream) %outputStream.Write(s) return
wff()        d:$isobject(%outputStream) %outputStream.Write($char(12)) return
wnl()        d:$isobject(%outputStream) %outputStream.Write($char(13,10)) return
wtab(s)      d:$isobject(%outputStream) %outputStream.Write($char(9)) return
}

}
