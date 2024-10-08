Class ut.ks.lib.archive.ProductionTest Extends ks.lib.test.TestProduction
{

Parameter PRODUCTION = "ut.ks.lib.archive.Production";

Parameter IGNOREPRODUCTIONERRORS = 1;

Method TestDummy()
{
}

Method OnBeforeAllTests() As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException
    
    try {
    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
    q sc
}

Method OnBeforeProductionStart() As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException

    Try {
     $$$TOE(sc,..ChangeSetting(..#PRODUCTION,"HL7Operation","RootDirectory",..HL7OutputDir,1))
     $$$TOE(sc,..ChangeSetting(..#PRODUCTION,"XMLOperation","RootDirectory",..HL7OutputDir,1))
    }
    Catch (ex) {
      Set sc = ex.AsStatus()
    }
    Quit sc
}

Method OnAfterProductionStart() As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException

  #Dim hl7Msg As EnsLib.HL7.Message
  #Dim xmlMsg As TestMessage


  Try {
    s hl7Msg = ..ImportHL7FromFile("archive\msg\test.hl7","2.5")    
    d $$$AssertTrue($isobject(hl7Msg))
    $$$TOE(sc,..SendRequest("HL7Operation",hl7Msg,,0))
    s xmlMsg = ..ImportXMLFromFile("ut.ks.lib.archive.TestMessage","archive\msg\test.xml")
    $$$TOE(sc,..SendRequest("XMLOperation",xmlMsg,,0))
  }
  Catch (ex) {
    Set sc = ex.AsStatus()
  }
  Quit sc
}

Method CheckResults(ByRef log As %String, new As %String) As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException
  
  Try {
  }
  Catch (ex) {
    Set sc = ex.AsStatus()
  }
  Quit sc
}

}
