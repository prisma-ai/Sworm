// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sworm",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .library(
            name: "Sworm",
            targets: ["Sworm"]
        ),
        .library(
            name: "SwormTools",
            targets: ["SwormTools"]
        ),
    ],
    targets: [
        .target(name: "Sworm"),
        .target(name: "SwormTools"),
        .testTarget(
            name: "SwormTests",
            dependencies: ["Sworm", "SwormTools"]
        ),
    ]
)
