// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NnReminderKit",
    platforms: [
        .iOS(.v15), .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "NnReminderKit",
            targets: ["NnReminderKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nikolainobadi/NnTestKit", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "NnReminderKit"),
        .testTarget(
            name: "NnReminderKitTests",
            dependencies: [
                "NnReminderKit",
                .product(name: "NnTestHelpers", package: "NnTestKit")
            ]
        ),
    ]
)
