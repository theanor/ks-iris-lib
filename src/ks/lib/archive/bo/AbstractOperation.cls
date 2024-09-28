/// <p>This abstract archive operation provides basic behavior for archiving incoming messages to file into a root directory, optionnally creating subfolder(s).
/// The incoming message is serialized during execution on <method>OnMessage</method>, by calling <method>MessageStream</method> that must be implemented by the concrete operation extending this class.</p>
/// 
/// <p>Serialized messages are saved to files under the directory specified by <property>RootDirectory</property>.</p>
/// 
/// <p>The archived file name is build using <property>FileNameExpressions</property>, a list of expressions separated by <property>FileNameSeparator</property> that are parsed using <class>Ens.Rule.ExpressionParser</class> and the operation instance as context.</p>
/// 
/// <p>The actual subdirectory where the file is archived is build using <property>SubFolderExpressions</property>, a list of expression separated by <property>SubFolderSeparator</property> that are parsed using <class>Ens.Rule.ExpressionParser</class> and the operation instance as context.
/// The following properties are available during expression parsing :</p>
/// <ul>
///   <li><property>Header</property> : incoming message header instance of <class>Ens.MessageHeader</class></li>
///   <li><property>SessionHeader</property> : incoming message session header instance of <class>Ens.MessageHeader</class></li>
///   <li><property>Body</property> : incoming message body
///   <li><property>BodyId</property> : incoming message body identifier
/// <ul>
Class ks.lib.archive.bo.AbstractOperation Extends Ens.BusinessOperation [ Abstract ]
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

Parameter SETTINGS = "-FilePath,RootDirectory,FileSpec,CreateDirectories,FileNameExpressions,FileNameSeparator,SubFolderExpressions,SubFolderSeparator";

/// root directory path
Property RootDirectory As %String(MAXLEN = 2048);

/// file spec
Property FileSpec As %String(MAXLEN = 128) [ InitialExpression = "%Y%m%d%H%M%S%N%!#+(.000)-%f.dat" ];

/// if true, will created required new directories
Property CreateDirectories As %Boolean [ InitialExpression = 1 ];

/// list of objectscript expressions, separated by <property>FileNameSeparator</property>
Property FileNameExpressions As %String(MAXLEN = 32) [ InitialExpression = "BodyId" ];

/// file name separator
Property FileNameSeparator As %String(MAXLEN = 4) [ InitialExpression = "-" ];

/// list of subfolder expressions, separated by <property>SubFolderSeparator</property>
Property SubFolderExpressions As %String(MAXLEN = 1024) [ InitialExpression = "SessionHeader.SourceConfigName\CurrentDateTime(""%Y"")\CurrentDateTime(""%m"")\CurrentDateTime(""%d"")" ];

/// subfolder separator
Property SubFolderSeparator As %String(MAXLEN = 1) [ InitialExpression = "\" ];

/// file adapter
Property Adapter As EnsLib.File.OutboundAdapter;

/// transient property available during file name and subfolder evaluation
/// contains the incoming header
Property Header As Ens.MessageHeader [ Transient ];

/// transient property available during file name and subfolder evaluation
/// contains the incoming message session header
Property SessionHeader As Ens.MessageHeader [ Transient ];

/// transient property available during file name and subfolder evaluation
/// contains message body
Property Body As %RegisteredObject [ Transient ];

/// transient property available during file name and subfolder evaluation
/// contains message body id
Property BodyId As %String [ Transient ];

/// initialize
Method OnInit() As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
  
  s sc = $$$OK
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

/// process incoming message
Method OnMessage(request As %Library.Persistent, Output response As %Library.Persistent) As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException

    #Dim fileName As %String
    #Dim directory As %String
    #Dim tag As %String
    #Dim messageStream As %Stream.Object
    
    try {
      $$$TRACE("exporting message to stream")
      $$$TOE(sc,..MessageStream(..%RequestHeader,request,.messageStream))
      if $isobject(messageStream) {
        $$$TOE(sc,..InitializeRequestProperties(request))

        $$$TRACE("root directory :"_..RootDirectory)           
        s directory = ..EvaluateSubFolderExpressions(request,.sc)
        $$$TOE(sc,sc)

        if ..CreateDirectories && '##class(%File).DirectoryExists(directory) d ##class(%File).CreateDirectoryChain(directory)
        $$$TRACE("target directory : "_directory)

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
      } else {
        $$$TRACE("message not archived, MessageStream did not return any data")
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

/// override this to provide message to be archived in <b>messageStream</b>
Method MessageStream(header As Ens.MessageHeader, message As %Persistent, Output messageStream As %Stream.Object) As %Status [ Abstract ]
{
}

}
