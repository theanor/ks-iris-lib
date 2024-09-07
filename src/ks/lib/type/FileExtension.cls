Class ks.lib.type.FileExtension Extends %String
{

ClassMethod FromFileName(fileName As %String) As FileExtension
{
	q $piece(fileName, ".", *)
}

ClassMethod Normalize(%val As %RawString) As FileExtension
{
    return ##super($zconvert($replace(%val,".",""),"L"))
}

}
