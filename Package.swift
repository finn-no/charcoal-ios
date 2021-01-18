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
    ],
    dependencies: [
        .package(name: "FinniversKit", url: "https://github.com/finn-no/FinniversKit.git", from: "71.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Charcoal",
            dependencies: [
                "FinniversKit"
            ],
            path: "Sources/Charcoal",
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
