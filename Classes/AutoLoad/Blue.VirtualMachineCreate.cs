using System.Collections;
using System.Collections.Generic;

namespace Blue
{
  public class VirtualMachineCreate
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Type { get; set; }
        public string Location { get; set; }
        public Dictionary<string, string> Tags {get;set;}
        public VMProperties Properties { get; set; }
    }
}