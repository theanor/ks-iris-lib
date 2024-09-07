Class ks.lib.type.DateTime Extends %RegisteredObject
{

Parameter XMLTIMEZONE = "IGNORE";

Parameter XSDTYPE = "dateTime";

ClassMethod Normalize(%val As %RawString) As DateTime [ ServerOnly = 1 ]
{
  return:($length(%val)=0) ""
  return $select(($extract(%val,*-$find($reverse(%val),".")+3,*) ? 1.3N):%val,1:%val_".000")
}

ClassMethod XSDToLogical(%val As %String) As DateTime
{
  return ..Normalize(##class(%TimeStamp).XSDToLogical(%val))
}

ClassMethod FromFormat(value As %String, format As %String) As DateTime
{
  return ##class(Ens.Util.Time).ConvertDateTime(value,format,"%q(1)")
}

ClassMethod ToFormat(value As DateTime, format As %String) As %String
{
  return ##class(Ens.Util.Time).ConvertDateTime(..Normalize(value),"%q(1)",format,,,1)
}

Method Format(fmt As %String) As %String
{
    q ##class(DateTime).ToFormat(%val,fmt)
}

Method AddDays(days As %Integer) As DateTime
{
   #Dim hl,dl As %String

   s hl = ##class(Ens.Util.Time).ConvertDateTime(%val,"%q(1)","%q(4)",,.sc,1)       
   s dl = $piece(hl,",",1)+days_","_$piece(hl,",",2)
   q ##class(Ens.Util.Time).ConvertDateTime(dl,"%q(4)","%q(1)")
}

Method AddSeconds(seconds As %Integer) As DateTime
{
   #Dim hl,tp,dl As %String
   #Dim dp,tps As %Integer

   s hl = ##class(Ens.Util.Time).ConvertDateTime(%val,"%q(1)","%q(4)",,.sc,1)       
   s dp = $piece(hl,",",1)
   s tp = $piece(hl,",",2)
   s tps = (86400*dp)+$piece(tp,".",1)+seconds
   s dl = (tps \ 86400)_","_(tps#86400)_"."_$piece(tp,".",2)      
   q ##class(Ens.Util.Time).ConvertDateTime(dl,"%q(4)","%q(1)")
}

ClassMethod Today() As DateTime
{
    q ##class(Ens.Util.Time).ConvertDateTime($zdateh($zdate($HOROLOG))_",0","%q(3)","%q(1)")
}

ClassMethod Now() As DateTime
{
    q ##class(Ens.Util.FunctionSet).CurrentDateTime("%q(1)")
}

Method Equals(other As DateTime) As %Boolean
{
  #Dim fmt As %String = "%Y%m%d%H%M%S%N"
  return ##class(DateTime).ToFormat(%val,fmt) = ##class(DateTime).ToFormat(other,fmt)
}

Method Before(other As DateTime) As %Boolean
{
  #Dim fmt As %String = "%Y%m%d%H%M%S%N"
  return ##class(DateTime).ToFormat(%val,fmt) < ##class(DateTime).ToFormat(other,fmt)
}

Method After(other As DateTime) As %Boolean
{
  #Dim fmt As %String = "%Y%m%d%H%M%S%N"
  return ##class(DateTime).ToFormat(%val,fmt) > ##class(DateTime).ToFormat(other,fmt)
}

ClassMethod SameDay(date As DateTime, other As DateTime) As %Boolean
{
  return ..ToFormat(..Normalize(date),"%Y%m%d")=..ToFormat(..Normalize(other),"%Y%m%d")
}

ClassMethod DaysBetween(from As DateTime, until As DateTime) As %Integer
{
  return $piece(..ToFormat(..Normalize(until),"%q(3)"),",",1)-$piece(..ToFormat(..Normalize(from),"%q(3)"),",",1)
}

ClassMethod SecondsBetween(from As DateTime, until As DateTime) As %Integer
{
  s u = ..ToFormat(..Normalize(until),"%q(3)")
  s f = ..ToFormat(..Normalize(from),"%q(3)")
  return (($piece(u,",",1)*86400)+$piece(u,",",2))-(($piece(f,",",1)*86400)+$piece(f,",",2))
}

}
