Class ut.ks.lib.archive.ProductionTest Extends ks.lib.test.TestProduction
{

Parameter PRODUCTION = "test.ut.ks.lib.archive.Production";

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


  Try {
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
