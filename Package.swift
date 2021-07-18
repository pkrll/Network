// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Network",
    products: [
        .library(name: "Network", targets: ["Network"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Network", dependencies: ["Shared"]),
        .target(name: "Shared", dependencies: []),
        .testTarget(name: "NetworkTests", dependencies: ["Network"])
    ]
)
