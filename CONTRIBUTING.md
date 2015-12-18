## Contribution guidelines

### General
The Blue module was started because of all the bugs and the non-"PowerShell-ness" of Microsoft's own module for interacting with Azure.
Blue only supports Azure Resource Manager, and there's no plan to introduce support for Azure Service Manager.

### Basic building blocks
Blue consists of a common set of functions for authentication and keeping track of the current subscription.
There is also a common model for interacting with ARM's rest api, which should generally be used. This model allows each function to
simply specify the url to call, the method to use (get/put/post/delete) and optionally the expected type or array of types to return.
Use the *-ArmResourceGroup functions to get aquainted with how these work

### Function naming
For functions that are being exported use <Verb>-Arm<Name>, for example Get-ArmResourceGroup
For internal(helper) functions, use <Verb>-Internal<Name> 

### Stuff to remember
* Focus on pipeline-ability
* Focus on use case, not the api structure. For example, `Get-ArmResourceGroup -name "MyRg" | Get-ArmVm` should be a perfectly
acceptable way of listing VMs in a resource group
* Fail correctly: A function should generally not cause terminating errors, 
and a function should fail and return instead of failing and continuing. In general, make the function behave nicely.
* Support ShouldProcess so users can use common switch such as `-Confirm`, `-WhatIf`, etc. Do NOT implement these directly.

### Adding new functionality
In general, follow these steps to add new functionality
* Add the required classes to "\Classes". Classes in the "Autoload" subfolder will be loaded on module load
* Add the required functions, one function per file
* Add the required folder to the main psm1 file so that functions are dot-sourced at module load
* Add any necessary unit tests



