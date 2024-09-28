/// HL7 message utilities
Class ks.lib.hl7.Utils
{

/// export <b>message</b> to <b>stream</b> as XML (see <class>EnsLib.HL7.Util.FormatSimpleXMLv2</class>)
ClassMethod ExportToXML(message As EnsLib.HL7.Message, Output stream As %Stream.Object) As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException
  
  try {
    if '$d(stream) s stream = ##class(%Stream.TmpCharacter).%New()
    d ##class(EnsLib.HL7.Util.FormatSimpleXMLv2).OutputDocument(message,.sc,stream,message.Separators)
    $$$TOE(sc,sc)
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

/// return message imported from XData block <b>xdataName</b> in class <b>classRef</b>, resolving document type (see <method>ks.lib.hl7.Utils.ResolveDocType</method>) using <b>docTypeCategory</b>
ClassMethod ImportFromXData(classRef As %Dictionary.Classname, xdataName As %String, docTypeCategory As %String, Output sc As %Status) As EnsLib.HL7.Message
{
	#Dim ex as %Exception.AbstractException
	#Dim msg as EnsLib.HL7.Message
	#Dim xdata as %Dictionary.CompiledXData
	
	s sc = $$$OK
	s msg = $$$NULLOREF
	try {
	  s className = $select($isobject(classRef):classRef.%ClassName(1),1:classRef)
	  s xdata = ##class(%Dictionary.CompiledXData).IDKEYOpen(className,xdataName,,.sc)
	  $$$TOE(sc,sc)
	  if '$isobject(xdata) throw ##class(%Exception.General).%New("xdata not found : "_xdataName_" in compiled class "_className)
	  s msg = ##class(EnsLib.HL7.Message).ImportFromLibraryStream(xdata.Data,.sc)
	  $$$TOE(sc,sc)
	  if $isobject(msg) && $data(docTypeCategory) d ##class(ks.lib.hl7.Utils).ResolveDocType(msg,docTypeCategory)
	} catch (ex) {
	  s sc = ex.AsStatus()
	}
	return msg
}

/// Resolve the DocType property of message using the supplied <b>docTypeCategory</b> and the value of MSH:9
ClassMethod ResolveDocType(message As EnsLib.HL7.Message, docTypeCategory As %String) As %Status
{
  s message.DocType=$select(message.DocType="":##class(EnsLib.HL7.Schema).ResolveSchemaTypeToDocType(docTypeCategory,message.Name),1:message.DocType)
  return $$$OK
}

/// returns true if none of <b>segment</b> fields have value
ClassMethod IsEmptySegment(segment As EnsLib.HL7.Segment) As %Boolean
{
 s str = segment.OutputToString() 
 s name = segment.Name
 s fs = segment.FS
 s str = $replace(str,name,"")
 s str = $replace(str,fs,"")
 s str = $zstrip(str,"*C")
 return $length(str) = 0
}

/// Parse <b>str</b>, replacing expressions as ${<property path>} by values from <b>msg</b>
ClassMethod ParseExpressions(msg As EnsLib.HL7.Message, str As %String, Output sc As %Status) As %String
{
  #Dim ex as %Exception.AbstractException
  #Dim matcher as %Regex.Matcher = ##class(%Regex.Matcher).%New("^.*\$(\{[A-Z,a-z,0-9,:\.]*\}).*$")
  
  s sc = $$$OK
  s result = str
  try {
    while matcher.Match(result) {
      s expr = matcher.Group(1)
      s exprValue = ""
      s code = ##class(Ens.VDoc.Utils).GetGetCode("msg."_expr,"objectscript")
      xecute ("(msg,out) set out="_code,msg,.exprValue)
      s result = $replace(result,"$"_expr,exprValue)
      d matcher.ResetPosition(1)
    }
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

}
