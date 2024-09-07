Class ks.lib.record.Generators
{

ClassMethod GenerateDataTypeExportToDelimited(compiledclass As %Dictionary.CompiledClass, prop As %Dictionary.CompiledProperty, code As %Stream.TmpCharacter, strvar As %Dictionary.Identifier = "line") As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim escaping as %String
    #Dim esc as %String
    
    s sc = $$$OK
    try {
      s escaping = ##class(%Dictionary.CompiledParameter).IDKEYOpen(compiledclass.Name,"ESCAPING").Default
      s esc = ##class(%Dictionary.CompiledParameter).IDKEYOpen(compiledclass.Name,"ESCAPECHAR").Default
      if escaping="all"  {
        $$$TOE(sc,code.WriteLine("    s value="""_$replace(esc,"""","""""")_"""_$property($this,"""_prop.Name_""")_"""_$replace(esc,"""","""""")_""""))
        $$$TOE(sc,code.WriteLine("    s "_strvar_"="_strvar_"_value"))
      } elseif escaping="del" {
        $$$TOE(sc,code.WriteLine("    s value=$property($this,"""_prop.Name_""")"))
        $$$TOE(sc,code.WriteLine("    s:(value["""_$replace(esc,"""","""""")_""") value="""_$replace(esc,"""","""""")_"""_value_"""_$replace(esc,"""","""""")_""""))
        $$$TOE(sc,code.WriteLine("    s "_strvar_"="_strvar_"_value"))
      } else {
        $$$TOE(sc,code.WriteLine("    s "_strvar_"="_strvar_"_$property($this,"""_prop.Name_""")"))        
      }
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

ClassMethod GenerateDataTypeExportToFixed(compiledclass As %Dictionary.CompiledClass, prop As %Dictionary.CompiledProperty, code As %Stream.TmpCharacter, strvar As %Dictionary.Identifier = "line") As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim startCol,endCol as %Integer
    #Dim len as %Integer
    
    s sc = $$$OK
    try {              

        s fillerParam = ##class(%Dictionary.CompiledClass).IDKEYOpen(compiledclass,"FILLER")
        s filler = $select($isobject(fillerParam):fillerParam.Default,1:" ")

        s startCol = prop.Parameters.GetAt("COL")
        if startCol="" {
          s startCol = 1
        }

        s len = prop.Parameters.GetAt("LEN")
        s:len="" len = prop.Parameters.GetAt("MAXLEN")

        s endCol = startCol+len-1

        if startCol <= endCol {          

          
          s padding = prop.Parameters.GetAt("PADDING")
          s:padding="" padding="right"
          s colLen = endCol-startCol+1
          s padPos=$case(padding,"left":-colLen,"right":colLen,:colLen)
          s padChar = prop.Parameters.GetAt("FILLER")          
          if padChar = "" {
            s padParam = ##class(%Dictionary.CompiledClass).IDKEYOpen(compiledclass,"FILLER")
            if $isobject(padParam) s padChar = padParam.Default
          }          
          s:padChar="" padChar = " "
          $$$TOE(sc,code.WriteLine("    s value = $property($this,"""_prop.Name_""")"))          
          $$$TOE(sc,code.WriteLine("    s value = ##class(Ens.Util.FunctionSet).Pad(value,"_padPos_","""_padChar_""")")) 
          $$$TOE(sc,code.WriteLine("    s $extract("_strvar_","_startCol_","_endCol_") = value"))                         
        } 
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

ClassMethod GenerateDataTypeImportFromDelimited(compiledclass As %Dictionary.CompiledClass, prop As %Dictionary.CompiledProperty, code As %Stream.TmpCharacter, strvar As %String, index As %Integer) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    #Dim escaping as %String
    #Dim esc as %String

    
    s sc = $$$OK
    try {
      s escaping = ##class(%Dictionary.CompiledParameter).IDKEYOpen(compiledclass.Name,"ESCAPING").Default
      s esc = ##class(%Dictionary.CompiledParameter).IDKEYOpen(compiledclass.Name,"ESCAPECHAR").Default
      if escaping="all" {
        $$$TOE(sc,code.WriteLine("    s value = $extract($piece("_strvar_",..#SEPARATOR,"_index_"),"_($length(esc)+1)_",*-"_$length(esc)_")"))
      } elseif escaping="sep" {
        $$$TOE(sc,code.WriteLine("    s value = $piece("_strvar_",..#SEPARATOR,"_index_")"))
        $$$TOE(sc,code.WriteLine("    s:(value["""_$replace(esc,"""","""""")_""") value = $extract($piece("_strvar_",..#SEPARATOR,"_index_"),"_($length(esc)+1)_",*-"_$length(esc)_")"))
      } else {
        $$$TOE(sc,code.WriteLine("    s value = $piece("_strvar_",..#SEPARATOR,"_index_")"))
      }
      $$$TOE(sc,code.WriteLine("    s $property($this,"""_prop.Name_""") = value"))
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

ClassMethod GenerateDataTypeImportFromFixed(compiledclass As %Dictionary.CompiledClass, prop As %Dictionary.CompiledProperty, code As %Stream.TmpCharacter, strvar As %String, startCol As %Integer) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim endCol as %Integer

    
    s sc = $$$OK
    try {
     s colLen = prop.Parameters.GetAt("LEN")
     s:colLen="" colLen = prop.Parameters.GetAt("MAXLEN")
     s endCol = startCol+colLen

     s padding = prop.Parameters.GetAt("PADDING")
     s:padding="" padding="right"

     s padChar = prop.Parameters.GetAt("FILLER")          
     if padChar = "" {
       s padParam = ##class(%Dictionary.CompiledClass).IDKEYOpen(compiledclass,"FILLER")
       if $isobject(padParam) s padChar = padParam.Default
     }          
     s:padChar="" padChar = " "
     $$$TOE(sc,code.WriteLine("    s value = $extract("_strvar_","_(startCol)_","_(endCol)_")"))
     if padding="left" {
      $$$TOE(sc,code.WriteLine("   s value = $zstrip(value,""<"","""_padChar_""")"))
     } elseif padding="right" {
      $$$TOE(sc,code.WriteLine("   s value = $zstrip(value,"">"","""_padChar_""")"))
     }
     $$$TOE(sc,code.WriteLine("    s $property($this,"""_prop.Name_""") = value"))
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

ClassMethod FetchProps(compiledclass As %Dictionary.CompiledClass, Output props As %Dictionary.CompiledProperty) As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim i,index,lastCol as %Integer
  #Dim prop as %Dictionary.CompiledProperty
  
  s sc = $$$OK
  try {
    for i = 1:1:compiledclass.Properties.Count() {
      s prop = compiledclass.Properties.GetAt(i)
      if 'prop.Transient && '(prop.Parameters.GetAt("RECORDEXCLUDE")) {
        s index = prop.Parameters.GetAt("COL")
        if index="" s index = i
        s props(index) = prop        
      }
    }
    s lastCol = $order(props(""),-1)
    if lastCol '= "" {
      s len = props(lastCol).Parameters.GetAt("LEN")
      s:(len="") len = props(lastCol).Parameters.GetAt("MAXLEN")      
      s props = lastCol+len-1
    } else {
      s props = 0
    }
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

ClassMethod DelimitedHeader(compiledclass As %Dictionary.CompiledClass, code As %Stream.TmpCharacter) As %String
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim i as %Integer
  #Dim props as %Dictionary.CompiledProperty
  #Dim prop as %Dictionary.CompiledProperty
  #Dim curIndex,index as %Integer
  #Dim colName as %String
  #Dim cols as %List
  #Dim separator as %String
  
  s sc = $$$OK
  try {
    $$$TOE(sc,##class(Generators).FetchProps(compiledclass,.props))
    s curIndex = 1
    s index = ""
    s index = $order(props(index))
    s cols = ""
    while index '= "" {
      while index > curIndex {
          s colName="untitled"_curIndex
          s $list(cols,*+1) = colName
          s curIndex = curIndex + 1
      }
      s prop = props(index)
      if $classmethod(prop.Type,"%Extends","%Library.DataType") { // property is datatype
        s colName = prop.Parameters.GetAt("COLNAME")
        s:(colName="") colName = prop.Name
        s $list(cols,*+1) = colName
        s curIndex = curIndex + 1
      } else { // property is something unsupported
        throw ##class(%Exception.General).%New("property "_prop.Name_" has unsupported type "_prop.Type)
      }
      s index = $order(props(index))
    }      
    s separator = ##class(%Dictionary.CompiledParameter).IDKEYOpen(compiledclass.Name,"SEPARATOR").Default
    $$$TOE(sc,code.WriteLine("    return """_$listtostring(cols,separator)_""""))
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

}
