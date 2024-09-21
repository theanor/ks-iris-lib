/// interoperability configuration utilities
Class ks.lib.interop.ConfigUtils
{

/// Add a new configuration item to production <b>prod</b>
ClassMethod AddConfigItem(prod As Ens.Config.Production, name As %String, className As %String, ByRef item As Ens.Config.Item, enabled As %Boolean = 1, poolSize As %Integer = 1) As %Status
{
	
	#Dim sc as %Status
	#Dim ex as %Exception.AbstractException
	
	s sc = $$$OK
	try {
		s item = ##class(Ens.Config.Item).%New()		
		s item.ClassName = className
		s item.Name = name
		s item.PoolSize = poolSize
		s item.Enabled = enabled
		$$$TOE(sc,prod.Items.Insert(item))	
	} catch (ex) {
		s sc = ex.AsStatus()
	}
    return sc
}

/// set configuration <b>item</b> setting <b>name</b> to <b>value</b>, <b>target</b> must be either "Host" or "Adapter"
ClassMethod SetSetting(item As Ens.Config.Item, name As %String, value As %String, target As %String) As %Status
{
	
	#Dim sc As %Status
	#Dim ex As %Exception.AbstractException
	#Dim setting as Ens.Config.Setting
	
	s sc = $$$OK
	try {
	 s setting = item.FindSettingByName(name)
	 if (setting = "") {
		 s setting = ##class(Ens.Config.Setting).%New()
		 s setting.Name = name		 
		 s setting.Target = target
		 d item.Settings.Insert(setting)
	 }
	 s setting.Value = value	 
	} catch (ex) {
		s sc = ex.AsStatus()
	}
    return sc
}

/// return value of configuration item <b>name</b> <b>settingName</b> setting
/// set optional <b>productionName</b> to address non-current productions
ClassMethod GetSetting(name As Ens.DataType.ConfigName, settingName As %Dictionary.Identifier, productionName As %Dictionary.Identifier = "", Output status As %Status) As %String
{
	#Dim sc as %Status = $$$OK
	#Dim ex as %Exception.AbstractException

	#Dim result as %String = ""
	#Dim item as Ens.Config.Item
	#Dim setting as Ens.Config.Setting
	
	try {
		s item = ..GetConfigItem(name,productionName,.sc)
		$$$TOE(sc,sc)
		if $isobject(item) {
			s setting = item.FindSettingByName(settingName)
			if $isobject(setting) {
				s result = setting.Value
			}
		}		
	}
	catch (ex) {
	  s sc = ex.AsStatus()
	}
	return result
}

/// fill pArray with the target config names specified in property of pItem
ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item, property As %String = "TargetConfigNames")
{
	if pItem.GetModifiedSetting(property,.tValue) {
		for i=1:1:$L(tValue,",") { Set tOne=$ZStrip($P(tValue,",",i),"<>W")  Continue:""=tOne  Set pArray(tOne)="" }
	}
}

