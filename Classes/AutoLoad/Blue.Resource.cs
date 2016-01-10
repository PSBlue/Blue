using System.Collections;
using System.Collections.Generic;

namespace Blue
{
    public class Resource
    {
        public string Name { get; set; }
		public string Type { get; set; }
        public string Location { get; set;}
        public Dictionary<string, string> Tags {get;set;}
        public string Id { get; set; }
        public string ResourceId { get; set; }
    }
}


