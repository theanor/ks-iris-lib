Class ks.lib.record.Writer Extends %RegisteredObject
{

Property Stream As %Stream.Object [ ReadOnly ];

Method WriteHeader(recordClass As %Dictionary.Classname) As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
  
  s sc = $$$OK
  try {
    $$$TOE(sc,..Stream.WriteLine($classmethod(recordClass,"DelimitedHeader")))
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method Write(record As RecordAdaptor) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim str as %String
    
    s sc = $$$OK
    try {
        $$$TOE(sc,record.ExportToString(.str))
        $$$TOE(sc,..Stream.WriteLine(str))
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

Method OutputToStream(stream As %Stream.Object) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    
    s sc = $$$OK
    try {
        s r%Stream = stream
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

Method OutputToFile(fileName As %String) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    
    s sc = $$$OK
    try {
        s ..Stream = ##class(%Stream.FileCharacter).%New()
        s ..Stream.Filename = fileName
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

}
