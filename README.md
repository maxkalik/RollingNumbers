# RollingNumbers

[![Version](https://img.shields.io/cocoapods/v/RollingNumbers.svg?style=flat)](https://cocoapods.org/pods/RollingNumbers)
[![License](https://img.shields.io/cocoapods/l/RollingNumbers.svg?style=flat)](https://cocoapods.org/pods/RollingNumbers)
[![Platform](https://img.shields.io/cocoapods/p/RollingNumbers.svg?style=flat)](https://cocoapods.org/pods/RollingNumbers)

![WeahterLogger App Icon](RollingNumbersExample.gif)

## Requirements

- iOS 11.0+
- Swift 5.0+

## Instalation

### Cocoapod

RollingNumbers is available through [CocoaPods](https://cocoapods.org/):

```ruby
pod 'RollingNumbers'
```

### Swift Package Manager

```
https://github.com/maxkalik/RollingNumbers.git
```

## Usage

Initialize a RollingNumbersView.

```swift
let view = RollingNumbersView()
```

Set number with animation

```swift
rollingNumbersView.setNumberWithAnimation(1234.56)
```

Set number without animation

```swift
rollingNumbersView.setNumber(1234.56)
```
