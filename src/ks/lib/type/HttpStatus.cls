Class ks.lib.type.HttpStatus Extends %Integer
{

Parameter MINVAL = 100;

Parameter MAXVAL = 599;

ClassMethod IsOK(%val) As %Boolean
{
      q (%val >= 200) && (%val <= 299)
}

}
