using System;
using System.Collections;
using System.Collections.Generic;

namespace Blue
{
    public class AutomationRunbook
    {
        public AutomationRunbookProperties Properties { get; set; }
        public string Name { get; set; }
        public string Location { get; set; }
        public string id { get; set; }
        public string ResourceGroupName { get; set; }
        public string AutomationAccountName { get; set; }
        public string RunbookType
        {
            get
            {
                return Properties.runbookType;
            }
        }
        public string State
        {
            get
            {
                return Properties.state;
            }
        }
        public bool LogVerbose
        {
            get
            {
                return Properties.logVerbose;
            }
        }
        public bool LogProgress
        {
            get
            {
                return Properties.logProgress;
            }
        }
        public bool LogActivityTrace
        {
            get
            {
                return Properties.logActivityTrace;
            }
        }
        public DateTime CreationTime
        {
            get
            {
                return Properties.creationTime;
            }
        }
        public DateTime LastModifiedTime
        {
            get
            {
                return Properties.lastModifiedTime;
            }
        }
    }

    public class AutomationRunbookProperties
    {
        public string runbookType { get; set; }
        public string state { get; set; }
        public bool logVerbose { get; set; }
        public bool logProgress { get; set; }
        public bool logActivityTrace { get; set; }
        public DateTime creationTime { get; set; }
        public DateTime lastModifiedTime { get; set; }
    }
}