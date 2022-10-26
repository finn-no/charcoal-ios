// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Charcoal",
    defaultLocalization: "nb",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Charcoal",
            targets: ["Charcoal"]
        ),
    ],
    dependencies: [
        .package(name: "FinniversKit", url: "https://github.com/finn-no/FinniversKit.git", from: "93.10.0")
    ],
    targets: [
        .target(
            name: "Charcoal",
            dependencies: [
                "FinniversKit"
            ],
            path: "Sources/Charcoal",
            exclude: ["Info.plist"],
            resources: [
                .process("Sources/Charcoal/Resources")
            ]
        ),
        .testTarget(
            name: "CharcoalTests",
            dependencies: ["Charcoal"],
            path: "UnitTests/Charcoal"
        ),
    ]
)
