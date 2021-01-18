// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Charcoal",
    defaultLocalization: "nb",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Charcoal",
            targets: ["Charcoal"]
        ),
        .library(
            name: "Charcoal/FINNSetup",
            targets: ["FINNSetup"]
        ),
    ],
    dependencies: [
        .package(name: "FinniversKit", url: "https://github.com/finn-no/FinniversKit.git", from: "71.0.0"),
        .package(name: "AppCenter", url: "https://github.com/microsoft/appcenter-sdk-apple.git", .upToNextMinor(from: "4.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Charcoal",
            dependencies: [
                "FinniversKit"
            ],
            path: "Sources/Charcoal"
        ),
        .target(
            name: "FINNSetup",
            dependencies: [
                "Charcoal"
            ],
            path: "Sources/FINNSetup"
        ),
        .testTarget(
            name: "CharcoalTests",
            dependencies: [
                "Charcoal",
                "FINNSetup"
            ],
            path: "UnitTests/Charcoal"
        ),
    ]
)
