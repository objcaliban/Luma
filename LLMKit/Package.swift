// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LLMKit",
    platforms: [.macOS(.v15)],
    products: [
        .library(
            name: "LLMKit",
            targets: ["LLMKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift-lm", from: "2.30.0"),
    ],
    targets: [
        .target(
            name: "LLMKit",
            dependencies: [
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
