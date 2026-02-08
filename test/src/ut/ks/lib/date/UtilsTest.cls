Class ut.ks.lib.data.UtilsTests Extends ks.lib.test.TestCase
{

Parameter WORKINGHOURSSPEC = "STOP:WEEK-*-01T17:00:00,START:WEEK-*-01T08:00:00,STOP:WEEK-*-02T17:00:00,START:WEEK-*-02T08:00:00,STOP:WEEK-*-03T17:00:00,START:WEEK-*-03T08:00:00,STOP:WEEK-*-04T17:00:00,START:WEEK-*-04T08:00:00,STOP:WEEK-*-05T17:00:00,START:WEEK-*-05T08:00:00";

Method TestEasterDate()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    
    s sc = $$$OK
    try {
        s easter2025 = ##class(ks.lib.date.Utils).EasterDate("2025","%Y-%m-%d")
        d $$$AssertEquals(easter2025,"2025-04-20")
        s easter2026 = ##class(ks.lib.date.Utils).EasterDate("2026","%Y-%m-%d")
        d $$$AssertEquals(easter2026,"2026-04-05")
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

Method TestWorkingHours()
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    
    s sc = $$$OK
    try {
        s d = "2026-01-09 10:00:00.000"
        d $$$AssertTrue(##class(ks.lib.date.Utils).IsWorkingHours(d,"be",..#WORKINGHOURSSPEC))
        s d = "2026-01-10 08:00:00.000"
        d $$$AssertTrue('##class(ks.lib.date.Utils).IsWorkingHours(d,"be",..#WORKINGHOURSSPEC))
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    d $$$AssertStatusOK(sc)
}

}
