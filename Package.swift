// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NnReminderKit",
    platforms: [
        .iOS(.v17), .macOS(.v14)
    ],
    products: [
        .library(
            name: "NnReminderKit",
            targets: ["NnReminderKit"]),
        .library(
            name: "NnReminderUITestHelpers",
            targets: ["NnReminderUITestHelpers"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "NnReminderKit"),
        .target(
            name: "NnReminderUITestHelpers",
            linkerSettings: [.linkedFramework("XCTest")]),
        .testTarget(
            name: "NnReminderKitTests",
            dependencies: [
                "NnReminderKit"
            ]
        )
    ]
)
