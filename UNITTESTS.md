## Running unit tests

### Interactive unit tests
These cover basic interactive authentication scenarios and require that the tester specifies a valid subscription when prompted
Any interactive unit tests should be tagged with "interactive" so that the CI job can skip these.

### Non-interactive unit tests
Non-interactive unit tests are run on each commit using Pester.
If anyone wants to run non-interactive unit tests locally, place a file called "LocalVars.config" in the module directory (this is already excluded by gitignore), 
and fill it with the follow json (replacing the values with correct ones):
```javascript
[
    {
        "Name":"logonaccountusername",
        "Value": "<validusername>"
    },
    {
        "Name":"logonaccountuserpassword",
        "Value": "<validpassword>"
    },
    {
        "Name":"subscriptionid",
        "Value": "<validsubscriptionid>"
    }
]
```

### Testing strategies
It is a goal for the project to have high test coverage. Also ensure that tests cover failure scenarios (testing that a function will hever throw exceptions if it shouldn't for instance)