Include Ensemble

Class ks.lib.file.bo.Commons Extends %RegisteredObject [ Abstract ]
{

Parameter SETTINGS = "Filename:Basic,SemaphoreSpec,SemaphoreContent,SemaphoreLine";

Property Filename As %String(MAXLEN = 1000, MINLEN = 1) [ InitialExpression = "%f_%Q%!+(_a)", Required ];

Property Adapter As EnsLib.File.OutboundAdapter;

/// Semaphore file name specification. If this is empty, no semaphore file is generated
Property SemaphoreSpec As %String(MAXLEN = 400) [ InitialExpression = "*.OK" ];

/// String for semaphore file content (may be empty)
Property SemaphoreContent As %String(MAXLEN = 400);

/// If this is true, the semaphore content will be followed by platform line terminator(s)
Property SemaphoreLine As %Boolean [ InitialExpression = 0 ];

Method PutSemaphoreFile(fileName As %String) As %Status [ Private ]
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException

    #Dim semaphoreFileName As %String;
    #Dim semaphoreStream As %Stream.FileCharacter
    
    try {
        if (..SemaphoreSpec '= "") {
          $$$TRACE("file name : "_fileName)
          s semaphoreFileName = ##class(Ens.Util.File).GenerateSemaphoreFilename(fileName,..SemaphoreSpec,.sc)        
          s semaphoreStream = ##class(%Stream.TmpCharacter).%New()
          $$$TOE(sc,sc)
          $$$TRACE("semaphore name : "_semaphoreFileName)
          if ..SemaphoreLine {
            $$$TOE(sc,semaphoreStream.WriteLine(..SemaphoreContent))        
          }
          $$$TOE(sc,..Adapter.PutStream(semaphoreFileName,semaphoreStream))
        }
    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
    q sc
}

}
