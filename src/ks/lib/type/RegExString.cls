/// A string datatype definition which extends <class>%Library.String</class> with additional regex pattern validation. <br />
Class ks.lib.type.RegExString Extends %String
{

/// Set PATTERN to empty and final, as it is not relevant on
/// this type, but is inherited from <class>%Library.String</class>
Parameter PATTERN [ Final ];

/// Set VALUELIST to empty and final, as it is not relevant on
/// this type, but is inherited from <class>%Library.String</class>
Parameter VALUELIST [ Final ];

/// Set DISPLAYLIST to empty and final, as it is not relevant on
/// this type, but is inherited from <class>%Library.String</class>
Parameter DISPLAYLIST [ Final ];

/// Set a valid regex pattern for value validation
Parameter REGEX As STRING;

/// The XMLPATTERN to regex by default. Can be overridden.
Parameter XMLPATTERN = {..#REGEX};

ClassMethod IsValid(%val As %Library.RawString) As %Status [ ServerOnly = 0 ]
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException
    
    try {
         $$$TOE(sc,##class(%String).IsValid(%val))
         if (..#REGEX '= "") {
            if '$MATCH(%val, ..#REGEX) {
                s sc = $$$ERROR($$$DTPattern, %val, ..#REGEX)
            }
         }       
    }
    catch (ex) {
      s sc = ex.AsStatus()
    }
    q sc
}

}
