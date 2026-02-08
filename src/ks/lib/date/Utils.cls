Class ks.lib.date.Utils Extends Ens.Rule.FunctionSet
{

/// default working hours : [08:00:00,17:00:00[ from Monday to Friday
Parameter DEFAULTWORKINGHOURSSPEC = "STOP:WEEK-*-01T17:00:00,START:WEEK-*-01T08:00:00,STOP:WEEK-*-02T17:00:00,START:WEEK-*-02T08:00:00,STOP:WEEK-*-03T17:00:00,START:WEEK-*-03T08:00:00,STOP:WEEK-*-04T17:00:00,START:WEEK-*-04T08:00:00,STOP:WEEK-*-05T17:00:00,START:WEEK-*-05T08:00:00";

/// default country code, override this to force it 
Parameter DEFAULTCOUNTRYCODE = {$zconvert(##class(%SYS.NLS.Locale).%New().CountryAbbr,"L")};

/// returns easter date for <b>year</b> in <b>fmt</b> format (defaults to ISO 8601 date)
ClassMethod EasterDate(year As %Integer, fmt As %String = "%q(2)") As %String
{
  #Dim n,u,c,s,t,p,q,e,b,d,L,h,m,j As %Integer

  return:year<1583 ""

  s n = year # 19
  s c = year \ 100
  s u = year # 100
  s s = c \ 4
  s t = c # 4
  s p = (c+8) \ 25
  s q = (c-p+1) \ 3
  s e = ((19*n)+c-s-q+15) # 30
  s b = u \ 4
  s d = u # 4
  s L = ((2*t)+(2*b)-e-d+32) # 7
  s h = (n+(11*e)+(22*L)) \ 451
  s m = (e+L-(7*h)+114) \ 31
  s j = (e+L-(7*h)+114) # 31
  s sj = j + 1
  s:$length(sj)=1 sj = "0"_sj
  return ##class(Ens.Util.Time).ConvertDateTime(year_"0"_m_sj,"%Y%m%d",fmt)
}

/// returns true if <b>dateTime</b> is on Belgium (legal) holiday 
ClassMethod IsBelgiumHoliday(dateTime As %DateTime) As %Boolean
{
  #Dim fmt As %String = "%q(2)"
  #Dim y,m,d As %Integer
  #Dim h,easterSunday As %Date


  s y=##class(Ens.Util.Time).ConvertDateTime(dateTime,fmt,"%Y",,,1)+0
  s m=##class(Ens.Util.Time).ConvertDateTime(dateTime,fmt,"%m",,,1)+0
  s d=##class(Ens.Util.Time).ConvertDateTime(dateTime,fmt,"%d",,,1)+0
  return:(m=1)&&(d=1) 1
  return:(m=5)&&(d=1) 1
  return:(m=7)&&(d=21) 1
  return:(m=8)&&(d=15) 1
  return:(m=11)&&(d=1) 1
  return:(m=11)&&(d=11) 1
  return:(m=12)&&(d=25) 1
  
  s h = ##class(Ens.Util.Time).ConvertDateTime(dateTime,fmt,"%q(3)",,,1)+0
  s easterSunday = ..EasterDate(y,"%q(3)")+0
  return:(h=easterSunday) 1
  return:(h=(easterSunday+1)) 1
  return:(h=(easterSunday+39)) 1
  return:(h=(easterSunday+49)) 1
  return:(h=(easterSunday+50)) 1

  return 0
}

/// returns true if <b>dateTime</b> (current date time if not specified) is on Saturday or Sunday
ClassMethod IsWeekend(dateTime As %DateTime = {##class(Ens.Util.FunctionSet).CurrentDateTime()}) As %Boolean
{
  #Dim fmt As %String = "%q(2)"
  #Dim wd As %Integer
  
  s wd=##class(Ens.Util.Time).ConvertDateTime(dateTime,fmt,"%u",,,1)+0
  return $case(wd,6:1,7:1,:0)
}

/// supports only Belgium (country='be', default value) for now
ClassMethod IsHoliday(dateTime As %DateTime = {##class(Ens.Util.FunctionSet).CurrentDateTime()}, country As %String = {..#DEFAULTCOUNTRYCODE}) As %Boolean
{
  return $case(country,"be":..IsBelgiumHoliday(dateTime),:0)
}

/// returns true if <b>dateTime</b> (defaults to current date time) date is not a holiday and time is within <b>spec</b> working hours schedule spec
ClassMethod IsWorkingHours(dateTime As %DateTime = {##class(Ens.Util.FunctionSet).CurrentDateTime()}, country As %String = {..#DEFAULTCOUNTRYCODE}, spec As %String = {..#DEFAULTWORKINGHOURSSPEC}) As %Boolean
{
  s dateTime = ##class(Ens.Util.Time).ConvertDateTime(dateTime,"%Y-%m-%d %H:%M:%S","%q(1)",,,1)
  return '..IsHoliday(dateTime,country) && ##class(Ens.Util.FunctionSet).Schedule(spec,dateTime)
}

}
