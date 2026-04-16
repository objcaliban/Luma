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
//    dependencies: [
//        // Core LLM library
//        .package(url: "https://github.com/ml-explore/mlx-swift-lm", branch: "main"),
//        // Tokenizer adapter
//        .package(url: "https://github.com/DePasqualeOrg/swift-tokenizers-mlx", from: "0.1.0"),
//        // Hugging Face downloader adapter (for downloading models)
//        .package(url: "https://github.com/DePasqualeOrg/swift-hf-api-mlx", from: "0.1.0"),
//    ],
//    dependencies: [
//        .package(url: "https://github.com/ml-explore/mlx-swift-lm", branch: "main"),
//        .package(url: "https://github.com/DePasqualeOrg/swift-tokenizers-mlx", branch: "main"),
//        .package(url: "https://github.com/DePasqualeOrg/swift-hf-api-mlx", branch: "main"),
//    ],
//    targets: [
//        .target(
//            name: "LLMKit",
//            dependencies: [
//                .product(name: "MLXLLM", package: "mlx-swift-lm"),
//                .product(name: "MLXLMTokenizers", package: "swift-tokenizers-mlx"),
//                .product(name: "MLXLMHuggingFace", package: "swift-hf-api-mlx"),
//            ]
//        ),
//    ],
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
