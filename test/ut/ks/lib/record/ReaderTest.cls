Class ut.ks.lib.record.ReaderTest Extends %UnitTest.TestCase
{

Method TestReader()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim reader as ks.lib.record.Reader
    #Dim stream as %Stream.TmpCharacter

    
    s sc = $$$OK
    try {       
        s reader = ##class(ks.lib.record.Reader).%New()
        $$$TOE(sc,reader.CorrelateDefault(##class(DelimitedRecord).%ClassName(1)))
        s stream = ##class(%Stream.TmpCharacter).%New()
        d stream.WriteLine("""aaa"",""bbb"",""ccccc""")
        d stream.WriteLine("""d"",""eeeeeee"",""fff""")
        $$$TOE(sc,stream.Rewind())
        $$$TOE(sc,reader.OpenStream(stream))
        s recCount = 0
        for {
            s record = reader.Next(.sc)
            $$$TOE(sc,sc)
            quit:'$isobject(record)
            $$$TOE(sc,record.ExportToString(.str))            
            d $$$LogMessage("read record : "_str)
            s recCount = recCount + 1
        }
        d $$$AssertEquals(recCount,2)
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

}
