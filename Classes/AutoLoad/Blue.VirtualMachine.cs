using System.Collections;
using System.Collections.Generic;

namespace Blue
{
    public class HardwareProfile
    {
        public string VmSize { get; set; }
    }

    public class ImageReference
    {
        public string Publisher { get; set; }
        public string Offer { get; set; }
        public string Sku { get; set; }
        public string Version { get; set; }
    }

    public class Vhd
    {
        public string Uri { get; set; }
    }

    public class OsDisk
    {
        public string OsType { get; set; }
        public string Name { get; set; }
        public string CreateOption { get; set; }
        public Vhd Vhd { get; set; }
        public string Caching { get; set; }
    }

    public class StorageProfile
    {
        public ImageReference ImageReference { get; set; }
        public OsDisk OsDisk { get; set; }
        public List<object> DataDisks { get; set; }
    }

    public class LinuxConfiguration
    {
        public bool DisablePasswordAuthentication { get; set; }
    }

    public class OsProfile
    {
        public string ComputerName { get; set; }
        public string AdminUsername { get; set; }
        public LinuxConfiguration LinuxConfiguration { get; set; }
        public List<object> Secrets { get; set; }
    }

    public class NetworkInterface
    {
        public string Id { get; set; }
    }

    public class NetworkProfile
    {
        public List<NetworkInterface> NetworkInterfaces { get; set; }
    }

    public class BootDiagnostics
    {
        public bool Enabled { get; set; }
        public string StorageUri { get; set; }
    }

    public class DiagnosticsProfile
    {
        public BootDiagnostics BootDiagnostics { get; set; }
    }

    public class Properties
    {
        public string VmId { get; set; }
        public HardwareProfile HardwareProfile { get; set; }
        public StorageProfile StorageProfile { get; set; }
        public OsProfile SsProfile { get; set; }
        public NetworkProfile NetworkProfile { get; set; }
        public DiagnosticsProfile DiagnosticsProfile { get; set; }
        public string ProvisioningState { get; set; }
    }

    public class VmResource
    {
        public string Id { get; set; }
    }

    public class VirtualMachine
    {
        public string Name { get; set; }
        public string Location { get; set; }
        public Properties Properties { get; set; }
        public List<VmResource> Resources { get; set; }
        public string Type { get; set; }
        public string Id { get; set; }
    }

}

