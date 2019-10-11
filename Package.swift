// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FcaKit",
    platforms: [
        .macOS(.v10_12),
    ],
    products: [
        .library(
            name: "FcaKit",
            targets: ["FcaKit"]),
    ],
    targets: [
        .target(
            name: "FcaKit",
            dependencies: []),
        .testTarget(
            name: "FcaKitTests",
            dependencies: ["FcaKit"]),
    ]
)
