// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReopenMacApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ReopenMacApp",
            targets: ["ReopenMacApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ReopenMacApp",
            dependencies: [],
            path: ".",
            sources: [
                "ReopenMacAppApp.swift",
                "ContentView.swift",
                "AppDelegate.swift"
            ]
        )
    ]
)