Class ks.lib.xml.Utils
{

ClassMethod ExportSchema(className As %String, fileName As %String, namespace As %String = "http://temuri.org/ISC/Sample", namespacePrefix As %String = "tns") As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException

    #Dim schema as %XML.Schema
    #Dim writer as %XML.Writer
    
    try {
      s schema=##class(%XML.Schema).%New()
      s schema.DefaultNamespace=namespace

      s writer = ##class(%XML.Writer).%New()
      $$$TOE(sc,writer.OutputToFile(fileName))            
      s writer.Indent=1
      d writer.AddSchemaNamespace()
      d writer.AddNamespace(namespace,namespacePrefix)

      $$$TOE(sc,schema.AddSchemaType(className))
    
      $$$TOE(sc,writer.DocumentNode(schema.GetSchema(namespace)))      
      
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    q sc
}

ClassMethod ImportClassFromFile(className As %String, fileName As %String, namespace As %String = "", Output sc As %Status) As %XML.Adaptor
{
  #Dim ex as %Exception.AbstractException
  #Dim result as %XML.Adaptor
  #Dim stream as %Stream.Object
  
  s sc = $$$OK
  try {
    s result = $$$NULLOREF
    s stream = ##class(%Stream.FileCharacter).%New()
    s stream.Filename = fileName
    s result = ..ImportClassFromStream(className,stream,namespace,.sc)
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }  
  q result
}

ClassMethod ImportClassFromStream(className As %String, stream As %Stream.Object, namespace As %String = "", Output sc As %Status) As %XML.Adaptor
{
  #Dim ex as %Exception.AbstractException
  #Dim reader as %XML.Reader
  #Dim result as %XML.Adaptor
  
  s sc = $$$OK
  try {
    s result = $$$NULLOREF
    s reader = ##class(%XML.Reader).%New()
    d reader.CorrelateRoot(className)
    $$$TOE(sc,reader.OpenStream(stream))
    s found = reader.Next(.result,.sc,namespace)
    $$$TOE(sc,sc)  
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }  
  q result
}

ClassMethod ClassElementName(className As %Dictionary.Classname, Output sc As %Status) As %String
{
  #Dim ex as %Exception.AbstractException
  #Dim result as %String

  s sc = $$$OK
  s result = ""
  try {
    s result = $parameter(className,"XMLNAME")
    s:result="" result = $piece(className,".",*)
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

ClassMethod ImportClassesFromXData(xdataClassName As %Dictionary.Classname, xdataName As %String, baseClassName As %Dictionary.Classname = "", namespace As %String = "", Output sc As %Status) As %XML.Adaptor
{
  
  #Dim ex as %Exception.AbstractException
  #Dim result as %XML.Adaptor

  #Dim xdata as %Dictionary.CompiledXData
  #Dim data as %Stream.Object
  
  s sc = $$$OK
  try {
	  s xdata=##class(%Dictionary.CompiledXData).%OpenId(xdataClassName_"||"_xdataName)
	  if $isobject(xdata) {
		  s data = xdata.Data		  
	  } 	
    s:(baseClassName="") baseClassName = xdataClassName
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return:$$$ISOK(sc) ..ImportClassesFromStream(baseClassName,data,namespace,.sc)
}

ClassMethod ImportClassFromXData(xdataClassName As %Dictionary.Classname, xdataName As %String, baseClassName As %Dictionary.Classname = "", namespace As %String = "", Output sc As %Status) As %XML.Adaptor
{
  
  #Dim ex as %Exception.AbstractException

  #Dim xdata as %Dictionary.CompiledXData
  #Dim data as %Stream.Object
  
  s sc = $$$OK
  try {
	  s xdata=##class(%Dictionary.CompiledXData).%OpenId(xdataClassName_"||"_xdataName)
	  if $isobject(xdata) {
		  s data = xdata.Data		  
	  } 	
    s:(baseClassName="") baseClassName = xdataClassName
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return:$$$ISOK(sc) ..ImportClassFromStream(baseClassName,data,namespace,.sc)
}

ClassMethod ImportClassesFromStream(baseClassName As %String, stream As %Stream.Object, namespace As %String = "", Output sc As %Status) As %XML.Adaptor
{
  #Dim ex as %Exception.AbstractException

  #Dim reader as %XML.Reader
  #Dim result as %XML.Adaptor
  
  #Dim stmt as %SQL.Statement
  #Dim rs as %SQL.StatementResult
  
  try {
    s result = $$$NULLOREF
    s reader = ##class(%XML.Reader).%New()

    if '##class(ks.lib.object.Utils).IsAbstract(baseClassName) {
      s element = ..ClassElementName(baseClassName)
      d reader.Correlate(element,baseClassName,namespace)
    }
    s stmt = ##class(%SQL.Statement).%New()
    $$$TOE(sc,stmt.PrepareClassQuery("%Dictionary.ClassDefinition","SubclassOf"))
    s rs = stmt.%Execute(baseClassName)    
    while (rs.%Next(.sc)) {
      $$$TOE(sc,sc)
      s className = rs.%Get("Name")
      if '##class(ks.lib.object.Utils).IsAbstract(className) {
        s element = ..ClassElementName(className)
        d reader.Correlate(element,className,namespace)
      }
    }    
    $$$TOE(sc,reader.OpenStream(stream))
    s found = reader.Next(.result,.sc,namespace)
    $$$TOE(sc,sc)  
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }  
  q result
}

/// Import object instance of class extending <b>baseClassName</b> from <b>fileName</b> from XML 
ClassMethod ImportClassesFromFile(baseClassName As %String, fileName As %String, namespace As %String = "", Output sc As %Status) As %XML.Adaptor
{
  #Dim ex as %Exception.AbstractException
  #Dim stream as %Stream.FileCharacter

  #Dim result as %XML.Adaptor

  s result = $$$NULLOREF  
  s sc = $$$OK
  try {
    s stream = ##class(%Stream.FileCharacter).%New()
    s stream.Filename = fileName
    s result = ..ImportClassesFromStream(baseClassName,stream,namespace,.sc)
    $$$TOE(sc,sc)
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

ClassMethod ExportToFile(xml As %XML.Adaptor, fileName As %String, charset As %String = "UTF-8", indent As %Boolean = 1) As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException
  #Dim stream as %Stream.FileCharacter
  
  try {
    if '$d(fileName) {
      s fileName = ##class(%File).TempFilename(".xml")
    }
    s stream = ##class(%Stream.FileCharacter).%New()
    s stream.Filename = fileName
    $$$TOE(sc,..ExportToStream(xml,.stream,charset,indent))
    $$$TOE(sc,stream.%Save())        
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  q sc
}

ClassMethod ExportToStream(xml As %XML.Adaptor, ByRef stream As %Stream.Object, charset As %String = "UTF-8", indent As %Boolean = 1) As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException
  #Dim writer as %XML.Writer
  
  try {
    if '$d(stream) {
      s stream = ##class(%Stream.TmpCharacter).%New()
    }
    s writer = ##class(%XML.Writer).%New()
    s writer.Indent = indent
    s writer.Charset = charset
    $$$TOE(sc,writer.OutputToStream(.stream))
    $$$TOE(sc,writer.RootObject(xml))
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  q sc
}

}
