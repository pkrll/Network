// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkStack",
    products: [.library(name: "NetworkStack", targets: ["NetworkStack"])],
    dependencies: [],
    targets: [
        .target(name: "NetworkStack", dependencies: ["Shared"]),
        .target(name: "Shared", dependencies: []),
        .testTarget(name: "NetworkTests", dependencies: ["NetworkStack"])
    ]
)
