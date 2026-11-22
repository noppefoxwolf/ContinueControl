// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContinueControl",
    platforms: [.iOS(.v18), .visionOS(.v2)],
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
