// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GhibliKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "GhibliDomain", targets: ["GhibliDomain"]),
        .library(name: "GhibliData", targets: ["GhibliData"]),
        .library(name: "GhibliPresentation", targets: ["GhibliPresentation"])
    ],
    targets: [
        .target(
            name: "GhibliDomain",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .target(
            name: "GhibliData",
            dependencies: ["GhibliDomain"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .target(
            name: "GhibliPresentation",
            dependencies: ["GhibliDomain"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
