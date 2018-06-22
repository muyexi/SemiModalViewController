
[![CocoaPods](https://img.shields.io/cocoapods/v/SemiModalViewController.svg?maxAge=2592000)](muyexi)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/muyexi/SemiModalViewController/blob/master/LICENSE)

Swift Port of [KNSemiModalViewController](https://github.com/kentnguyen/KNSemiModalViewController), present view / view controller as bottom-half modal.

<p align="center">
  <img src="Demo.gif" width="30%">
</p>

## Installation

### CocoaPods

```ruby
pod 'SemiModalViewController'
```

## Usage

Present a view controller:

```swift
let options = [
    SemiModalOption.pushParentBack: true
]

let controller = UIViewController()

controller.view.height = 200
controller.view.backgroundColor = UIColor.redColor()

presentSemiViewController(controller, options: options, completion: {
    print("Completed!")
}, dismissBlock: {
    print("Dismissed!")
})
```

Or view:

```swift
let view = UIView(frame: UIScreen.mainScreen().bounds)
view.height = 300
view.backgroundColor = UIColor.redColor()

presentSemiView(view, options: options) {
    print("Completed!")
}
```

Default options:

```swift
SemiModalOption.traverseParentHierarchy : true,
SemiModalOption.pushParentBack          : false,
SemiModalOption.animationDuration       : 0.5,
SemiModalOption.parentAlpha             : 0.5,
SemiModalOption.parentScale             : 0.8,
SemiModalOption.shadowOpacity           : 0.5,
SemiModalOption.transitionStyle         : .slideUp,
SemiModalOption.disableCancel           : true
```

## License

SemiModalViewController is released under the MIT license. See LICENSE for details.
