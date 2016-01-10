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
    
    public class WindowsConfiguration
    {
        public bool provisionVMAgent { get; set; }
        public bool enableAutomaticUpdates { get; set; }
    }

    public class OsProfile
    {
        public string ComputerName { get; set; }
        public string AdminUsername { get; set; }
        public string adminPassword { get; set; }
        public string customData { get; set; }
        public LinuxConfiguration LinuxConfiguration { get; set; }
        public WindowsConfiguration WindowsConfiguration { get; set; }
        public List<VmSecret> Secrets { get; set; }
    }

    public class VmSecret
    {
        public SourceVault SourceVault {get;set;}
        public string VaultCertificate {get;set;}
    }
    
    public class SourceVault
    {
        public string id {get;set;}
    }

    public class NetworkInterfaceReference
    {
        public string Id { get; set; }
    }

    public class NetworkProfile
    {
        public List<NetworkInterfaceReference> NetworkInterfaces { get; set; }
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

    public class VMProperties
    {
        public string VmId { get; set; }
        public HardwareProfile HardwareProfile { get; set; }
        public StorageProfile StorageProfile { get; set; }
        public OsProfile OsProfile { get; set; }
        public NetworkProfile NetworkProfile { get; set; }
        public DiagnosticsProfile DiagnosticsProfile { get; set; }
        public string ProvisioningState { get; set; }
    }

    public class VmResourceReference
    {
        public string Id { get; set; }
    }

    public class VirtualMachine
    {
        public string Name { get; set; }
        public string Location { get; set; }
        public VMProperties Properties { get; set; }
        public List<VmResourceReference> Resources { get; set; }
        public string Type { get; set; }
        public string Id { get; set; }
        public string VirtualMachineId { get; set; }
        public string PowerState {get;set;}
        public string ProvisioningState {get;set;}
        public VmInstanceView InstanceView {get;set;}
    }
    
    
    public class InstanceViewVmAgentStatus
    {
        public string code { get; set; }
        public string level { get; set; }
        public string displayStatus { get; set; }
        public string message { get; set; }
        public string time { get; set; }
    }

    public class InstanceViewVmAgent
    {
        public string vmAgentVersion { get; set; }
        public List<InstanceViewVmAgentStatus> statuses { get; set; }
    }

    public class InstanceViewDiskStatus
    {
        public string code { get; set; }
        public string level { get; set; }
        public string displayStatus { get; set; }
        public string time { get; set; }
    }

    public class InstanceViewDisk
    {
        public string name { get; set; }
        public List<InstanceViewDiskStatus> statuses { get; set; }
    }

    public class InstanceViewStatuses
    {
        public string code { get; set; }
        public string level { get; set; }
        public string displayStatus { get; set; }
        public string time { get; set; }
    }

    public class VmInstanceView
    {
        public InstanceViewVmAgent VmAgent { get; set; }
        public List<InstanceViewDisk> Disks { get; set; }
        public List<InstanceViewStatuses> statuses { get; set; }
    }


}

