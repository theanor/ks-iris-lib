Class ut.ks.lib.archive.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="test.ut.ks.lib.archive.Production" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description>Test production for archive operations</Description>
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="HL7Operation" Category="" ClassName="ks.lib.archive.bo.HL7Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="RootDirectory"></Setting>
  </Item>
  <Item Name="XMLOperation" Category="" ClassName="ks.lib.archive.bo.XMLOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="RootDirectory"></Setting>
  </Item>


</Production>
}

}
