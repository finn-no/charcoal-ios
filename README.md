<p align="center"><img src="https://github.com/finn-no/FilterKit/blob/master/GitHub/Charcoal.png" width="100%" /></p>

<p align="center">
[![CI Status](https://circleci.com/gh/finn-no/charcoal-ios.png?style=shield)](https://circleci.com/gh/finn-no/charcoal-ios)
[![Version](https://img.shields.io/cocoapods/v/Charcoal.svg?style=flat)](http://cocoadocs.org/docsets/Charcoal)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Charcoal.svg?style=flat)](http://cocoadocs.org/docsets/Charcoal)
[![Platform](https://img.shields.io/cocoapods/p/Charcoal.svg?style=flat)](http://cocoadocs.org/docsets/Charcoal)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/Charcoal.svg?style=flat)](http://cocoadocs.org/docsets/Charcoal)
![Swift](https://img.shields.io/badge/%20in-swift%205.0-orange.svg)
</p>

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

**Making a new Demo release**
1. Update Demo/CHANGELOG.md
2. Update version for Demo target in Xcode
3. Run `sh Scripts/version.sh` to update build number
4. Run `fastlane` and follow instructions

## Installation

### CocoaPods

**Charcoal** is available through [CocoaPods](http://cocoapods.org). To install
the core module of the framework, simply add the following line to your `Podfile`:

```ruby
pod 'Charcoal'
```

For using FINN-specific configuration in addition to core functionality:

```ruby
pod 'Charcoal/FINN'
```

### Carthage

**Charcoal** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install it just write into your `Cartfile`:

```ruby
github "finn-no/charcoal-ios"
```

`FINNSetup.framework` contains FINN-specific configuration and `Charcoal.framework`
is suitable for building your custom implementation of filters.

## Usage

1. Create filter container with a list of filters, for example:

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
                unit: .currency,
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

## Dependencies

Some of the UI elements in **Charcoal** are taken from [FinniversKit](https://github.com/finn-no/FinniversKit),
a framework which holds all the UI elements of the FINN iOS app.

## License

**Charcoal** is available under the MIT license. See the [LICENSE](https://github.com/finn-no/charcoal-ios/blob/master/LICENSE.md) file for more info.
