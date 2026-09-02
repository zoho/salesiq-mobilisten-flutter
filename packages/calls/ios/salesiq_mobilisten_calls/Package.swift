// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "salesiq_mobilisten_calls",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "salesiq-mobilisten-calls", targets: ["salesiq_mobilisten_calls"])
    ],
    dependencies: [
        .package(url: "https://github.com/zoho/SalesIQ-Mobilisten-iOS-SP", exact: "11.0.3")
    ],
    targets: [
        .target(
            name: "salesiq_mobilisten_calls",
            dependencies: [
                .product(name: "Mobilisten", package: "SalesIQ-Mobilisten-iOS-SP"),
                .product(name: "MobilistenCalls", package: "SalesIQ-Mobilisten-iOS-SP")
            ]
        )
    ]
)
