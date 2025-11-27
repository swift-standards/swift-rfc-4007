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

// RFC_4007.swift
// swift-rfc-4007
//
// RFC 4007: IPv6 Scoped Address Architecture (March 2005)
// https://www.rfc-editor.org/rfc/rfc4007.html
//
// This package implements IPv6 scoped address architecture, which extends
// RFC 4291 with zone identifiers for disambiguating non-global addresses.
//
// Key concepts:
// - Zone identifiers for link-local and site-local addresses
// - Format: address%zone_id (e.g., "fe80::1%eth0")
// - Zone IDs are node-local and MUST NOT be sent on the wire
//
// RFC 4007 is essential for proper IPv6 implementation as it resolves
// ambiguity when multiple interfaces exist with the same link-local prefix.

public import INCITS_4_1986

/// RFC 4007: IPv6 Scoped Address Architecture
///
/// This namespace provides support for IPv6 addresses with zone identifiers,
/// which are necessary for disambiguating non-global addresses.
///
/// ## Scoped Addresses (RFC 4007 Section 3)
///
/// IPv6 addresses have different scopes:
/// - **Link-local** (fe80::/10): Valid only on a specific link
/// - **Site-local** (deprecated): Valid within a site
/// - **Global**: Valid globally
///
/// For non-global addresses, a zone identifier specifies which zone (typically
/// an interface) the address belongs to.
///
/// ## Zone Identifier Format (RFC 4007 Section 11)
///
/// ```
/// <address>%<zone_id>
/// ```
///
/// Examples:
/// - `fe80::1%eth0` - Link-local address on interface eth0
/// - `fe80::1%1` - Link-local address on zone ID 1
///
/// ## Important Properties
///
/// 1. **Node-local**: Zone IDs are meaningful only to the local node
/// 2. **MUST NOT be sent**: RFC 4007 Section 6 - zone IDs must not appear in packets
/// 3. **Display only**: Zone IDs are for human-readable representation and APIs
///
/// ## Example
///
/// ```swift
/// import RFC_4007
///
/// let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
/// let scoped = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")
///
/// print(scoped.address.isLinkLocal)  // true
/// print(String(scoped))              // "fe80::1%eth0"
/// ```
public enum RFC_4007 {}

/// IPv6 namespace for scoped addresses
extension RFC_4007 {
    public enum IPv6 {}
}
