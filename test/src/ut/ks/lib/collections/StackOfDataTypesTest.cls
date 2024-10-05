Class ut.ks.lib.collections.StackOfDataTypesTest Extends ks.lib.test.TestCase
{

Method TestStack()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim stack as ks.lib.collections.StackOfDataTypes
    
    s sc = $$$OK
    try {
        s stack = ##class(ks.lib.collections.StackOfDataTypes).%New()
        $$$TOE(sc,stack.Push("foo"))
        $$$TOE(sc,stack.Push("bar"))
        d $$$AssertEquals(stack.Pop(),"bar")
        d $$$AssertEquals(stack.Pop(),"foo")
        d $$$AssertEquals(stack.Pop("empty"),"empty")
        d $$$AssertEquals(stack.Pop(),"")        
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

}
