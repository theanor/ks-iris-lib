Class ks.lib.record.PropertyParameters
{

/// for delimited records : column index, first column index is 1
/// for fixed records : field starting column, first column is 1
Parameter COL;

/// Column name
Parameter COLNAME;

/// length of column used for fixed length record and padding
Parameter LEN;

/// padding : "left" or "right"
Parameter PADDING;

/// padding character
Parameter FILLER;

/// set this to 1 to ignore property
Parameter RECORDEXCLUDE;

/// correlation value
Parameter CORRELATION;

}
