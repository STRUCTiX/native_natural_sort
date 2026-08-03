// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "native_natural_sort",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "native_natural_sort",
            targets: ["native_natural_sort"]
        ),
    ],
    targets: [
        .target(
            name: "native_natural_sort",
            path: "Classes",
            resources: [
                .process("../Resources/PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
