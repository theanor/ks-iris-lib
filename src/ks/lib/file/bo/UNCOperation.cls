/// Extends <class>EnsLib.File.PassthroughOperation</class>, adding optional semaphore file output and support for Windows shares (UNC paths),  using <class>ks.lib.file.ba.UNCOutboundAdapter</class>
Class ks.lib.file.bo.UNCOperation Extends (Commons, EnsLib.File.PassthroughOperation)
{

Parameter ADAPTER = "ks.lib.file.ba.UNCOutboundAdapter";

Property Adapter As ks.lib.file.ba.UNCOutboundAdapter;

}
