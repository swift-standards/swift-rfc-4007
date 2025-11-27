// swift-tools-version: 6.2
import PackageDescription

extension String {
    static let rfc4007 = "RFC 4007"
    var tests: Self { "\(self) Tests" }
}

extension Target.Dependency {
    static let rfc4007 = Self.target(name: .rfc4007)
    static let rfc5952 = Self.product(name: "RFC 5952", package: "swift-rfc-5952")
    static let standards = Self.product(name: "Standards", package: "swift-standards")
    static let incits41986 = Self.product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
}

let package = Package(
    name: "swift-rfc-4007",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(name: .rfc4007, targets: [.rfc4007]),
    ],
    dependencies: [
        .package(path: "../swift-rfc-5952"),
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: .rfc4007,
            dependencies: [.rfc5952, .standards, .incits41986]
        ),
        .testTarget(
            name: .rfc4007.tests,
            dependencies: [.rfc4007]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
