/// list of data types exposing %GetSerial and %SetSerial
Class ks.lib.collections.ListOfDataTypes Extends %Library.ListOfDataTypes
{

/// serialize object
Method %GetSerial(force As %Integer = 0) As %String
{
    return ##super(force)
}

/// deserialize object
Method %SetSerial(serialized As %String) As %Status
{
    return ##super(.serialized)
}

Storage Custom
{
<Type>%Library.CompleteCustomStorage</Type>
}

}
