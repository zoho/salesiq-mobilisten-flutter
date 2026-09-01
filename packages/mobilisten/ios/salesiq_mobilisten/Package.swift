// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "salesiq_mobilisten",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "salesiq-mobilisten", targets: ["salesiq_mobilisten"])
    ],
    dependencies: [
        .package(url: "https://github.com/zoho/SalesIQ-Mobilisten-iOS-SP.git", exact: "10.4.8"),
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "salesiq_mobilisten",
            dependencies: [
                .product(name: "Mobilisten", package: "SalesIQ-Mobilisten-iOS-SP"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
