// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "JoyBoySDK",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "JoyBoySDK",
            targets: ["JoyBoySDK"]  // Fixed the typo here
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "JoyBoyPlayer",
            dependencies: [],
            path: "Sources/JoyBoyPlayer"
        ),
        .target(
            name: "JoyBoyLogin",
            dependencies: [],
            path: "Sources/JoyBoyLogin"
        ),
        .target(
            name: "JoyBoySDK",
            dependencies: ["JoyBoyPlayer", "JoyBoyLogin"],
            path: "Sources/JoyBoySDK"
        ),
    ]
)
