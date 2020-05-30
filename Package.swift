// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SemiModalViewController",
	platforms: [
		.iOS(.v8)
	],
    products: [
        .library(name: "SemiModalViewController", targets: ["SemiModalViewController"]),
    ],
    targets: [
        .target(
            name: "SemiModalViewController",
            path: "Source"
        )
    ]
)
