Class ut.ks.lib.collections.ListOfDataTypesTest Extends ks.lib.test.TestCase
{

Method TestList()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim listOfDT as ks.lib.collections.ListOfDataTypes
    #Dim list as %List
    #Dim ptr as %Integer
    #Dim dtKey,dt,dtFromObj as %String
    
    s sc = $$$OK
    try {
        s list = $listbuild("foo","bar")        
        s listOfDT = ##class(ks.lib.collections.ListOfDataTypes).%New()
        $$$TOE(sc,listOfDT.%SetSerial(list))

        d $$$AssertEquals($listlength(list),listOfDT.Size)
        s ptr = 0    
        while $listnext(list,ptr,dt) {
            s dtFromObj = listOfDT.GetNext(.dtKey)
            d $$$AssertEquals(dt,dtFromObj)
        }
        s listFromObj = listOfDT.%GetSerial()        
        d $$$AssertEquals(list,listFromObj)
    
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

}