/// import lookup table from XData section xdataName in className
ClassMethod ImportLUTFromXData(className As %String, xdataName As %String) As %Status
{
	#Dim xdata as %Dictionary.CompiledXData
	
	
	#Dim sc as %Status
	#Dim ex as %Exception.AbstractException
	#Dim data as %Stream.Object
	#Dim count as %Integer
	
	s sc = $$$OK
	try {
		
	  s xdata=##class(%Dictionary.CompiledXData).%OpenId(className_"||"_xdataName)
	  if $isobject(xdata) {
		  s data = xdata.Data
		  $$$TOE(sc,##class(Ens.Util.LookupTable).%Import(data,,.count))
	  } else {
		  throw ##class(%Exception.General).%New("xdata "_xdataName_" not found in class "_className)
	  }		
	} catch (ex) {
		s sc = ex.AsStatus()
	}
    return sc
}

ClassMethod GetConfigItem(name As %String, productionName As %String = "", ByRef sc As %Status) As Ens.Config.Item
{
	#Dim ex as %Exception.AbstractException

	#Dim result as Ens.Config.Item
	#Dim id as %Integer

	s sc = $$$OK	
	s result = $$$NULLOREF

	try {
		s:productionName="" productionName=##class(Ens.Director).GetActiveProductionName()		
		s:$$$ISOK(##class(Ens.Config.Item).NameExists(productionName,name,.id)) result =##class(Ens.Config.Item).IDKEYOpen(id)
	} catch (ex) {
	  s sc = ex.AsStatus()
	}
	return result
}

/// returns array of config items using <b>className</b>
ClassMethod FindItemsOfClass(className As %Dictionary.Classname, Output items As Ens.Config.Item, productionName As %Dictionary.Classname = "") As %Status
{
	#Dim sc as %Status = $$$OK
	#Dim ex as %Exception.AbstractException

	#Dim production As Ens.Config.Production
	#Dim curItem As Ens.Config.Item
		
	try {
		s:productionName="" productionName = ##class(Ens.Director).GetActiveProductionName()
		s production = ##class(Ens.Config.Production).%OpenId(productionName)
		kill items
		for i=1:1:production.Items.Size
		 {
	      s curItem = production.Items.GetAt(i)
		  if (curItem.ClassName=className) {
			s items($increment(items)) = curItem
			quit
		  }
		 }		
	} catch (ex) {
	  s sc = ex.AsStatus()
	}
	return sc
}

ClassMethod HeaderSourceConfigName(headerId As %Integer) As %String
{
	#Dim header as Ens.MessageHeader

	s header = ##class(Ens.MessageHeader).%OpenId(headerId)
	return header.SourceConfigName
}

ClassMethod HeaderTargetConfigName(headerId As %Integer) As %String
{
	#Dim header as Ens.MessageHeader

	s header = ##class(Ens.MessageHeader).%OpenId(headerId)
	return header.TargetConfigName
}

ClassMethod GetCategoryItems(productionName As %Dictionary.Classname, category As %String, Output items As %ListOfObjects(ELEMENTTYPE="Ens.Config.Item")) As %Status
{
	#Dim sc as %Status
	#Dim prod As Ens.Config.Production
	#Dim item As Ens.Config.Item
	#Dim catlist As %List

	s sc = $$$OK
	s items = ##class(%ListOfObjects).%New()
	try {
  	     $$$TOE(sc,##class(Ens.Director).GetProductionStatus(.productionName,.productionState))
		 s prod = ##class(Ens.Config.Production).%OpenId(productionName)
		 for i=1:1:prod.Items.Size
		 {
	      s item = prod.Items.GetAt(i)
	      s catlist = $lfs(item.Category,",")
	      if ($listfind(catlist,category) > 0) {
			  $$$TOE(sc,items.Insert(item))		      
	      }	      
		 }		
	} catch ex {
		s sc = ex.AsStatus()		
	}
	return sc
}

ClassMethod MergeEnsColumns(targetNameSpace As %Dictionary.Identifier = {$namespace}) As %Status
{
  new $namespace
  s $namespace = "%SYS"

  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException
  #Dim sourceDirectory, targetDirectory as SYS.Database
  #Dim targetDB as %Dictionary.Identifier
  #Dim properties as %String
  
  s sc = $$$OK
  try {

    s sourceDirectory = ##class(%SYS.Namespace).GetGlobalDest(targetNameSpace, "^IRIS.Msg", "EnsColumns") 
    s targetDirectory = ##class(%SYS.Namespace).GetGlobalDest(targetNameSpace)

    if sourceDirectory = targetDirectory { // EnsColumns already mapped, merge again, but from ENSLIB
      $$$TOE(sc,##class(Config.Databases).Get("ENSLIB",.properties))
      s sourceDirectory = "^"_properties("Directory")
    } 

    merge ^|"^"_targetDirectory|IRIS.Msg("EnsColumns")=^|"^"_sourceDirectory|IRIS.Msg("EnsColumns")

    $$$TOE(sc,##class(Config.Namespaces).Get(targetNameSpace,.properties))
    s targetDB = $get(properties("Globals"))
    if targetDB '= "" {
      kill properties
      $$$TOE(sc,##class(Config.MapGlobals).Get(targetNameSpace, "IRIS.Msg(""EnsColumns"")", .properties))
      s properties("Database") = targetDB
      $$$TOE(sc,##class(Config.MapGlobals).Modify(targetNameSpace, "IRIS.Msg(""EnsColumns"")", .properties))
    }

  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

/// Upload messages (display names in management portal) for settings from xdataName in compiledClass into ^IRIS.Msg
/// Expects messages as JSON in xdata
/// {
///   "APropertyName" : {
///     "en" : "english text",
///     "fr" : "texte en français",
///     ...
///   },
///   ...
/// }
ClassMethod SetSettingsMessages(compiledClass As %Dictionary.CompiledClass, xdataName As %String = "SettingsMessages") As %Status
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim settings as %List
    #Dim ptr as %Integer
    #Dim propName as %String
    #Dim prop as %Dictionary.CompiledProperty
    #Dim xdata as %Dictionary.CompiledXData
    #Dim settingMsgs as %DynamicAbstractObject
    #Dim settingsParameter as %Dictionary.CompiledParameter
    #Dim langIterator as %Iterator
    
    s sc = $$$OK
    try {
        s xdata = ##class(%Dictionary.CompiledXData).IDKEYOpen(compiledClass.Name,xdataName)        
        if $isobject(xdata) && (xdata.MimeType="application/json") && $isobject(xdata.Data) {          
          s msgs = ##class(%DynamicAbstractObject).%FromJSON(xdata.Data)
          if $isobject(msgs) {
            s settingsParameter = ##class(%Dictionary.CompiledParameter).IDKEYOpen(compiledClass.Name,"SETTINGS")
            s settings = $listfromstring(settingsParameter.Default,",")
            s ptr = 0
            while $listnext(settings,ptr,setting) {
              s propName = $piece(setting,":",1)
              s prop = ##class(%Dictionary.CompiledProperty).IDKEYOpen(compiledClass.Name,propName)
              if $isobject(prop) {
                s settingMsgs = msgs.%Get(propName)
                if $isobject(settingMsgs) {
                    s langIterator = settingMsgs.%GetIterator()
                    while langIterator.hasNext() {                        
                        s langMsg = langIterator.next()
                        s lang = langMsg.key
                        s text = langMsg.value    
                        s ^IRIS.Msg("EnsColumns",lang,propName)=text
                    }
                }
              }
            }
          }      
        }        
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

}
