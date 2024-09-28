/// stream utilities
Class ks.lib.stream.Utils Extends %RegisteredObject
{

/// translate all occurences in <b>binStream</b> of any character in <b>badchars</b> into corresponding character in <b>goodchars</b>
ClassMethod ReplaceString(binStream As %Stream.Object, Output charStream As %Stream.GlobalCharacter, badstr As %String, goodstr As %String) As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException
  
  s:'$d(charStream) charStream = ##class(%Stream.TmpCharacter).%New()

  try {
    while 'binStream.AtEnd {    
      $$$TOE(sc,charStream.Write($change(binStream.Read(16384),badstr,goodstr))) 
    }
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  q sc
}

/// encode stream data into encoded using bufferSize (due the implementation of $system.Encryption.Base64Encode, this must be a multiple of 57)
ClassMethod Base64Encode(stream As %Stream.Object, Output encoded As %Stream.Object, bufferSize As %Integer = 5700) As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim len As %Integer
  
  s sc = $$$OK
  try {
    throw:((bufferSize#57)'=0) ##class(%Exception.General).%New("buffer size must be a multiple of 57")
    $$$TOE(sc,stream.Rewind())
    s:'$d(encoded) encoded = ##class(%Stream.TmpCharacter).%New()
    s len=bufferSize
    while 'stream.AtEnd {
      $$$TOE(sc,encoded.Write($system.Encryption.Base64Encode(stream.Read(.len),1)))
      s len = bufferSize
    }
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

}
