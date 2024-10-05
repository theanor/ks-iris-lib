Class ut.ks.lib.record.RecordTest Extends %UnitTest.TestCase
{

Method TestDelimited()
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim record As DelimitedRecord
  #Dim str As %String

  
  s sc = $$$OK
  try {
    s str = """hello"",,""world"""
    s record = ##class(DelimitedRecord).%New()
    $$$TOE(sc,record.ImportFromString(str))    
    d $$$AssertEquals(record.Foo,"hello")
    d $$$AssertEquals(record.Bar,"world")
    $$$TOE(sc,record.ExportToString(.exportedStr))
    d $$$AssertTrue($data(exportedStr))
    d $$$AssertEquals(str,exportedStr)
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  d $$$AssertStatusOK(sc)
}

Method TestFixed()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    
    s sc = $$$OK
    try {
      s str = "hello      world          "
      s record = ##class(FixedRecord).%New()
      $$$TOE(sc,record.ImportFromString(str))    
      d $$$AssertEquals(record.Foo,"hello")
      d $$$AssertEquals(record.Bar,"world")      
      $$$TOE(sc,record.ExportToString(.exportedStr))
      d $$$AssertTrue($data(exportedStr))
      d $$$AssertEquals(str,exportedStr)        
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

}
