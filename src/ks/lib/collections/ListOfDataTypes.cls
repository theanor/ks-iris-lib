Class ks.lib.collections.ListOfDataTypes Extends %Library.ListOfDataTypes
{

Method %GetSerial(force As %Integer = 0) As %String
{
    return ##super(force)
}

Method %SetSerial(serialized As %String) As %Status
{
    return ##super(.serialized)
}

Storage Custom
{
<Type>%Library.CompleteCustomStorage</Type>
}

}
