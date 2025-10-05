Class ks.lib.interop.TransformUtils
{

ClassMethod GetAuxProperty(ByRef aux As %Any, propertyName As %Dictionary.Identifier, defaultValue As %String = "", Output sc As %Status) As %Any
{
    #Dim ex,propEx as %Exception.AbstractException
    #Dim result as %String
    #Dim propList as %List
    #Dim ptr as %Integer
    #Dim propAssign,propName,propValue as %String
    
    s sc = $$$OK
    s result = defaultValue
    try {      
      if $data(aux) && $isobject(aux) { // fetch aux object property value
        try {
          s result = $property(aux,propertyName)      
        } catch (propEx) {
          // do nothing
        }
      } elseif $data(aux) && (aux [ "=") { // fetch list property value
        s propList = $listfromstring(aux)
        s ptr = 0
        while $listnext(propList,ptr,propAssign) {
          s propName = $piece(propAssign,"=",1)
          s propValue = $piece(propAssign,"=",2)
          if propName=propertyName {
            s result = $extract(propValue,2,*-1)
            quit
          }
        }
      } 
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return result
}

}
