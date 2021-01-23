// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Packages",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "Packages",
            targets: ["Packages"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("5.1.1")),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "14.0.0")),
        .package(url: "https://github.com/roberthein/TinyConstraints.git", .upToNextMajor(from: "4.0.1")),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "4.0.0"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.13.2"),
        .package(name: "Realm", url: "https://github.com/realm/realm-cocoa.git", from: "10.5.1"),
        .package(url: "https://github.com/super-ultra/UltraDrawerView", from: "0.5.0")
    ],
    targets: [
        .target(
            name: "Packages",
            dependencies: ["Moya",
                           "RxSwift",
                           "TinyConstraints",
                           "SDWebImage",
                           "RxDataSources",
                           "PromiseKit",
                           "UltraDrawerView",
                           .product(name: "RealmSwift", package: "Realm"),
                           .product(name: "ReactiveMoya", package: "Moya"),
                           .product(name: "RxCocoa", package: "RxSwift")],
            exclude: ["Tests",
                      "Sources/Supporting Files",
                      "Examples"]),
    ]
)
