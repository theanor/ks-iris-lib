Class ks.lib.xdata.Utils Extends %RegisteredObject
{

/// export XData block named <b>xdataName</b> of class <b>className</b> to file <b>fileName</b>
/// if <b>fileName</b> is not defined, method will set it to a new temporary file name
ClassMethod ExportToFile(className As %Dictionary.Classname, xdataName As %Dictionary.Identifier, ByRef fileName As %String) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim fileStream as %Stream.FileCharacter
    #Dim xdataStream as %Stream.TmpCharacter
    #Dim xdataDef as %Dictionary.XDataDefinition
    #Dim compiledXDataDef as %Dictionary.CompiledXData
    
    s sc = $$$OK
    try {              
        s xdataStream = $$$NULLOREF
        s xdataDef = ##class(%Dictionary.XDataDefinition).IDKEYOpen(className,xdataName)
        if $isobject(xdataDef) {
            s xdataStream = xdataDef.Data
        } else {
            s compiledXDataDef = ##class(%Dictionary.CompiledXData).IDKEYOpen(className,xdataName)
            s:$isobject(compiledXDataDef) xdataStream = compiledXDataDef.Data
        }
        if $isobject(xdataStream) {          
          s fileName = ##class(%File).TempFilename()            
          s fileStream = ##class(%Stream.FileCharacter).%New()
          s fileStream.Filename = fileName
          $$$TOE(sc,fileStream.CopyFrom(xdataStream))
          $$$TOE(sc,fileStream.%Save())
        } else {
            s fileName = ""
        }
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

}
