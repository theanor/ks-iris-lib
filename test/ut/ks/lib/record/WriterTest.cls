Class ut.ks.lib.record.WriterTest Extends %UnitTest.TestCase
{

Method TestWriter()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim writer as ks.lib.record.Writer
    #Dim stream as %Stream.TmpCharacter
    
    s sc = $$$OK
    try {
        s writer = ##class(ks.lib.record.Writer).%New()
        s stream = ##class(%Stream.TmpCharacter).%New()
        $$$TOE(sc,writer.OutputToStream(stream))
        s record = ##class(DelimitedRecord).%New()
        s record.Foo = "foo"
        s record.Bar = "bar" 
        $$$TOE(sc,writer.Write(record))
        $$$TOE(sc,writer.Stream.Rewind())
        s str = writer.Stream.ReadLine()
        s record = ##class(DelimitedRecord).%New()
        $$$TOE(sc,record.ImportFromString(str))
        d $$$AssertEquals(record.Foo,"foo")
        d $$$AssertEquals(record.Bar,"bar")
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

}
