Class ks.lib.test.Runner Extends %RegisteredObject
{

ClassMethod DebugTestCase(className As %Dictionary.Classname, testMethod As %String = "", ByRef userParams) As %Status
{
    return $classmethod(className,"Debug",testMethod,.userParams)
}

ClassMethod RuntimeDirectory() As %String [ CodeMode = expression ]
{
##class(%File).SubDirectoryName(^UnitTestRoot, "runtime")
}

ClassMethod TestResourceDirectory() As %String [ CodeMode = expression ]
{
$get(^UnitTestResourcesRoot,##class(%File).SubDirectoryName(^UnitTestRoot, "resource"))
}

}
