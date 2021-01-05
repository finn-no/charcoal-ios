fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios beta_setup
```
fastlane ios beta_setup
```
Set up beta certificates
### ios beta_create
```
fastlane ios beta_create
```
Create beta certificates
### ios clean
```
fastlane ios clean
```
Cleans any fastlane build artifacts
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to AppCenter
### ios make_charcoal_version
```
fastlane ios make_charcoal_version
```
Create a new Charcoal version
### ios verify_ssh_to_github
```
fastlane ios verify_ssh_to_github
```
Attempt to connect to github.com with ssh
### ios verify_environment_variable
```
fastlane ios verify_environment_variable
```
Verify that environment variable exists

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
