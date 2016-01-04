using System;
using System.Collections;
using System.Collections.Generic;

namespace Blue
{
    public class AutomationDscNode
    {
        public string Name { get; set; }
        public string id { get; set; }
        public DateTime lastSeen { get; set; }
        public DateTime registrationTime { get; set; }
        public string ip { get; set; }
        public string nodeId { get; set; }
        public string status { get; set; }
        public string AutomationAccountName { get; set; }
        public string ResourceGroupName { get; set; }
        public Dictionary<string, string> nodeConfiguration { get; set; }
    }
}