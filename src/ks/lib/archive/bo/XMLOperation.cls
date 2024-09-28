/// archive operation for messages extending <class>%XML.Adaptor</class>
Class ks.lib.archive.bo.XMLOperation Extends AbstractOperation
{

Parameter SETTINGS = "RootElement,ParameterFormat";

Property FileSpec As %String(MAXLEN = 128) [ InitialExpression = "%Y%m%d%H%M%S%N%!#+(.000)-%f.xml" ];

/// Optional root element 
Property RootElement As %String(MAXLEN = 32);

/// export xml parameters format
Property ParameterFormat As %String(VALUELIST = ",literal,encoded,encoded12") [ InitialExpression = "literal" ];

/// extract XML message stream
Method MessageStream(header As Ens.MessageHeader, message As %Persistent, Output messageStream As %Stream.Object) As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException

    try {
        if 'message.%Extends("%XML.Adaptor") throw ##class(%Exception.General).%New("only classes extending %XML.Adaptor are supported")
        s messageStream = ##class(%Stream.TmpCharacter).%New()
        $$$TOE(sc,message.XMLExportToStream(.messageStream,..RootElement,..ParameterFormat))        
    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

}
