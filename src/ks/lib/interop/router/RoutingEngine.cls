/// routing engine 
Class ks.lib.interop.router.RoutingEngine Extends EnsLib.MsgRouter.RoutingEngine
{

Parameter SETTINGS = "ContextRequestTarget:Context,ContextRequestTimeout:Context,ContextRequestTransform:Context:dtlSelector,ContextResponseTransform:Context:dtlSelector,ActOnContextError:Context";

/// Context request target
Property ContextRequestTarget As Ens.DataType.ConfigName;

/// Context request timeout
Property ContextRequestTimeout As %Integer [ InitialExpression = 30 ];

/// Context request data transform. If not empty, used by default implementation of <method>BuildContextRequest</method> to build context request, passing primary request as source object.
Property ContextRequestTransform As %Dictionary.Classname;

/// Context response data transform. If not empty, it is used by default implementation of <method>BuildContextRequest</method> to build context request, passing primary request as source object.
Property ContextResponseTransform As %Dictionary.Classname;

/// Set this to true to act on error during context processing
Property ActOnContextError As %Boolean [ InitialExpression = 0 ];

/// Property available during rule evaluation
Property Context As %RegisteredObject [ Transient ];

Method OnRequest(request As %Persistent, Output response As %Persistent) As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  s sc = $$$OK
  if ..ContextRequestTarget '= "" {
    try {
      $$$TOE(sc,..GetContext(request,.response))
    } catch (ex) {
      s sc = ex.AsStatus()
    }
  }    
  return $select($$$ISERR(sc) && ..ActOnContextError:sc,1:##super(request,.response))
}

Method GetContext(request As %Persistent, Output response) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim contextRequest as Ens.Request
    #Dim contextResponse as Ens.Response
    
    s sc = $$$OK
    try {
      $$$TRACE("in get context")
      $$$TOE(sc,..BuildContextRequest(request,.response,.contextRequest))
      $$$TOE(sc,sc)
      $$$TRACE("sending request")
      $$$TOE(sc,..SendRequestSync(..ContextRequestTarget,contextRequest,.contextResponse))
      if '$isobject(contextResponse) throw ##class(%Exception.General).%New("context request timed out")
      $$$TRACE("processing response")
      $$$TOE(sc,..OnContextResponse(request,.response,contextRequest,contextResponse))
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

Method BuildContextRequest(request As %Persistent, ByRef response As %Persistent, Output contextRequest As %Persistent) As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
  
  s sc = $$$OK
  try {
    if (..ContextRequestTransform'="") && $classmethod(..ContextRequestTransform,"%Extends","Ens.DataTransform") {
      $$$TOE(sc,$classmethod(..ContextRequestTransform,"Transform",request,.contextRequest,$this))
    }      
    else {
      s contextRequest = request.%ConstructClone(1)
    }
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method OnContextResponse(request As %Persistent, ByRef response As %Persistent, contextRequest As %Persistent, contextResponse As %Persistent) As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim context as %RegisteredObject
  
  s sc = $$$OK
  try {
    if (..ContextResponseTransform'="") && $classmethod(..ContextResponseTransform,"%Extends","Ens.DataTransform") {
      $$$TOE(sc,$classmethod(..ContextResponseTransform,"Transform",contextResponse,.context))
    } else {
      s context = contextResponse.%ConstructClone(1)      
    }    
    s ..Context = context
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method MergeSettingDescriptions() As %Status [ CodeMode = generator, GenerateAfter = SettingsMessages ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
  
  s sc = $$$OK
  try {
    $$$TOE(sc,##class(ks.lib.interop.ConfigUtils).MergeEnsColumns())
    $$$TOE(sc,##class(ks.lib.interop.ConfigUtils).SetSettingsMessages(%class))
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

XData SettingsMessages [ MimeType = application/json ]
{
{
    "ContextRequestTarget" : {
       "en-us" : "Context request target"
    },
    "ContextRequestTimeout" : {
       "en-us" : "Context request timeout"
    },
    "ActOnContextError" : {
       "en-us" : "Act on context error"
    },
    "ContextRequestTransform" : {
       "en-us" : "Context request data transform"
    },
    "ContextResponseTransform" : {
       "en-us" : "Context request data transform"
    }
   }
}

Storage Default
{
<Data name="RoutingEngineDefaultData1">
<Subscript>"RoutingEngine1"</Subscript>
<Value name="1">
<Value>ContextRequestTarget</Value>
</Value>
<Value name="2">
<Value>ContextRequestTimeout</Value>
</Value>
<Value name="3">
<Value>ContextRequestTransform</Value>
</Value>
<Value name="4">
<Value>ContextResponseTransform</Value>
</Value>
<Value name="5">
<Value>ActOnContextError</Value>
</Value>
</Data>
<DefaultData>RoutingEngineDefaultData1</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
