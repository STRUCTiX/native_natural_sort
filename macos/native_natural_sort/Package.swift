// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "native_natural_sort",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "native_natural_sort",
            targets: ["native_natural_sort"]
        ),
        .library(
            name: "native-natural-sort",
            targets: ["native_natural_sort"]
        ),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "native_natural_sort",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            path: "Sources/native_natural_sort",
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
