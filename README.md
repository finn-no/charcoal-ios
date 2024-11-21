# **Deprecated! This repository is no longer maintained**

Old README for reference:


<p align="center"><img src="https://github.com/finn-no/FilterKit/blob/master/GitHub/Charcoal.png" width="100%" /></p>

[![CI Status](https://circleci.com/gh/finn-no/charcoal-ios.png?style=shield)](https://circleci.com/gh/finn-no/charcoal-ios)
[![Version](https://img.shields.io/cocoapods/v/Charcoal.svg?style=flat)](http://cocoadocs.org/docsets/Charcoal)
[![License](https://img.shields.io/cocoapods/l/Charcoal.svg?style=flat)](http://cocoadocs.org/docsets/Charcoal)
[![Platform](https://img.shields.io/cocoapods/p/Charcoal.svg?style=flat)](http://cocoadocs.org/docsets/Charcoal)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/Charcoal.svg?style=flat)](http://cocoadocs.org/docsets/Charcoal)
![Swift](https://img.shields.io/badge/%20in-swift%205.0-orange.svg)

## Description

**Charcoal** is a declarative library that simplifies the creation of modern filtering experiences. It allows you in a flexible way to represent complex filtering flows in just a few steps. When building Charcoal we have taken major steps to ensure every UI element is refined to provide a great experience to your users, taking in account things such as accessibility and customization.

At FINN, filtering is one of the key elements of our native apps and we believe we are not alone on this, this is why we have taken the time and effort to share our countless hours of iterations and redesigns to share with you what we believe is one of the best filtering experiences, say hi to **Charcoal**.

**Why Charcoal?**

_Charcoal_ /ˈtʃɑːkəʊl/: _a porous black solid, consisting of an amorphous form of carbon, obtained as a residue when wood, bone, or other organic matter is heated in the absence of air. Used among other things as an effective component of filtering._

## Features

- [x] Out-of-the-box implementations of various filters
- [x] Simple configuration and easy to use public API
- [x] All-in-one solution for handling of complex filtering flows
- [x] Beautiful design, UI animations and accessibility support
- [x] Haptic feedback

## Demo

<p align="center">
  <img src="/GitHub/demo.gif"/>
</p>

## Installation

### CocoaPods

**Charcoal** is available through [CocoaPods](http://cocoapods.org). To install
the core module of the framework, simply add the following line to your `Podfile`:

```ruby
pod "Charcoal", git: "https://github.com/finn-no/charcoal-ios"
```

You will also need to include the FinniversKit dependency in your Podfile.
```ruby
pod "FinniversKit", git: "https://github.com/finn-no/FinniversKit"
```

For using FINN-specific configuration in addition to core functionality:

```ruby
pod 'Charcoal/FINN', git: "https://github.com/finn-no/charcoal-ios"
```

### Swift Package Manager
#### Xcode
Add **Charcoal** to your project through Xcode by navigating to `File > Swift Packages > Add Package Dependency` and
specify `https://github.com/finn-no/charcoal-ios`.

#### Manual – `Package.swift`
Add this line to your `Package.swift`. We may not always update the version string below in this `README`, so make sure to
check the list of [available tags](https://github.com/finn-no/charcoal-ios/tags) and select the newest one.

```swift
.package(name: "Charcoal", url: "https://github.com/finn-no/charcoal-ios.git", from: "10.0.0")
```

Don't forget to add `Charcoal` as a dependency to your intended target!

## Usage

1. Setup

```swift
import Charcoal

let charcoalConfiguration = CustomImplementationOfCharcoalConfiguration()
Charcoal.setup(charcoalConfiguration)
```

2. Create filter container with a list of filters, for example:

```swift
let container = FilterContainer(
    rootFilters: [
        // Multi-level list filter
        Filter(title: "Area", key: "area", subfilters: [
            Filter(title: "Oslo", key: "area", value: "Oslo"),
            Filter(title: "Bergen", key: "area", value: "Bergen"),
        ]),
        // Range slider with number inputs
        Filter.range(
            title: "Price",
            key: "price",
            lowValueKey: "price_from",
            highValueKey: "price_to",
            config: RangeFilterConfiguration(
                minimumValue: 1000,
                maximumValue: 100000,
                valueKind: .incremented(1000),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: .currency(unit: "kr"),
                usesSmallNumberInputFont: false
            )
        ),
        // Map filter
        Filter.map(
            title: "Map",
            key: "map",
            latitudeKey: "latitude",
            longitudeKey: "longitude",
            radiusKey: "radius",
            locationKey: "location"
        )
    ],
    freeTextFilter: Filter.freeText(key: "query"),
    inlineFilter: Filter.inline(title: "", key: "inline", subfilters: inlineFilters),
    numberOfResults: 100
)
```

2. Create `CharcoalViewController`, set optional delegates and data sources for
handling selection changes, responding to user interactions with the map and free
text search filters, etc.:

```swift
let viewController = CharcoalViewController()
viewController.mapDataSource = mapDataSource
viewController.searchLocationDataSource = searchLocationDataSource
viewController.freeTextFilterDataSource = freeTextFilterService
viewController.freeTextFilterDelegate = freeTextFilterService
viewController.selectionDelegate = self
viewController.textEditingDelegate = self
```

3. Assign an instance of filter container to your view controller:

```swift
viewController.filterContainer = filterContainer
```

4. If needed, pre-select some of the filters by using a set of `URLQueryItem`'s,
where `name` of the query item is the filter key and `value` is the selected
filter value:

```swift
let selection = Set([
    URLQueryItem(name: "area", value: "Oslo"),
    URLQueryItem(name: "price_from", value: "10000")
])
viewController.set(selection: selection)
```

## Changelogs

This project has a `Gemfile` that specify some development dependencies, one of those is `pr_changelog` which is a tool that helps you to generate changelogs from the Git history of the repo. You install this by running `bundle install`.

To get the changes that have not been released yet just run:

```
$ pr_changelog
```

If you want to see what changes were released in the last version, run:

```
$ pr_changelog --last-release
```

You can always run the command with the `--help` flag when needed.

## Dependencies

Some of the UI elements in **Charcoal** are taken from [FinniversKit](https://github.com/finn-no/FinniversKit),
a framework which holds all the UI elements of the FINN iOS app.

## Creating a new release

### Setup
- Install dependencies listed in Gemfile with `bundle install` (dependencies will be installed in `./bundler`)
- Fastlane will use the GitHub API, so make sure to create a personal access token [here](https://github.com/settings/tokens) and place it within an environment variable called **`CHARCOAL_GITHUB_ACCESS_TOKEN`**.
  - When creating a token, you only need to give access to the scope `repo`.
  - There are multiple ways to make an environment variable, for example by using a `.env` file or adding it to `.bashrc`/`.bash_profile`). Don't forget to run `source .env` (for whichever file you set the environment variables in) if you don't want to restart your shell.
  - Run `bundle exec fastlane verify_environment_variable` to see if it is configured correctly.
- Run `bundle exec fastlane verify_ssh_to_github` to see if ssh to GitHub is working.

### Make release
- Run `bundle exec fastlane make_charcoal_version`. Follow instructions, you will be asked for confirmation before all remote changes.
- After the release has been created you can edit the description on GitHub by using the printed link.

## License

**Charcoal** is available under the MIT license. See the [LICENSE](https://github.com/finn-no/charcoal-ios/blob/master/LICENSE.md) file for more info.
