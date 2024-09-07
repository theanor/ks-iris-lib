Class ut.ks.lib.hl7.UtilsTest Extends ks.lib.test.TestCase
{

Method TestParseExpressions()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim msg as EnsLib.HL7.Message
    
    s sc = $$$OK
    try {
      s msg = ##class(ks.lib.hl7.Utils).ImportFromXData($this,"TestMessage","2.5")
      d $$$AssertTrue($isobject(msg),"import message")
      $$$TOE(sc,##class(ks.lib.hl7.Utils).ResolveDocType(msg,"2.5"))
      s val = ##class(ks.lib.hl7.Utils).ParseExpressions(msg,"${MSH:10}",.sc)
      d $$$AssertEquals(val,"oz240211142842462236")      
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

XData TestMessage [ MimeType = application/hl7 ]
{
MSH|^~\&|||||20240211142842||ADT^A01|oz240211142842462236|D|2.5
EVN|A01|20240211142842
PID|||36||Hammel^Pam||20170211|
PV1||I|18^17^2||||||||||||||||36.112|||||||||||||||||||||||||
}

}
