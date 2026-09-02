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
        .package(url: "https://github.com/zoho/SalesIQ-Mobilisten-iOS-SP", exact: "11.0.3")
    ],
    targets: [
        .target(
            name: "salesiq_mobilisten",
            dependencies: [
                .product(name: "Mobilisten", package: "SalesIQ-Mobilisten-iOS-SP")
            ]
        )
    ]
)
