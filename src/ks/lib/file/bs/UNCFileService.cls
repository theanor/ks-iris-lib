/// Windows UNC path file service, using <class>ks.lib.file.ba.UNCInboundAdapter</class>
Class ks.lib.file.bs.UNCFileService Extends EnsLib.File.PassthroughService
{

Parameter ADAPTER = "ks.lib.file.ba.UNCInboundAdapter";

Property Adapter As ks.lib.file.ba.UNCInboundAdapter;

}
