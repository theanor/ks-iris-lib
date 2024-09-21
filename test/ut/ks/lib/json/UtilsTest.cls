Class ut.ks.lib.json.UtilsTest Extends ks.lib.test.TestCase
{

Method TestObjectKeyList()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim ks as %List
    #Dim do as %DynamicObject
    
    s sc = $$$OK
    try {
        s do = {
            "foo" : "hello",
            "bar" : true,
            "int" : 42
        }
        s kl = ##class(ks.lib.json.Utils).ObjectKeyList(do)
        d $$$AssertEquals($listlength(kl),3)
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

Method TestKeyValueList()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim values as %List
    #Dim do as %DynamicObject    
    
    s sc = $$$OK
    try {
        s do = {
            "foo" : "hello",
            "bar" : true,
            "int" : 42
        }
        s values = ##class(ks.lib.json.Utils).KeyValuesList(do,$listbuild("foo","bar","int"))
        d $$$AssertEquals($listlength(values),3)    
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

Method TestFormatTimeStamp()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    
    #Dim ts as ks.lib.type.DateTime
    #Dim jts as %String    
    #Dim do as %DynamicObject
    #Dim ja as JSONAdaptor
    
    s sc = $$$OK
    try {
        s ts = ##class(ks.lib.type.DateTime).Now()
        d $$$LogMessage("ts : "_ts)
        s jts = ##class(ks.lib.json.Utils).FormatTimeStamp(ts)
        s do = {
            "Date":(jts)
        }
        d $$$AssertEquals(do.Date,jts)
        s ja = ##class(JSONAdaptor).%New()
        $$$TOE(sc,ja.%JSONImport(do)) 
        d $$$AssertEquals(ts,ja.Date)
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

Method TestListToArray()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim list as %ListOfObjects
    #Dim array as %DynamicArray
    
    s sc = $$$OK
    try {
       s obj = ##class(JSONAdaptor).%New()
       s obj.Bar = 1
       s obj.Foo = "the quick brown fox jumped over the lazy dog"
       s obj.Int = 42 
       s list = ##class(%ListOfObjects).%New()
       $$$TOE(sc,list.Insert(obj))
       $$$TOE(sc,##class(ks.lib.json.Utils).ListToArray(list,.array))
       d $$$AssertTrue($isobject(array))
       d $$$AssertTrue(array.%Extends("%Library.DynamicArray"))
       d $$$AssertEquals(array.%Size(),1)       
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

Method TestJSONFromXData()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim do as %DynamicAbstractObject
    
    s sc = $$$OK
    try {

        $$$TOE(sc,##class(ks.lib.json.Utils).JSONFromXData($classname(),"TestData",.do))
        d $$$AssertTrue($isobject(do))
        d $$$AssertTrue(do.%Extends("%DynamicObject"))
        d $$$AssertEquals(do.test,"hello, world")        
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

Method TestJSONFromFile()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim do as %DynamicAbstractObject
    
    s sc = $$$OK
    try {

        s do = ##class(ks.lib.json.Utils).JSONFromFile(..ResourceFile("json/test.json"))
        d $$$AssertTrue($isobject(do))
        d $$$AssertTrue(do.%Extends("%DynamicObject"))
        d $$$AssertEquals(do.test,"hello, world")        
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

XData TestData [ MimeType = application/json ]
{
{
        "test":"hello, world"
    }
}

}
