Class ut.ks.lib.archive.TestMessage Extends Ens.MessageBody
{

Property FooString As %String [ InitialExpression = "hello,world" ];

Property BarBool As %Boolean [ InitialExpression = 1 ];

Property FooBarInt As %Integer [ InitialExpression = 42 ];

Storage Default
{
<Data name="TestMessageDefaultData">
<Subscript>"TestMessage"</Subscript>
<Value name="1">
<Value>FooString</Value>
</Value>
<Value name="2">
<Value>BarBool</Value>
</Value>
<Value name="3">
<Value>FooBarInt</Value>
</Value>
</Data>
<DefaultData>TestMessageDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
