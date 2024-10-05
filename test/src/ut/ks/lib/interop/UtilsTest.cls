Class ut.ks.lib.interop.UtilsTest Extends ks.lib.test.TestProduction
{

Parameter PRODUCTION = "ut.ks.lib.interop.Production";

Parameter IGNOREPRODUCTIONERRORS = 1;

Property ItemName As Ens.DataType.ConfigName [ InitialExpression = "FooOperation", Private, ReadOnly ];

Property ItemClass As %Dictionary.Classname [ InitialExpression = {##class(TestOperation).%ClassName(1)}, Private, ReadOnly ];

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
    #Dim production as Ens.Production

    Try {        
        $$$TOE(sc,..AddConfigItemSetup(..ItemName,..ItemClass))
        $$$TOE(sc,..GetSetSettings())
    }
    Catch (ex) {
      Set sc = ex.AsStatus()
    }
    Quit sc
}

Method GetSetCagegory() As %Status [ Private ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
  
  s sc = $$$OK
  try {
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method GetSetSettings() As %Status [ Private ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim itemName as Ens.DataType.ConfigName

  
  s sc = $$$OK
  try {
        s itemName="FileOperation"
        s fileName="test.txt"
        s itemCategory="test-item"

        s item = ##class(ks.lib.interop.ConfigUtils).GetConfigItem(itemName,..#PRODUCTION,.sc)
        $$$TOE(sc,sc)
        d $$$AssertTrue($isobject(item))    
        $$$TOE(sc,##class(ks.lib.interop.ConfigUtils).SetSetting(item,"Filename",fileName,"Host"))
        d $$$AssertEquals(fileName,##class(ks.lib.interop.ConfigUtils).GetSetting(item.Name,"Filename",..#PRODUCTION,.sc))

        s item.Category = itemCategory
        $$$TOE(sc,item.%Save())

        $$$TOE(sc,##class(ks.lib.interop.ConfigUtils).GetCategoryItems(..#PRODUCTION,itemCategory,.items))
        d $$$AssertTrue($isobject(items))
        d $$$AssertEquals(items.Size,1)
        d $$$AssertTrue($isobject(items.GetAt(1)))
        d $$$AssertEquals(item.Name,items.GetAt(1).Name)
        d $$$AssertEquals(item.Category,items.GetAt(1).Category)
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method AddConfigItemSetup(itemName As Ens.DataType.ConfigName, itemClass As %Dictionary.Classname) As %Status [ Private ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim fileName as %String
  
  s sc = $$$OK
  try {                
        s production = ##class(Ens.Config.Production).%OpenId(..#PRODUCTION)
        d $$$AssertTrue($isobject(production))
        $$$TOE(sc,##class(ks.lib.interop.ConfigUtils).AddConfigItem(production,itemName,itemClass,.fooOperation))
        $$$TOE(sc,production.%Save())

        $$$TOE(sc,##class(ks.lib.interop.ConfigUtils).FindItemsOfClass(##class(TestOperation).%ClassName(1),.items,..#PRODUCTION))
        d $$$AssertTrue($data(items))
        d $$$AssertEquals(items,1)
        d $$$AssertTrue($isobject(items(1)))
        d $$$AssertTrue(items(1).%Extends("Ens.Config.Item"))
        d $$$AssertEquals(items(1).Name,itemName)

  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method OnAfterProductionStart() As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException

  Try {
    $$$TOE(sc,..AddConfigItemCheck())
  }
  Catch (ex) {
    Set sc = ex.AsStatus()
  }
  Quit sc
}

Method AddConfigItemCheck() As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim request As Ens.StringRequest
  #Dim response As Ens.StringResponse

  
  s sc = $$$OK
  try {
    s request = ##class(Ens.StringRequest).%New("hello, world")
    $$$TOE(sc,..SendRequest(..ItemName,request,.response,1))
    d $$$AssertTrue($isobject(response))
    d $$$AssertEquals(request.StringValue,response.StringValue)
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
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
