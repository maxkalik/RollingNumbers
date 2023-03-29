# RollingNumbers

[![Version](https://img.shields.io/cocoapods/v/RollingNumbers.svg?style=flat)](https://cocoapods.org/pods/RollingNumbers)
[![License](https://img.shields.io/cocoapods/l/RollingNumbers.svg?style=flat)](https://cocoapods.org/pods/RollingNumbers)
[![Platform](https://img.shields.io/cocoapods/p/RollingNumbers.svg?style=flat)](https://cocoapods.org/pods/RollingNumbers)

RollingNumbers is a lightweight UIView for getting smooth rolling animation between numbers implemented using only CALayer. 

![WeahterLogger App Icon](RollingNumbersExample.gif)

In [Triumph Arcade](https://github.com/triumpharcade) building [Triumph SDK](https://github.com/triumpharcade/triumph-sdk-ios) for game developers. I had a task to create Rolling Numbers animation for a balance component. Sometimes we cannot afford to use third-party libraries, so I decided to make my own solution using only `CALayers` in purpose to avoid performance issues.

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

## Configuration

```swift

var rollingNumbersView = {
    // Initialize Rolling Numbers view with initial number value
    let view = RollingNumbersView(number: 1234.56)
    
    // Configure animation type
    view.animationType = .onlyChangedDigits
    
    // Rolling direction will scroll only up
    view.rollingDirection = .up
    
    // Spacing between numbers
    view.characterSpacing = 1
    
    // Text color
    view.textColor = .black
    
    // Alignment within UIView
    view.alignment = .left
    
    // UIFont
    view.font = .systemFont(ofSize: 48, weight: .medium)
    
    return view
}()

```

### Animation Type

| Type                         | Description                                     |
| ---------------------------- | ----------------------------------------------- |
| `allNumbers`                 | All numbers roll if even only one number change |
| `onlyChangedNumbers`         | Only changed numbers roll                       |
| `allAfterFirstChangedNumber` | All numbers roll after first changed number     |
| `noAnimation`                | Numbers change without animation                |

### Animation Configuration

```swift
rollingNumbersView.animationConfiguration = RollingNumbersView.AnimationConfiguration(
    duration: 3,
    speed: 0.3,
    damping: 17,
    initialVelocity: 1
)
```

### Number Formatter

```swift
let formatter = NumberFormatter()
formatter.numberStyle = .currency
formatter.usesGroupingSeparator = true
formatter.locale = Locale(identifier: "en_US")
formatter.maximumFractionDigits = 2
formatter.minimumFractionDigits = 0
rollingNumbersView.formatter = formatter
```

## Contributing

Be welcome to contribute to this project!

## License

This project was released under the [MIT]() license.

## Author

Max Kalik, maxkalik@gmail.com
