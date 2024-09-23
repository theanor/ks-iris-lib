/// stack of data types
Class ks.lib.collections.StackOfDataTypes Extends %SerialObject
{

/// The type (class name) of the elements stored in the collection.
Parameter ELEMENTTYPE = "%String";

/// The type (classname:propertyname) of the elements stored in the collection.
Property ElementType As %Dictionary.Classname [ InitialExpression = {..#ELEMENTTYPE} ];

Property Stack As %String [ MultiDimensional, Private ];

/// Clears the contents of the stack.
Method Clear() As %Status
{
	Kill i%Stack    
	Quit $$$OK
}

/// Push new value on the stack
Method Push(value As %String) As %Status
{
    s ..Stack($increment(i%Stack)) = value
    return $$$OK
}

/// Pop value from the stack
Method Pop(emptyValue As %String = "") As %String
{
    return:('$data(i%Stack)) emptyValue
    s value = $get(..Stack(i%Stack),emptyValue)
    s i%Stack = i%Stack-1
    return value
}

Method %GetSerial(force As %Integer = 0) As %String
{
	Set list="",key="" For  Set key=$order(i%Stack(key)) Quit:key=""  Set list=list_$listbuild(i%Stack(key))
	Quit list
}

Method %SetSerial(serialized As %String) As %Status
{
    d ..Clear()
	Set i%ElementType=""
	Set ptr=0
    While $listnext(serialized,ptr,item) {
        d ..Push(item)
    }
	Quit $$$OK
}

Storage Default
{
<Data name="StackOfDataTypesState">
<Value name="1">
<Value>ElementType</Value>
</Value>
</Data>
<State>StackOfDataTypesState</State>
<StreamLocation>^StPierre.Lib.StackOfDataTypesS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}