Class ks.lib.archive.bo.AbstractOperation Extends Ens.BusinessOperation [ Abstract ]
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

Parameter SETTINGS = "-FilePath,RootDirectory,FileSpec,CreateDirectories,FileNameExpressions,FileNameSeparator,SubFolderExpressions,SubFolderSeparator";

Property RootDirectory As %String(MAXLEN = 2048);

Property FileSpec As %String(MAXLEN = 128) [ InitialExpression = "%Y%m%d%H%M%S%N%!#+(.000)-%f.dat" ];

Property CreateDirectories As %Boolean [ InitialExpression = 1 ];

Property FileNameExpressions As %String(MAXLEN = 32) [ InitialExpression = "BodyId" ];

Property FileNameSeparator As %String(MAXLEN = 4) [ InitialExpression = "-" ];

Property SubFolderExpressions As %String(MAXLEN = 1024) [ InitialExpression = "SessionHeader.SourceConfigName\CurrentDateTime(""%Y"")\CurrentDateTime(""%m"")\CurrentDateTime(""%d"")" ];

Property SubFolderSeparator As %String(MAXLEN = 1) [ InitialExpression = "\" ];

Property Adapter As EnsLib.File.OutboundAdapter;

Property Header As Ens.MessageHeader [ Transient ];

Property SessionHeader As Ens.MessageHeader [ Transient ];

Property Body As %RegisteredObject [ Transient ];

Property BodyId As %String [ Transient ];

Method OnInit() As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException
  
  try {
    if '##class(%File).DirectoryExists(..RootDirectory) && ..CreateDirectories {
      d ##class(%File).CreateDirectoryChain(..RootDirectory)
    }
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method OnMessage(request As %Library.Persistent, Output response As %Library.Persistent) As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException

    #Dim fileName As %String
    #Dim directory,subfolder As %String
    #Dim tag As %String
    #Dim messageStream As %Stream.Object
    
    try {
      $$$TRACE("exporting message to stream")

      $$$TOE(sc,..InitializeRequestProperties(request))

      $$$TRACE("root directory :"_..RootDirectory)           
      s directory = ..EvaluateSubFolderExpressions(request,.sc)
      $$$TOE(sc,sc)
      if ..CreateDirectories && '##class(%File).DirectoryExists(directory) d ##class(%File).CreateDirectoryChain(directory)
      $$$TRACE("target directory : "_directory)

      $$$TOE(sc,..MessageStream(..%RequestHeader,request,.messageStream,.tags))
      if $isobject(messageStream) {     
        s tag =  ..EvaluateFileNameExpressions(request,.sc)
        $$$TOE(sc,sc)
        s ..Adapter.FilePath = directory
        s fileName = ..Adapter.CreateFilename(tag,..FileSpec,0)
        $$$TRACE("archiving message to file")
        $$$TOE(sc,..Adapter.PutStream(fileName,messageStream))
      } else {        
        throw ##class(%Exception.General).%New("could not export message")
      }
    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

Method InitializeRequestProperties(request As %Persistent) As %Status [ Private ]
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException
  
  try {
    if $isobject(..%RequestHeader) {
      s ..Header = ..%RequestHeader
      s ..SessionHeader = ##class(Ens.MessageHeader).%OpenId(..%RequestHeader.SessionId)
    } else {
      s ..SessionHeader = $$$NULLOREF
      s ..Header = $$$NULLOREF
    }    
    s ..Body = request
    s ..BodyId = $translate(request.%Id(),"\|:","")
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method EvaluateFileNameExpressions(request As %Persistent, Output sc As %Status) As %String [ Private ]
{
  #Dim ex as %Exception.AbstractException
  #Dim result as %String

  #Dim expressions,values as %List
  #Dim ptr as %Integer
  #Dim expr,value,err as %String
  
  s sc = $$$OK
  s result = ..Adapter.FilePath
  try {
      s expressions = $listfromstring(..FileNameExpressions,..FileNameSeparator)
      s ptr = 0      
      s values = ""
      while $listnext(expressions,ptr,expr) {
        s value = ##class(Ens.Rule.ExpressionParser).Evaluate(expr,$this,.err)
        if err="" {
          s $list(values,*+1) = value
        } else {
          throw ##class(%Exception.General).%New("error evaluating expr "_expr_" : "_err)
        }
      } 
      s result = $listtostring(values,..FileNameSeparator)     
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

Method EvaluateSubFolderExpressions(request As %Persistent, Output sc As %Status) As %String [ Private ]
{
  #Dim ex as %Exception.AbstractException
  #Dim result as %String

  #Dim expressions as %List
  #Dim ptr as %Integer
  #Dim expr,value,err as %String
  
  s sc = $$$OK
  s result = ..RootDirectory
  try {
      s expressions = $listfromstring(..SubFolderExpressions,..SubFolderSeparator)
      s ptr = 0      
      while $listnext(expressions,ptr,expr) {
        s value = ##class(Ens.Rule.ExpressionParser).Evaluate(expr,$this,.err)
        if err="" {
          s result = ##class(%File).SubDirectoryName(result,value,1)
        } else {
          throw ##class(%Exception.General).%New("error evaluating expr "_expr_" : "_err)
        }
      }      
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

Method MessageStream(header As Ens.MessageHeader, message As %Persistent, Output messageStream As %Stream.Object, ByRef messageTag As %String) As %Status [ Abstract ]
{
}

}
