/// Object utilities
Class ks.lib.object.Utils
{

/// returns true if <b>className</b> is abstract
ClassMethod IsAbstract(className As %Dictionary.Classname, Output sc As %Status) As %Boolean
{
  
  #Dim ex as %Exception.AbstractException
  #Dim result as %Boolean
  #Dim compiledClass as %Dictionary.CompiledClass
  
  s sc = $$$OK
  s result = 0
  try {
    s compiledClass = ##class(%Dictionary.CompiledClass).%OpenId(className)
    if $isobject(compiledClass) {
      s result = compiledClass.Abstract
    } else {
      throw ##class(%Exception.General).%New("class not found",,,className)
    }    
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

/// returns true if <b>property</b> of <b>className</b> extends <b>propertyClassName</b>
ClassMethod PropertyExtends(className As %Dictionary.Classname, property As %Dictionary.Identifier, propertyClassName As %Dictionary.Classname, Output sc As %Status) As %Boolean
{
    #Dim ex as %Exception.AbstractException

    #Dim type as %Dictionary.Classname
    #Dim result as %Boolean
    
    s sc = $$$OK
    try {
      s type = ..GetPropertyType(className,property,.sc)
      $$$TOE(sc,sc)
      s result = $classmethod(type,"%Extends",propertyClassName)
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return result
}

/// returns <b>className</b> <b>property</b> type
ClassMethod GetPropertyType(className As %Dictionary.Classname, property As %Dictionary.Identifier, Output sc As %Status) As %Dictionary.Classname
{
    #Dim ex as %Exception.AbstractException
    #Dim cp as %Dictionary.CompiledProperty
    
    s sc = $$$OK
    s result = ""
    try {
      s cp = ##class(%Dictionary.CompiledProperty).IDKEYOpen(className,property)
      if '$isobject(cp) throw ##class(%Exception.General).%New("property not found : "_className_"."_property)      
      s result = cp.Type
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return result
}

}
