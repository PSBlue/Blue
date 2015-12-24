using System.Collections;
using System.Collections.Generic;

namespace blue
{
    public class AddressSpace
    {
        public List<string> AddressPrefixes { get; set; }
    }

    public class DhcpOptions
    {
        public List<string> DnsServers { get; set; }
    }

    public class IpConfigurationReference
    {
        public string id { get; set; }
    }

    public class SubnetProperties
    {
        public string ProvisioningState { get; set; }
        public string AddressPrefix { get; set; }
        public List<IpConfigurationReference> IpConfigurations { get; set; }
    }

    public class Subnet
    {
        public string Name { get; set; }
        public string Id { get; set; }
        public string Etag { get; set; }
        public SubnetProperties Properties { get; set; }
    }

    public class Properties
    {
        public string ProvisioningState { get; set; }
        public string ResourceGuid { get; set; }
        public AddressSpace AddressSpace { get; set; }
        public DhcpOptions DhcpOptions { get; set; }
        public List<Subnet> Subnets { get; set; }
    }

    public class VirtualNetwork
    {
        public string Name { get; set; }
        public string Etag { get; set; }
        public string Type { get; set; }
        public string Location { get; set; }
        public Dictionary<string, string> Tags {get;set;}
        public Properties Properties { get; set; }
        public string Id { get; set; }
        public string VirtualNetworkId { get; set; }
    }
}