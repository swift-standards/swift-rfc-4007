// swift-tools-version: 6.2
import PackageDescription

extension String {
    static let rfc4007 = "RFC 4007"
    var tests: Self { "\(self) Tests" }
}

extension Target.Dependency {
    static let rfc4007 = Self.target(name: .rfc4007)
    static let rfc5952 = Self.product(name: "RFC 5952", package: "swift-rfc-5952")
    static let standards = Self.product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    static let incits41986 = Self.product(name: "ASCII", package: "swift-ascii")
}

let package = Package(
    name: "swift-rfc-4007",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(name: .rfc4007, targets: [.rfc4007])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-rfc-5952.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-standard-library-extensions.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-ascii.git", from: "0.0.1"),
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
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
        ]
}
