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
Submit a new Beta Build to HockeyApp

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
