Class ut.ks.lib.interop.TestOperation Extends Ens.BusinessOperation
{

Method OnMessage(request As Ens.StringRequest, Output response As Ens.StringResponse) As %Status
{
    $$$TRACE("received message !")
    s response = ##class(Ens.StringResponse).%New(request.StringValue)
    return $$$OK
}

}
