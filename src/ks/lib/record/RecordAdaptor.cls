Class ks.lib.record.RecordAdaptor Extends %RegisteredObject [ DependsOn = Generators, PropertyClass = PropertyParameters ]
{

/// record adaptor type : "delimited", "fixed" or "recordset"
Parameter TYPE = "delimited";

/// separator (delimiter) used for delimited records
Parameter SEPARATOR;

/// char used as filler (default padding character) for fixed length records
Parameter FILLER = " ";

/// delimiter for strings containing separator in delimited record
Parameter ESCAPECHAR = """";

/// "all" for all values or "sep" for values containing separator in delimited records
Parameter ESCAPING;

Method ExportToStringDelimited(Output line As %String) As %Status [ CodeMode = objectgenerator, Private ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim props as %Dictionary.CompiledProperty
  #Dim prop as %Dictionary.CompiledProperty
  #Dim curIndex,index as %Integer
  
  s sc = $$$OK
  try {

    s type = ""
    s typeParam = ##class(%Dictionary.CompiledParameter).IDKEYOpen(%compiledclass.Name,"TYPE")
    s:$isobject(typeParam) type = typeParam.Default
    return:(type'="delimited") $$$OK

    $$$TOE(sc,##class(Generators).FetchProps(%compiledclass,.props))

    s curIndex = 1
    s index = ""
    s index = $order(props(index))
    $$$TOE(sc,%code.WriteLine("    s line="""""))

    while index '= "" {
      while index > curIndex {
          $$$TOE(sc,%code.WriteLine("    s line=line_..#SEPARATOR"))
          s curIndex = curIndex + 1
      }
      s prop = props(index)
      if $classmethod(prop.Type,"%Extends","%Library.DataType") { // property is datatype
        $$$TOE(sc,##class(Generators).GenerateDataTypeExportToDelimited(%compiledclass,prop,%code,"line"))
      } else { // property is something unsupported
        throw ##class(%Exception.General).%New("property "_prop.Name_" has unsupported type "_prop.Type)
      }
      s index = $order(props(index))
    }      
    $$$TOE(sc,%code.WriteLine("    return $$$OK"))
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method ExportToStringFixed(Output line As %String) As %Status [ CodeMode = objectgenerator, Private ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim props as %Dictionary.CompiledProperty
  #Dim prop as %Dictionary.CompiledProperty
  #Dim index as %Integer


    s type = ""
    s typeParam = ##class(%Dictionary.CompiledParameter).IDKEYOpen(%compiledclass.Name,"TYPE")
    s:$isobject(typeParam) type = typeParam.Default
    return:(type'="fixed") $$$OK

  s sc = $$$OK
  try {
    $$$TOE(sc,##class(Generators).FetchProps(%compiledclass,.props))

    s index = ""
    s index = $order(props(index))
    $$$TOE(sc,%code.WriteLine("    s line = $justify("""","_props_")"))
    while index '= "" {
      s prop = props(index)
      if $classmethod(prop.Type,"%Extends","%Library.DataType") { // property is datatype
        $$$TOE(sc,##class(Generators).GenerateDataTypeExportToFixed(%compiledclass,prop,%code,"line"))
      } else { // property is something unsupported
        throw ##class(%Exception.General).%New("property "_prop.Name_" has unsupported type "_prop.Type)
      }
      s index = $order(props(index))
    }      
    $$$TOE(sc,%code.WriteLine("    return $$$OK"))
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method ExportToString(Output line As %String) As %Status [ CodeMode = objectgenerator ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
  
  s sc = $$$OK
  try {

    s type = ""
    s typeParam = ##class(%Dictionary.CompiledParameter).IDKEYOpen(%compiledclass.Name,"TYPE")
    s:$isobject(typeParam) type = typeParam.Default
    return:(type="recordset") $$$OK


    s type = ""
    s typeParam = ##class(%Dictionary.CompiledParameter).IDKEYOpen(%compiledclass.Name,"TYPE")
    s:$isobject(typeParam) type = typeParam.Default

    if type="delimited" {
      $$$TOE(sc,%code.WriteLine("    return ..ExportToStringDelimited(.line)"))
    } elseif type="fixed" {
      $$$TOE(sc,%code.WriteLine("    return ..ExportToStringFixed(.line)"))
    } else {
      throw ##class(%Exception.General).%New("unsupported record type : "_type)
    }
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method ExportToStream(stream As %Stream.Object) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim str as %String


    s type = ""
    s typeParam = ##class(%Dictionary.CompiledParameter).IDKEYOpen(%compiledclass.Name,"TYPE")
    s:$isobject(typeParam) type = typeParam.Default
    return:(type="recordset") $$$OK

    s sc = $$$OK
    try {
        $$$TOE(sc,..ExportToString(.str))
        $$$TOE(sc,stream.WriteLine(str))
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

Method ImportFromString(line As %String) As %Status [ CodeMode = objectgenerator ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
    
  s sc = $$$OK
  try {
    s type = ""
    s typeParam = ##class(%Dictionary.CompiledParameter).IDKEYOpen(%compiledclass.Name,"TYPE")
    s:$isobject(typeParam) type = typeParam.Default

    if type="delimited" {
      $$$TOE(sc,%code.WriteLine("    return ..ImportFromStringDelimited(.line)"))
    } elseif type="fixed" {
      $$$TOE(sc,%code.WriteLine("    return ..ImportFromStringFixed(line)"))
    } else {
      throw ##class(%Exception.General).%New("unsupported record type : "_type)
    }
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method ImportFromStringDelimited(line As %String) As %Status [ CodeMode = objectgenerator ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim props as %Dictionary.CompiledProperty
  #Dim index as %Integer
  #Dim prop as %Dictionary.CompiledProperty
    

  s type = ""
  s typeParam = ##class(%Dictionary.CompiledParameter).IDKEYOpen(%compiledclass.Name,"TYPE")
  s:$isobject(typeParam) type = typeParam.Default
  return:(type'="delimited") $$$OK

  s sc = $$$OK
  try {
    $$$TOE(sc,##class(Generators).FetchProps(%compiledclass,.props))
    s index = ""
    s index = $order(props(index))
    while index '= "" {
      s prop = props(index)
      if $classmethod(prop.Type,"%Extends","%Library.DataType") {
        $$$TOE(sc,##class(Generators).GenerateDataTypeImportFromDelimited(%compiledclass,prop,%code,"line",index))        
      } else {
        throw ##class(%Exception.General).%New("property "_prop.Name_" has unsupported type "_prop.Type)
      }
      s index = $order(props(index))
    }
    $$$TOE(sc,%code.WriteLine("    return $$$OK"))
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method ImportFromStringFixed(line As %String) As %Status [ CodeMode = objectgenerator ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim props as %Dictionary.CompiledProperty
  #Dim index as %Integer
  #Dim prop as %Dictionary.CompiledProperty
    
  s type = ""
  s typeParam = ##class(%Dictionary.CompiledParameter).IDKEYOpen(%compiledclass.Name,"TYPE")
  s:$isobject(typeParam) type = typeParam.Default
  return:(type'="fixed") $$$OK

  s sc = $$$OK
  try {
    $$$TOE(sc,##class(Generators).FetchProps(%compiledclass,.props))
    s index = ""
    s index = $order(props(index))
    while index '= "" {
      s prop = props(index)
      if $classmethod(prop.Type,"%Extends","%Library.DataType") {
        $$$TOE(sc,##class(Generators).GenerateDataTypeImportFromFixed(%compiledclass,prop,%code,"line",index))        
      } else {
        throw ##class(%Exception.General).%New("property "_prop.Name_" has unsupported type "_prop.Type)
      }
      s index = $order(props(index))
    }
    $$$TOE(sc,%code.WriteLine("    return $$$OK"))
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

ClassMethod DelimitedHeader() As %String [ CodeMode = objectgenerator ]
{
    s type = ""
    s typeParam = ##class(%Dictionary.CompiledParameter).IDKEYOpen(%compiledclass.Name,"TYPE")
    s:$isobject(typeParam) type = typeParam.Default
    return:(type'="delimited") $$$OK

    return ##class(Generators).DelimitedHeader(%compiledclass,%code)
}

ClassMethod Correlate(line As %String, lineNum As %Integer, Output sc As %Status) As RecordAdaptor
{
  #Dim ex as %Exception.AbstractException
  #Dim result as RecordAdaptor
  #Dim prop as %Dictionary.CompiledProperty
  
  s sc = $$$OK
  s result = $$$NULLOREF
  try {

    $$$TOE(sc,%code.WriteLine("    s result = ..%New()"))
    $$$TOE(sc,%code.WriteLine("    s sc = result.ImportFromString(line)"))    
    $$$TOE(sc,%code.WriteLine("    return:$$$ISERR(sc) $$$NULLOREF"))
    $$$TOE(sc,##class(Generators).FetchProps(%compiledclass,.props))
    s index = ""
    s index = $order(props(index))
    while index '= "" {
      s prop = props(index)
      s correlationValue  = prop.Parameters.GetAt("CORRELATION")
      if correlationValue '= "" {
        $$$TOE(sc,%code.WriteLine("    return:'(result."_prop.Name_"="""_$replace(correlationValue,"""","""""")_""") $$$NULLOREF"))    
      }
      s index = $order(props(index))
    }          
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

ClassMethod Read(stream As %Stream.Object, ByRef currentPosition As %Integer = 0, ByRef currentLineNum As %Integer = 1, Output sc As %Status) As RecordAdaptor [ CodeMode = objectgenerator ]
{
  #Dim ex as %Exception.AbstractException
  #Dim type as %String
  #Dim typeParam as %Dictionary.CompiledParameter
  
  s sc = $$$OK
  try {
    $$$TOE(sc,%code.WriteLine("    s result=$$$NULLOREF"))

    s type = ""
    s typeParam = ##class(%Dictionary.CompiledParameter).IDKEYOpen(%compiledclass.Name,"TYPE")
    s:$isobject(typeParam) type = typeParam.Default
    if (type="delimited")||(type="fixed") {      
      $$$TOE(sc,%code.WriteLine("    kill len"))
      $$$TOE(sc,%code.WriteLine("    s line = stream.ReadLine(.len,.sc)"))
      $$$TOE(sc,%code.WriteLine("    return:$$$ISERR(sc) $$$NULLOREF"))
      $$$TOE(sc,%code.WriteLine("    s result = ..Correlate(line,currentLineNum,.sc)"))
      $$$TOE(sc,%code.WriteLine("    return:$$$ISERR(sc) $$$NULLOREF"))
      $$$TOE(sc,%code.WriteLine("    if $isobject(result) {"))
      $$$TOE(sc,%code.WriteLine("      s currentPosition = currentPosition+len"))
      $$$TOE(sc,%code.WriteLine("      s currentLineNum = currentLineNum+1"))
      $$$TOE(sc,%code.WriteLine("     } else {"))
      $$$TOE(sc,%code.WriteLine("       d stream.MoveTo(currentPosition)"))
      $$$TOE(sc,%code.WriteLine("     }"))
    } elseif type="recordset" {
      $$$TOE(sc,##class(Generators).FetchProps(%compiledclass,.props))
      s index = ""
      s index = $order(props(index))
      $$$TOE(sc,%code.WriteLine("    s result=..%New()"))
      while index '= "" {
        s prop = props(index)
        if $classmethod(prop.Type,"%Extends","ks.lib.record.RecordAdaptor") {
          $$$TOE(sc,%code.WriteLine("    s result."_prop.Name_"= ..Read(stream,.currentPosition,.currentLine,.sc)"))
          $$$TOE(sc,%code.WriteLine("    return:$$$ISERR(sc) $$$NULLOREF"))
        } elseif $classmethod(prop.Type,"%Extends","%Collection.AbstractList") {
          $$$TOE(sc,%code.WriteLine("    s record= ..Read(stream,.currentPosition,.currentLine,.sc)"))          
          $$$TOE(sc,%code.WriteLine("    while $isobject(record) {"))
          $$$TOE(sc,%code.WriteLine("      s sc = result."_prop.Name_".Insert(record)"))
          $$$TOE(sc,%code.WriteLine("      return:$$$ISERR(sc) $$$NULLOREF"))
          $$$TOE(sc,%code.WriteLine("      quit:stream.AtEnd"))
          $$$TOE(sc,%code.WriteLine("      s record= ..Read(stream,.currentPosition,.currentLine,.sc)"))          
          $$$TOE(sc,%code.WriteLine("      return:$$$ISERR(sc) $$$NULLOREF"))
          $$$TOE(sc,%code.WriteLine("    }"))
        } else {
          throw ##class(%Exception.General).%New("property type not supported : "_prop.Type)
        }
        s index = $order(props(index))
      }      
    } else {
      throw ##class(%Exception.General).%New("unsupported record type : "_type)
    }
    $$$TOE(sc,%code.WriteLine("    return result"))  
  } catch (ex) {
    s %objlasterror = ex.AsStatus()
  }
}

}
