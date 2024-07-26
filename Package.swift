// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Antishot",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Antishot",
            targets: ["Antishot"]),
        .library(
            name: "Nevershot",
            targets: ["Nevershot"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Antishot"),
        .target(
            name: "Nevershot",
            publicHeadersPath: "include"),
        .testTarget(
            name: "AntishotTests",
            dependencies: ["Antishot"]
        ),
    ]
)
