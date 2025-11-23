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

// [UInt8]+ScopedAddress.swift
// swift-rfc-4007
//
// Canonical byte serialization for IPv6 scoped addresses

import INCITS_4_1986
import RFC_5952
import Standards

// MARK: - Canonical Serialization (Universal Property)

extension [UInt8] {
    /// Creates ASCII byte representation of a scoped IPv6 address (RFC 4007)
    ///
    /// This is the canonical serialization of scoped IPv6 addresses to bytes.
    /// The format is defined by RFC 4007 Section 11.7:
    /// ```
    /// <address>%<zone_id>
    /// ```
    ///
    /// If no zone identifier is present, returns just the address in RFC 5952
    /// canonical format.
    ///
    /// ## Category Theory
    ///
    /// This is the most universal serialization (natural transformation):
    /// - **Domain**: IPv6.ScopedAddress (structured data)
    /// - **Codomain**: [UInt8] (ASCII bytes)
    ///
    /// String representation is derived as composition:
    /// ```
    /// IPv6.ScopedAddress → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Performance
    ///
    /// Direct ASCII generation without intermediate String allocations:
    /// - Composes through RFC 5952 canonical IPv6 bytes
    /// - Direct UTF-8 append for zone identifier
    /// - No string interpolation overhead
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
    /// let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")
    /// let bytes = [UInt8](ascii: scoped)
    /// // bytes == "fe80::1%eth0" (as ASCII bytes)
    /// ```
    ///
    /// - Parameter scopedAddress: The scoped IPv6 address to serialize
    public init(ascii scopedAddress: RFC_4007.IPv6.ScopedAddress) {
        // Get canonical RFC 5952 representation of the address
        self = [UInt8](ascii: scopedAddress.address)

        if let zone = scopedAddress.zone {
            // RFC 4007 Section 11.7: Format is <address>%<zone_id>
            self.append(UInt8(ascii: "%"))
            self.append(utf8: zone)
        }
    }
}
