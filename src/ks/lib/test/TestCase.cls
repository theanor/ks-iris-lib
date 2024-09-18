Class ks.lib.test.TestCase Extends %UnitTest.TestCase [ Abstract ]
{

ClassMethod Run(testMethod As %String = "", ByRef userParams) As %Status
{
  return ##class(%UnitTest.Manager).DebugRunTestCase("", $classname(), "/debug=0/recursive=0",testMethod,.userParams)
}

ClassMethod Debug(testMethod As %String = "", ByRef userParams) As %Status
{
  return ##class(%UnitTest.Manager).DebugRunTestCase("", $classname(), "/debug=1/recursive=0",testMethod,.userParams)
}

ClassMethod ResourceFile(path As %String) As %String
{
   return ##class(%Library.File).NormalizeFilename(path,##class(Runner).TestResourceDirectory())
}

ClassMethod ResourceDirectory(path As %String) As %String
{
   return ##class(%Library.File).NormalizeDirectory(path,##class(Runner).TestResourceDirectory())
}

ClassMethod ImportHL7Schema(file As %String, Output importedCategory) As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException
  
  try {
    $$$TOE(sc,##class(EnsLib.HL7.SchemaXML).Import(..ResourceFile(file),.importedCategory))    
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

ClassMethod ImportHL7FromFile(fileName As %String, docTypeCategory As %String, isTestResource As %Boolean = 1) As EnsLib.HL7.Message
{
  #Dim msg As EnsLib.HL7.Message
  #Dim f As %String

  s f=$select(isTestResource:..ResourceFile(fileName),1:fileName)
  s msg = ##class(EnsLib.HL7.Message).ImportFromFile(f)
  if $isobject(msg) && $d(docTypeCategory) d ##class(ks.lib.hl7.Utils).ResolveDocType(msg,docTypeCategory)
  return msg
}

ClassMethod ImportXMLFromFile(className As %String, fileName As %String, namespace As %String = "", pathIsTestResource As %Boolean = 1) As %RegisteredObject
{
  #Dim sc as %Status = $$$OK
  #Dim result as %RegisteredObject
  #Dim fp as %String

  s fp = $select(pathIsTestResource:##class(%File).NormalizeFilename(fileName,##class(Runner).ResourceDirectory()),1:fileName)
  s result = ##class(ks.lib.xml.Utils).ImportClassFromFile(className,fp,namespace,.sc) 
  return result
}

Method ExportXMLToFile(object As %XML.Adaptor, fileName As %String, logMessage As %Boolean = 1) As %Status
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
    $$$TOE(sc,object.XMLExportToStream(.stream))
    $$$TOE(sc,stream.%Save())        
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

Method ImportJSONFromFile(className As %String, fileName As %String, pathIsTestResource As %Boolean = 1, Output sc As %Status) As %RegisteredObject
{
  #Dim ex as %Exception.AbstractException

  #Dim result as %JSON.Adaptor

  s sc = $$$OK  
  try {
    s result = $classmethod(className,"%New")  
  	if result.%Extends("%JSON.Adaptor") {
	    $$$TOE(sc,result.%JSONImport(##class(ks.lib.json.Utils).JSONFromFile(fileName)))
	  } else {
  	  throw ##class(%Exception.General).%New("class does extend %JSON.Adaptor : "_className)
  	}
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return result
}

Method ExportJSONToFile(object As %JSON.Adaptor, fileName As %String, logMessage As %Boolean = 1) As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException

  #Dim stream as %Stream.FileCharacter
  
  try {
     if '$d(fileName) {
      s fileName = ##class(%File).TempFilename(".json")
    }
    s stream = ##class(%Stream.FileCharacter).%New()
    s stream.Filename = fileName
    $$$TOE(sc,object.%JSONExportToStream(.stream))
    $$$TOE(sc,stream.%Save())
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

ClassMethod ImportStreamContainerFromFile(fileName As %String, pathIsTestResource As %Boolean = 1) As Ens.StreamContainer
{
  #Dim result As Ens.StreamContainer
  #Dim stream As %Library.FileBinaryStream

  s stream = ##class(%Library.FileBinaryStream).%New()
  s stream.Filename = $select(pathIsTestResource:..ResourceFile(fileName),1:fileName)
  s result = ##class(Ens.StreamContainer).%New(stream)
  return result
}

/// Copy files matching <b>fileSpec</b> from test resource subfolder <b>sourceDir</b> to <b>targetDir</b>.
/// Returns error status if copy fails.
Method CopyResources(fileSpec As %String, sourceDir As %String, targetDir As %String, sourceDirIsResources As %Boolean = 1) As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException

  #Dim rs as %ResultSet
  #Dim cnt as %Integer

  
  
  Try {      
 	  Set rs = ##class(%ResultSet).%New("%Library.File:FileSet")
    s sourcePath = ..ResourceDirectory(sourceDir)
    $$$TOE(sc,rs.Execute(sourcePath,fileSpec,"Name",0)) 
    s cnt = 0
    while rs.Next() { 
      $$$TOE(sc,..CopyResource(rs.Get("ItemName"),sourceDir,targetDir,sourceDirIsResources))      
      s cnt = cnt+1
    }
  }
  Catch (ex) {
    Set sc = ex.AsStatus()
  }
  Quit sc
}

/// copy file <b>fileName</b> from source test resources directory <b>sourceDir</b> to target directory <b>targetDir</b>
Method CopyResource(fileName As %String, sourceDir As %String, targetDir As %String, sourceDirIsResources As %Boolean = 1) As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException

    #Dim sourceName,targetName as %String
    
    try {
        s sourceName = ##class(%File).NormalizeFilename(fileName,$select(sourceDirIsResources:..ResourceDirectory(sourceDir),1:sourceDir))
        s targetName = ##class(%File).NormalizeFilename(fileName,targetDir)        
        $$$TOE(sc,##class(%File).CopyFile(sourceName, targetName))
    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
    q sc
}

ClassMethod CompareMessageFiles(messageFileName As %String, expectedFileName As %String, className As %String, namespace As %String = "", Output diffs As %String, Output sc As %Status) As %Boolean
{
	
	#Dim ex as %Exception.AbstractException
	#Dim result as %Boolean
	#Dim message,expected as %XML.Adaptor
	
	s result = 1
	s sc = $$$OK
	try {
		s message = ..ImportFromXML(className, messageFileName,namespace,.sc)
		$$$TOE(sc,sc)
		s expected = ..ImportFromXML(className, expectedFileName,namespace,.sc)
		$$$TOE(sc,sc)
		s result = ..CompareMessages(message,expected,.sc)
		if 'result {
			s diffs(className,expectedFileName,messageFileName) = 1
		}
		$$$TOE(sc,sc)

	} catch (ex) {
	  s sc = ex.AsStatus()
	}
	q result
}

ClassMethod CompareMessages(msgA As Ens.MessageBody, msgB As Ens.MessageBody, Output sc As %Status) As %Boolean
{
	#Dim ex As %Exception.AbstractException
	#Dim strA,strB As %String
	#Dim result As %Boolean
	
	s sc = $$$OK
	s result = 1
	try {	
	  if (msgA.%Extends("EnsLib.HL7.Message") && msgB.%Extends("EnsLib.HL7.Message")) {
		  s result = ..CompareHL7Messages(msgA,msgB)
	  }	
	  elseif (msgA.%Extends("%XML.Adaptor") && msgB.%Extends("%XML.Adaptor")) {
	   $$$TOE(sc,msgA.XMLExportToString(.strA))
	   $$$TOE(sc,msgA.XMLExportToString(.strB))
	   s result = strA=strB
	  }
	} catch(ex) {
	 s sc = ex.AsStatus()
	}	
	return result
}

ClassMethod CompareHL7Messages(message As EnsLib.HL7.Message, expected As EnsLib.HL7.Message, Output diffs As %String, Output sc As %Status, excludeMSH As %Boolean = 1, excludeEmptySegments As %Boolean = 1) As %Boolean
{
	
 #Dim ex As %Exception.AbstractException
 #Dim i As %Integer
 #Dim expectedSegment,messageSegment As EnsLib.HL7.Segment
 #Dim foundCount As %String 
 #Dim messageId,expectedId As %String
 #Dim result As %Boolean
 
 s sc = $$$OK
 s result = 1 
 
 try {  
  
  
  s foundCount = 0

  s messageId = message.GetSegmentAt(1).GetValueAt("10")
  s expectedId = expected.GetSegmentAt(1).GetValueAt("10")

  // set message ids to non-empty string to prevent reporting array to having index 1 empty
  if messageId="" s messageId = message.NewControlID()
  if expectedId="" s expectedId = expected.NewControlID()  

  for i=1:1:expected.SegCount {	

    s expectedSegment = expected.GetSegmentAt(i)
	s messageSegment = message.GetSegmentAt(i)	

	if excludeMSH && (expectedSegment.Name="MSH") {	  
	  s foundCount = foundCount+1
	} elseif excludeEmptySegments && ##class(ks.lib.hl7.Utils).IsEmptySegment(expectedSegment) {	  
	  s foundCount = foundCount+1
	} elseif $isobject(messageSegment) {
		s foundCount = foundCount+1
        s same = ..CompareHL7Segments(messageId,messageSegment,expectedId,expectedSegment,.diffs,.sc)	   
	    s result = result && same	   	   
	}
  }  

  if ((expected.SegCount-foundCount) '= 0)  {
	  s diffs(messageId,"message","SegCount") = message.SegCount
	  s diffs(expectedId,"expected","SegCount") = expected.SegCount
	  s result = 0
  }

 } catch(ex) {
	 s sc = ex.AsStatus()
 } 
 q result
}

ClassMethod CompareHL7Segments(messageId As %String, segment As EnsLib.HL7.Segment, expectedId As %String, expected As EnsLib.HL7.Segment, Output diffs As %String, Output sc As %Status) As %Boolean
{
	#Dim ex as %Exception.AbstractException
	#Dim result as %Boolean
	#Dim segmentString,expectedString as %String
	
	s sc = $$$OK
	try {
		s segmentString = segment.OutputToString(expected.Separators,,.sc)
		$$$TOE(sc,sc)		
		s expectedString = expected.OutputToString(,,.sc)
		$$$TOE(sc,sc)		
		s result =  (..StripSeparators(segment,segmentString) = ..StripSeparators(expected,expectedString))
		if ('result) {
			s diffs(messageId,segment.Name,"segment") = segmentString
			s diffs(expectedId,expected.Name,"expected") = expectedString
		}
	}
	catch (ex) {
	  s sc = ex.AsStatus()
	}
	q result
}

ClassMethod StripSeparators(seg As EnsLib.HL7.Segment, segmentString As %String) As %String
{
	#Dim result As %String

	s result = $replace(segmentString,seg.FS,"")
	s result = $replace(result,seg.SS,"")
	s result = $replace(result,seg.RS,"")
	s result = $replace(result,seg.CS,"")
	s result = $replace(result,$char(0),"")
	return result
}

ClassMethod CompareHL7Files(messageFileName As %String, expectedFileName As %String, docTypeCategory As %String, Output diffs As %String, Output sc As %Status) As %Boolean
{
	#Dim ex as %Exception.AbstractException

	#Dim result As %Boolean
	#Dim message,expected As EnsLib.HL7.Message
	
	s sc = $$$OK
	s result = 1

	try {
		if ##class(%File).Exists(messageFileName) {
			s message = ##class(EnsLib.HL7.Message).ImportFromFile(messageFileName)
		    d ##class(ks.lib.hl7.Utils).ResolveDocType(message,docTypeCategory)
		} else {
			throw ##class(%Exception.General).%New("file not found : "_messageFileName)			
		}
		if ##class(%File).Exists(expectedFileName) {
			s expected = ##class(EnsLib.HL7.Message).ImportFromFile(expectedFileName)
	 	    d ##class(ks.lib.hl7.Utils).ResolveDocType(expected,docTypeCategory)
		} else {
			throw ##class(%Exception.General).%New("file not found : "_expectedFileName)			
		}
		s result = ..CompareHL7Messages(message,expected,.diffs)
	}
	catch (ex) {
	  s sc = ex.AsStatus()
	}
	q result
}

ClassMethod CompareTextFiles(outputFileName As %String, expectedFileName As %String, Output sc As %Status, outputTerminator As %String = "", expectedTerminator As %String = "") As %Boolean
{
	#Dim ex as %Exception.AbstractException
	#Dim result As %Boolean
	#Dim outputStream,expectedStream as %Stream.FileCharacter
	#Dim outputLine,expectedLine as %String
	
	s sc = $$$OK
	s result = 1
	try {

		throw:'##class(%File).Exists(outputFileName) ##class(%Exception.General).%New("output file not found : "_outputFileName)
		throw:'##class(%File).Exists(expectedFileName) ##class(%Exception.General).%New("expected file not found : "_expectedFileName)

		s outputStream = ##class(%Stream.FileCharacter).%New()
		s outputStream.Filename = outputFileName
		s:($length(outputTerminator)>0) outputStream.LineTerminator = outputTerminator

		s expectedStream = ##class(%Stream.FileCharacter).%New()
		s expectedStream.Filename = expectedFileName		
		s:($length(expectedTerminator)>0) expectedStream.LineTerminator = expectedTerminator

		s result = 1
	    while 'outputStream.AtEnd || 'expectedStream.AtEnd {
			s outputLine = outputStream.ReadLine()
			s expectedLine = expectedStream.ReadLine()
			s result = (outputLine=expectedLine)
			quit:'result
		}
		s result = result && outputStream.AtEnd && expectedStream.AtEnd
	}
	catch (ex) {
	  s sc = ex.AsStatus()
	}
	return result
}

ClassMethod CompareHL7Directories(messageDir As %String, expectedDir As %String, fileSpec As %String = "*.hl7", docTypeCategory As %String, Output diffs As %String, Output sc As %Status) As %Boolean
{
	#Dim ex as %Exception.AbstractException

    #Dim rsExpected,rsMessage as %ResultSet

	#Dim expectedCnt,messageCnt,sameCnt As %Integer

    s sc = $$$OK

    s result = 1	
	try {
  	 if '##class(%File).DirectoryExists(messageDir) throw ##class(%Exception.General).%New("directory not found :"_messageDir)
 	 if '##class(%File).DirectoryExists(expectedDir) throw ##class(%Exception.General).%New("directory not found :"_expectedDir)

 	 s rsExpected = ##class(%ResultSet).%New("%Library.File:FileSet")
     $$$TOE(sc,rsExpected.Execute(expectedDir,fileSpec,"Name",0)) 

     s expectedCnt = 0
	 s sameCnt = 0
	 while rsExpected.Next() {	  
	  s expectedFile = rsExpected.Get("Name")	  
	  s messageFile = ##class(%File).NormalizeFilename(rsExpected.Get("ItemName"),messageDir)	  
	  if ##class(%File).Exists(messageFile) {
		s same = ..CompareHL7Files(messageFile,expectedFile,docTypeCategory,.diffs)
        s result = result && same
		s:same sameCnt = sameCnt + 1
	  } else {
		  // expected message was not found 
		  s diffs("file",rsExpected.Get("ItemName")) = "not found in "_messageDir
		  s result = 0
	  }
  	  s expectedCnt = expectedCnt + 1
     }
	 s diffs("compared","expectedCount") = expectedCnt
	 s diffs("compared","sameCount") = sameCnt
	 s diffs("compared","diffCount") = (expectedCnt-sameCnt)

 	 s rsMessage = ##class(%ResultSet).%New("%Library.File:FileSet")
     $$$TOE(sc,rsMessage.Execute(messageDir,fileSpec,"Name",0)) 
	 s messageCnt = 0
	 while rsMessage.Next() {	  
		 s expectedFile = ##class(%File).NormalizeFilename(rsMessage.Get("ItemName"),expectedDir)	  
		 if '##class(%File).Exists(expectedFile) {
			 s diffs("file",rsMessage.Get("ItemName")) = "not found in "_expectedDir
			 s result = 0
		 }
	     s messageCnt = messageCnt + 1
	 }
	 s diffs("compared","messageCount") = messageCnt
	 s result = result && (messageCnt = expectedCnt)

	}
	catch (ex) {
	  s sc = ex.AsStatus()
	}
	return result
}

ClassMethod CompareXMLDirectories(messageDir As %String, expectedDir As %String, fileSpec As %String = "*.xml", className As %String, namespace As %String = "", Output diffs As %String, Output sc As %Status) As %Boolean
{
	#Dim ex as %Exception.AbstractException

    #Dim rsExpected as %ResultSet

	#Dim cnt,sameCnt As %Integer

    s sc = $$$OK

    s result = 1	
	try {
  	 if '##class(%File).DirectoryExists(messageDir) throw ##class(%Exception.General).%New("directory not found :"_messageDir)
 	 if '##class(%File).DirectoryExists(expectedDir) throw ##class(%Exception.General).%New("directory not found :"_expectedDir)

 	 s rsExpected = ##class(%ResultSet).%New("%Library.File:FileSet")
     $$$TOE(sc,rsExpected.Execute(expectedDir,fileSpec,"Name",0)) 

     s cnt = 0
	 s sameCnt = 0
	 while rsExpected.Next() {	  
	  s expectedFile = rsExpected.Get("Name")	  
	  s messageFile = ##class(%File).NormalizeFilename(rsExpected.Get("ItemName"),messageDir)	  
	  if ##class(%File).Exists(messageFile) {
		s same = ..CompareMessageFiles(messageFile,expectedFile,className,namespace,.diffs,.sc)
        s result = result && same
		s:same sameCnt = sameCnt + 1
		s cnt = cnt + 1
	  }
     }
	 s diffs("compared","count") = cnt_" files compared"
	 s diffs("compared","same") = sameCnt_" files identical"
	 s diffs("compared","diff") = (cnt-sameCnt)_" files different"
	}
	catch (ex) {
	  s sc = ex.AsStatus()
	}
	return result
}

ClassMethod ZWriteToString() As %String
{
 #Dim result as %String
 #Dim i,lineCount as %Integer
 
 kill ^SPOOL($j)
 open 2:$j
 use 2
 zwrite
 s result=""
 s lineCount=$select($data(var):$za-1,1:$za-2)
 close 2
 for i=1:1:lineCount s result=result_^SPOOL($j,i)	
 return result
}

}
