Class ks.lib.test.TestProduction Extends (TestCase, %UnitTest.TestProduction) [ Abstract ]
{

Parameter PRODUCTION = "dummy";

Method %OnNew(initvalue) As %Status [ Internal ]
{
	set s = ##super(initvalue) if 's quit s
	set i%MainDir = ##class(%File).SubDirectoryName(^UnitTestRoot, "runtime")
	set i%HL7InputDir = ..SubMainDir("HL7/In")
	set i%HL7OutputDir = ..SubMainDir("HL7/Out")
	set i%HL7WorkDir = ..SubMainDir("HL7/Work")
	set i%HL7ArchiveDir = ..SubMainDir("HL7/Archive")
	set i%MachineName = $piece($system,":",1)
	set i%InstanceName = $piece($system,":",2)
	set i%DSNToSamples = $select($$$isUNIX:"Samples",$$$isWINDOWS:i%InstanceName_" Samples",1:"")
	set i%DSNToUser = $select($$$isUNIX:"User",$$$isWINDOWS:i%InstanceName_" User",1:"")
	quit $$$OK
}

}
