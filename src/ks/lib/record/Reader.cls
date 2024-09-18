Class ks.lib.record.Reader Extends %RegisteredObject
{

/// array of $list like <correlate method suffix>,<param1>,<param2>,...
Property Correlations As %List [ MultiDimensional, Private ];

Property Stream As %Stream.Object [ Private ];

Property LineIndex As %Integer [ ReadOnly ];

Method CorrelatePropertyValue(className As %Dictionary.Classname, propertyName As %Dictionary.Identifier, value As %String) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    #Dim props as %Dictionary.CompiledProperty
    #Dim compiledClass As %Dictionary.CompiledClass
    
    s sc = $$$OK
    try {
        s compiledClass = ##class(%Dictionary.CompiledClass).%OpenId(className)
        if '$isobject(compiledClass) throw ##class(%Exception.General).%New("class not found (or not compiled) : "_className)
        $$$TOE(sc,##class(Generators).FetchProps(compiledClass,.props))
        $$$TOE(sc,..AddCorrelation("Property",className,propertyName,value))
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

Method CorrelateLineIndex(className As %Dictionary.Classname, index As %Integer) As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
  
  s sc = $$$OK
  try {
    $$$TOE(sc,..AddCorrelation("LineIndex",className,index))
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method AddCorrelation(type As %String, params... As %String) As %Status [ Private ]
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
  
  s sc = $$$OK
  try {
    s idx = $increment(..Correlations)
    s ..Correlations(idx,0) = type
    merge ..Correlations(idx,1) = params
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method CorrelateDefault(className As %Dictionary.Classname) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    
    s sc = $$$OK
    try {
        d ..AddCorrelation("Default",className)
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

Method ReadRecord(line As %String, Output sc As %Status) As RecordAdaptor [ Private ]
{
  #Dim ex as %Exception.AbstractException
  #Dim result as %Dictionary.Classname
  #Dim k as %String
  #Dim method as %String
  #Dim params as %List
  
  s sc = $$$OK
  s result = ""
  try {
    s k = ""
    s k = $order(..Correlations(k))
    while k '= "" {
      s method = "CorrelateRecordBy"_..Correlations(k,0)
      merge params = ..Correlations(k,1)
      s result = $method($this,method,line,.sc,.params)
      $$$TOE(sc,sc)
      quit:(result '= "")
      s k = $order(..Correlations(k))
    }
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

Method CorrelateRecordByLineIndex(line As %String, Output sc As %Status, ByRef params) As RecordAdaptor [ Private ]
{
  #Dim ex as %Exception.AbstractException
  #Dim result as RecordAdaptor
  #Dim className as %Dictionary.Classname
  
  s sc = $$$OK
  s result = $$$NULLOREF
  try {
    if ..LineIndex = params(2) {
      s className = params(1)
      s result = $classmethod(className,"%New")
      $$$TOE(sc,result.ImportFromString(line))
    }    
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

Method CorrelateRecordByDefault(line As %String, Output sc As %Status, ByRef params) As RecordAdaptor [ Private ]
{
  #Dim ex as %Exception.AbstractException
  #Dim result as RecordAdaptor
  #Dim className as %Dictionary.Classname
  
  s sc = $$$OK
  s result = $$$NULLOREF
  try {
    s className = params(1)
    s result = $classmethod(className,"%New")
    $$$TOE(sc,result.ImportFromString(line))
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

Method CorrelateRecordByProperty(line As %String, Output sc As %Status, ByRef params) As RecordAdaptor [ Private ]
{
  #Dim ex as %Exception.AbstractException
  #Dim result as RecordAdaptor
  #Dim className As %Dictionary.Classname
  #Dim propertyName As %Dictionary.Identifier
  #Dim value As %String
  
  s sc = $$$OK
  s result = $$$NULLOREF
  try {
    s className = params(1)
    s propertyName = params(2)
    s value = params(3)
    s record = $classmethod(className,"%New")
    if $$$ISOK(record.ImportFromString(line)) {
      if $property(record,propertyName)=value {
        s result = record
      }
    }
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

Method OpenStream(stream As %Stream.Object) As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException
    
    s sc = $$$OK
    try {
        s ..Stream = stream
        s i%LineIndex = 0
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

Method OpenFile(fileName As %String) As %Status
{
    s stream = ##class(%Stream.FileCharacter).%New()
    s stream.Filename = fileName
    return ..OpenStream(stream)
}

Method Next(Output sc As %Status) As RecordAdaptor
{
    #Dim ex as %Exception.AbstractException
    #Dim result as RecordAdaptor
    #Dim line as %String
    
    s sc = $$$OK
    s result = $$$NULLOREF
    try {
      if '..Stream.AtEnd {
        s line = ..Stream.ReadLine()
        s i%LineIndex = i%LineIndex+1
        s result = ..ReadRecord(line,.sc)
        $$$TOE(sc,sc)
      }
    } catch (ex) {
      s sc = ##class(%SYSTEM.Status).AppendStatus($$$ERROR($$$GeneralError,"at line "_..LineIndex),ex.AsStatus())
    }
    return result
}

Method SkipLines(count As %Integer) As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
  #Dim skipped as %Integer
  
  s sc = $$$OK
  try {
    s skipped = 0
    while '..Stream.AtEnd && (skipped < count) {
      d ..Stream.ReadLine()
      s skipped = skipped+1
    }
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

}
