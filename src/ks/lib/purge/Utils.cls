/// purge utilities
Class ks.lib.purge.Utils
{

/// Purges all message bodies associated with sessionId and if purgeHeaders is set, purge headers too.
/// <b>purged</b> returns the total count of items successfully purged, and the count by class name in the first subscript
/// Stops and returns error status if any error occurs during purge.
ClassMethod PurgeSessionMessageBodies(sessionId As %Integer, Output purged As %Integer, purgeHeaders As %Boolean = 0, noLock As %Boolean = 1) As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim stmt as %SQL.Statement
  #Dim rs as %SQL.StatementResult
  
  s sc = $$$OK
  try {    
    s stmt = ##class(%SQL.Statement).%New()
    s rs = stmt.%ExecDirect(,"select"_$select(noLock:" %NOLOCK",1:"")_" ID as HeaderId,MessageBodyClassName as BodyClass,MessageBodyId as BodyId from Ens.MessageHeader where SessionId=?",sessionId)
    while rs.%Next() {
      if ($length(rs.BodyClass) > 1) && $$$ISOK($classmethod(rs.BodyClass,"%DeleteId",rs.BodyId)) {
        d $increment(purged)
        d $increment(purged(rs.BodyClass))
      }
      if purgeHeaders {
        $$$TOE(sc,##class(Ens.MessageHeader).%DeleteId(rs.HeaderId))
        d $increment(purged)
        d $increment(purged("Ens.MessageHeader"))     
      }
    }
  }
  catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

/// Purges all sessions originating from <b>sourceConfigName</b> in the current namespace interoperability production, 
/// keeping only the sessions that are less or <b>daysToKeep</b> day old, 
/// <b>purged</b> returns the total count of items successfully purged, and the count by class in the first subscript
/// Stops and returns error status if any error occurs during purge.
/// if <b>noDataMode</b> is 1 (default is 0), sets autocommit to false and no transaction modes, resulting in only kills being registered in journal (if journaling is enabled) and no data
/// !!! CAVEAT : use noDataMode=1 only if you really don't need to restore the data  from the journal. This is suitable only in special situations (e.g. numerous big messages to be purged)
ClassMethod PurgeSessions(sourceConfigName As Ens.DataType.ConfigName, Output purged As %String, daysToKeep As %Integer = 7, purgeHeaders As %Boolean = 0, noLock As %Boolean = 1, noDataMode As %Boolean = 0) As %Status
{
  #Dim sc as %Status
  #Dim ex as %Exception.AbstractException

  #Dim stmt as %SQL.Statement
  #Dim rs as %SQL.StatementResult
  #Dim dt As %String
  
  s sc = $$$OK
  if noDataMode { // set transaction mode and autocommit options
    s oldTm = $SYSTEM.OBJ.SetTransactionMode(0,.sc)    
    $$$TOE(sc,$SYSTEM.SQL.Util.SetOption("AUTOCOMMIT",0,.oldAc))
  }
  if $$$ISOK(sc) {
    try {
      s stmt = ##class(%SQL.Statement).%New()
      s dt = ##class(ks.lib.type.DateTime).ValuePlusDays(##class(ks.lib.type.DateTime).Now(),-daysToKeep)
      s rs = stmt.%ExecDirect(,"select "_$select(noLock:" %NOLOCK",1:"")_" SessionId,TimeCreated from Ens.MessageHeader where SourceConfigName=? and SessionId=ID and TimeCreated <= ?",sourceConfigName,dt)
      while rs.%Next() {
        $$$TOE(sc,..PurgeSessionMessageBodies(rs.SessionId,purgeHeaders,.purged,noLock))
      }
    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
  }
  if noDataMode { // restore transaction mode and autocommit options
    s oldTm = $SYSTEM.OBJ.SetTransactionMode(oldTm)    
    d $SYSTEM.SQL.Util.SetOption("AUTOCOMMIT",oldAc,.oldAc)
  }
  return sc
}

}
