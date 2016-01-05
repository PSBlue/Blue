using System.Collections;
using System.Collections.Generic;

namespace Blue
{
    public class AutomationAccount
    {
        public string Name { get; set; }
        public string Location { get; set; }
        public string id { get; set; }
        public string ResourceGroupName { get; set; }
        public string dscMetaConfiguration { get; set; }
        public string endpoint { get; set; }
        public string PrimaryKey { get; set; }
        public string SecondaryKey { get; set; }
        public Dictionary<string, string> Properties { get; set; }
    }
}