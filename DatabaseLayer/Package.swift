// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatabaseLayer",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "DatabaseLayer",
            targets: ["DatabaseLayer"])
    ],
    dependencies: [
        .package(path: "./CoreLayer")
    ],
    targets: [
        .target(
            name: "DatabaseLayer",
            dependencies: ["CoreLayer"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "DatabaseLayerTests",
            dependencies: ["DatabaseLayer", "CoreLayer"])
    ]
)
