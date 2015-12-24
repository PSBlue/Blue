using System.Collections;
using System.Collections.Generic;

namespace Blue
{
    public class PublicIPAddressReference
    {
        public string id { get; set; }
    }

    public class SubnetReference
    {
        public string id { get; set; }
    }

    public class IpConfigurationProperties
    {
        public string provisioningState { get; set; }
        public string privateIPAddress { get; set; }
        public string privateIPAllocationMethod { get; set; }
        public PublicIPAddressReference publicIPAddress { get; set; }
        public SubnetReference subnet { get; set; }
    }

    public class IpConfiguration
    {
        public string name { get; set; }
        public string id { get; set; }
        public string etag { get; set; }
        public IpConfigurationProperties properties { get; set; }
    }

    public class DnsSettings
    {
        public List<object> dnsServers { get; set; }
        public List<object> appliedDnsServers { get; set; }
    }

    public class NetworkSecurityGroupReference
    {
        public string id { get; set; }
    }

    public class VirtualMachineReference
    {
        public string id { get; set; }
    }

    public class NetworkInterfaceProperties
    {
        public string ProvisioningState { get; set; }
        public string ResourceGuid { get; set; }
        public List<IpConfiguration> IpConfigurations { get; set; }
        public DnsSettings DnsSettings { get; set; }
        public bool EnableIPForwarding { get; set; }
        public NetworkSecurityGroupReference NetworkSecurityGroup { get; set; }
        public VirtualMachineReference VirtualMachine { get; set; }
    }

    public class NetworkInterface
    {
        public string Name { get; set; }
        public string Id { get; set; }
        public string Etag { get; set; }
        public string Type { get; set; }
        public string Location { get; set; }
        public NetworkInterfaceProperties Properties { get; set; }
    }    
}
