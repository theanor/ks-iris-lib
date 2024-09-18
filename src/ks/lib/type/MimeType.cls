Class ks.lib.type.MimeType Extends %String
{

Parameter MAXLEN = 256;

Parameter TYPES = "^ks.lib.type.MimeType";

ClassMethod ToFileExtension(value As MimeType) As FileExtension
{
    return $get(@..#TYPES@("type",..Normalize(value)))
}

ClassMethod FromFileExtension(value As FileExtension) As MimeType
{
    return $get(@..#TYPES@("ext",##class(FileExtension).Normalize(value)))
}

ClassMethod FromFileName(fileName As %String) As MimeType
{
	q ..FromFileExtension(##class(FileExtension).FromFileName(fileName))
}

ClassMethod Equals(value As %String, other As %String, ignoreParameters As %Boolean = 1) As %Boolean
{
 q $select(ignoreParameters:..StripParameters(value)=..StripParameters(other),1:..Normalize(value)=..Normalize(other))
}

ClassMethod StripParameters(value As MimeType) As MimeType
{
	return $zcvt($piece(value,";",1),"L")
}

ClassMethod ParseParameters(value As MimeType, Output parameters) As %Status
{
	#Dim tokens = $listfromstring(value,";")
	#Dim ptr
	#Dim found as %Boolean
	#Dim token,name,val as %String
	
	s ptr = 0
	s found = $listnext(tokens,ptr,token)
	s parameters = 0
	if found {
		while $listnext(tokens,ptr,token) {
			s parameters = $increment(parameters)
			s name = $zconvert($zstrip($piece(token,"=",1),"<>W"),"L")
			s val = $replace($zstrip($piece(token,"=",2),"<>W"),"""","")
			s parameters(name)=val			
		}
	}
	return $$$OK
}

ClassMethod IsText(value As MimeType) As %Boolean
{
	return ..Equals(value,"text/plain",1)
}

ClassMethod TextCharset(value As MimeType) As %String
{
	
	#Dim result as %String = ""
	#Dim sc as %Status
	#Dim params
    if ..IsText(value) {
	  s sc = ..ParseParameters(value,.params)
      s:$$$ISOK(sc) result = $zconvert($get(params("charset")),"U")
	}
	return result
}

ClassMethod TextTranslateTable(value As MimeType) As %String
{
	s cs = ..TextCharset(value)	
	return $select(cs["1252":"CP1252",cs["8859":"CP1252",cs="UTF-8":"UTF8",cs="UTF8":"UTF8",cs="UTF-16":"UTF16",cs="UTF16":"UTF16",1:cs)
}

ClassMethod Normalize(%val) As %String
{
	return $zstrip($zconvert(%val,"L"),"<>W")
}

ClassMethod LoadTypes() As %Status [ CodeMode = objectgenerator ]
{
    #Dim sc as %Status
    #Dim ex as %Exception.AbstractException

    #Dim xdata as %Dictionary.XDataDefinition
    #Dim types as %DynamicArray
    #Dim i as %Iterator.Array
    #Dim k as %String
    #Dim type as %DynamicObject

    s sc = $$$OK
    try {        
        s xdata=  %class.XDatas.GetAt(1)
    	s types = {}.%FromJSON(xdata.Data)
        //s gref = ..#TYPES
        s gref = "^"_%class.Name
        if $isobject(types) {
            s i = types.%GetIterator()
            while i.%GetNext(.k,.type) {
                s @gref@("type",type.type) = type.ext
                s @gref@("ext",type.ext) = type.type
            }
        }
    } catch (ex) {
      s sc = ex.AsStatus()
    }
    return sc
}

XData Types [ MimeType = application/json ]
{
[
    {
       "type" : "text/css",
       "ext" : "css"
    },
	{
		"ext": "html",
		"type": "text/html"
	},
	{
		"ext": "js",
		"type": "application/javascript"
	},
	{
		"ext": "txt",
		"type": "text/plain"
	},
	{
		"ext": "xml",
		"type": "application/xml"
	},
	{
		"ext": "jpeg",
		"type": "image/jpeg"
	},
	{
		"ext": "gif",
		"type": "image/gif"
	},
	{
		"ext": "png",
		"type": "image/png"
	},
	{
		"ext": "bmp",
		"type": "image/bmp"
	},
	{
		"ext": "svg",
		"type": "image/svg+xml"
	},
	{
		"ext": "pdf",
		"type": "application/pdf"
	},
	{
		"ext": "doc",
		"type": "application/msword"
	},
	{
		"ext": "docx",
		"type": "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
	},
	{
		"ext": "tiff",
		"type": "image/tiff"
	},
	{
		"ext": "zip",
		"type": "application/zip"
	},
	{
		"ext": "rtf",
		"type": "text/rtf"
	},
	{
		"ext": "avi",
		"type": "video/x-msvideo"
	},
	{
		"ext": "rep",
		"type": "application/x-medidoc-report"
	},
	{
		"ext": "h1",
		"type": "application/x-h1-report"
	}
]
}

}
