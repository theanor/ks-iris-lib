/// JSON utilities
Class ks.lib.json.Utils
{

/// returns a %List with all object keys
ClassMethod ObjectKeyList(object As %DynamicObject) As %List
{
 #Dim iterator as %Iterator.Object
 #Dim key As %String
 #Dim keys As %List 

 s iterator=object.%GetIterator()
 while iterator.%GetNext(.key,.val) { s $LIST(keys,*+1) = key }
 return keys
}

/// returns a %List with all object keys values 
ClassMethod KeyValuesList(object As %DynamicObject, keys As %List) As %List
{
 #Dim value As %List
 #Dim ptr As %Integer

 s ptr=0
 while $listnext(keys,ptr,value) {
     if $data(value) {         
         s $list(values,*+1) = object.%Get(value)
     }
 }
 return values
}

/// format timestamp <b>value</b> to JSON usual date format (ISO-8601, same as XSD date-time type)
ClassMethod FormatTimeStamp(value As %TimeStamp) As %String [ CodeMode = expression ]
{
##class(%TimeStamp).LogicalToXSD(value)
}

/// build %DynamicArray from a list of objects extending %JSON.Adaptor
ClassMethod ListToArray(list As %ListOfObjects(ELEMENTTYPE="%JSON.Adaptor"), Output array As %DynamicArray) As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException
    #Dim idx 
    #Dim str as %String
    
    try {
            s array = [] 
            s idx = list.Next()
            while idx '="" {
                $$$TOE(sc,list.GetAt(idx).%JSONExportToString(.str))
                d array.%Push({}.%FromJSON(str))
                s idx = list.Next(idx)
            }

    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

/// set <b>result</b> to JSON from XData section <b>xDataName</b> in <b>className</b>
ClassMethod JSONFromXData(className As %Dictionary.Classname, xDataName As %Dictionary.Identifier, Output result As %DynamicAbstractObject) As %Status
{
  #Dim xData As %Dictionary.CompiledXData
  #Dim stream As %Stream.Object

  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException
  
  try {
   s xData=##class(%Dictionary.CompiledXData).%OpenId(className_"||"_xDataName)
   if $isobject(xData) {
    s stream=xData.Data
	if $IsObject(stream) {
	 s result = {}.%FromJSON(stream)
	} 
   }
  } catch (ex) {
	s sc = ex.AsStatus()
  }
  return sc
}

/// reads JSON from file 
ClassMethod JSONFromFile(fileName As %String) As %DynamicAbstractObject
{
  // use %FromJSONFile if method is available in this version
  return $select($isobject(##class(%Dictionary.CompiledMethod).IDKEYOpen(##class(%DynamicAbstractObject).%ClassName(1),"%FromJSONFile")) : ##class(%DynamicAbstractObject).%FromJSONFile(fileName),1:##class(%DynamicAbstractObject).%FromJSON(fileName))
}

}
