// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

// RFC_4007.IPv6.ScopedAddress.swift
// swift-rfc-4007
//
// IPv6 Scoped Address with Zone Identifier

import INCITS_4_1986
import RFC_5952
import Standards

extension RFC_4007.IPv6 {
    /// IPv6 Scoped Address (RFC 4007)
    ///
    /// An IPv6 address with an optional zone identifier for disambiguating
    /// non-global addresses.
    ///
    /// ## Zone Identifier Semantics (RFC 4007 Section 6)
    ///
    /// Zone identifiers are:
    /// - **Node-local**: Only meaningful on the local node
    /// - **Never transmitted**: MUST NOT appear in packets on the wire
    /// - **Display purposes**: For APIs, UIs, and configuration
    ///
    /// ## When Zone IDs Are Needed
    ///
    /// Zone identifiers are primarily used with:
    /// - **Link-local addresses** (fe80::/10): Required when multiple interfaces exist
    /// - **Site-local addresses** (deprecated): Needed for site disambiguation
    ///
    /// Global addresses typically don't need zone identifiers.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Link-local address on eth0
    /// let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
    /// let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")
    ///
    /// print(String(scoped))  // "fe80::1%eth0"
    ///
    /// // Global address (no zone needed)
    /// let global = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
    /// let unscoped = RFC_4007.IPv6.ScopedAddress(address: global, zone: nil)
    ///
    /// print(String(unscoped))  // "2001:db8::1"
    /// ```
    public struct ScopedAddress: Hashable, Sendable {
        /// The IPv6 address
        public let address: RFC_4291.IPv6.Address

        /// The zone identifier (e.g., "eth0", "1")
        ///
        /// Per RFC 4007 Section 11: The zone ID is a string that identifies
        /// the zone. It can be an interface name or numeric ID.
        ///
        /// `nil` indicates the address doesn't require a zone identifier
        /// (e.g., global addresses).
        public let zone: String?

        /// Creates a scoped IPv6 address
        ///
        /// - Parameters:
        ///   - address: The IPv6 address
        ///   - zone: Optional zone identifier for non-global addresses
        public init<S: StringProtocol>(
            address: RFC_4291.IPv6.Address,
            zone: S?
        ) {
            self.address = address
            self.zone = zone.map { String($0) }
        }

        /// Creates a scoped IPv6 address
        ///
        /// - Parameters:
        ///   - address: The IPv6 address
        ///   - zone: Optional zone identifier for non-global addresses
        public init(
            address: RFC_4291.IPv6.Address,
            zone: String? = nil
        ) {
            self.address = address
            self.zone = zone
        }
    }
}

// MARK: - Convenience Properties

extension RFC_4007.IPv6.ScopedAddress {
    /// Whether this address requires a zone identifier
    ///
    /// Returns `true` for addresses where a zone identifier is meaningful:
    /// - Link-local addresses (fe80::/10)
    /// - Unique local addresses (fc00::/7)
    ///
    /// Global addresses and loopback don't require zone identifiers.
    public var requiresZone: Bool {
        address.isLinkLocal || address.isUniqueLocal
    }

    /// Whether this is a properly scoped address
    ///
    /// Returns `true` if:
    /// - The address requires a zone and has one, OR
    /// - The address doesn't require a zone
    public var isProperlyScoped: Bool {
        if requiresZone {
            return zone != nil
        }
        return true
    }
}

// MARK: - String Transformation

extension String {
    /// Creates the text representation of a scoped IPv6 address
    ///
    /// This is a convenience transformation that composes through the canonical
    /// byte representation:
    /// ```
    /// IPv6.ScopedAddress → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// This follows RFC 4007 Section 11.7 format:
    /// ```
    /// <address>%<zone_id>
    /// ```
    ///
    /// If no zone identifier is present, returns just the address in RFC 5952
    /// canonical format.
    ///
    /// ## Category Theory
    ///
    /// This is functor composition - the String transformation is derived from
    /// the more universal [UInt8] transformation. ASCII is a subset of UTF-8,
    /// so this conversion is always safe.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // With zone
    /// let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
    /// let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")
    /// String(scoped)  // "fe80::1%eth0"
    ///
    /// // Without zone
    /// let global = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
    /// let unscoped = RFC_4007.IPv6.ScopedAddress(address: global, zone: nil)
    /// String(unscoped)  // "2001:db8::1"
    /// ```
    ///
    /// - Parameter scopedAddress: The scoped IPv6 address to represent
    public init(
        _ scopedAddress: RFC_4007.IPv6.ScopedAddress
    ) {
        // Compose through canonical byte representation
        // ASCII ⊂ UTF-8, so this is always valid
        self.init(decoding: [UInt8](ascii: scopedAddress), as: UTF8.self)
    }
}

// MARK: - CustomStringConvertible

extension RFC_4007.IPv6.ScopedAddress: CustomStringConvertible {
    /// The text representation of this scoped address
    ///
    /// Delegates to the String transformation for RFC 4007 compliance.
    public var description: String {
        String(self)
    }
}
