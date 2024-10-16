// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Charcoal",
    defaultLocalization: "nb",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Charcoal",
            targets: ["Charcoal"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/finn-no/FinniversKit.git", "147.0.0"..."999.0.0")
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
