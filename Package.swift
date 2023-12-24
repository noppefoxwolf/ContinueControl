// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContinueControl",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "ContinueControl",
            targets: ["ContinueControl"]
        ),
    ],
    targets: [
        .target(
            name: "ContinueControl",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "ContinueControlTests",
            dependencies: ["ContinueControl"]
        ),
    ]
)
