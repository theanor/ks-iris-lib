Class ut.ks.lib.interop.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="ut.ks.lib.archive.Production" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description>Test production for interop configuration utilities</Description>
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="FileOperation" Category="" ClassName="EnsLib.File.PassthroughOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
</Production>
}

}
