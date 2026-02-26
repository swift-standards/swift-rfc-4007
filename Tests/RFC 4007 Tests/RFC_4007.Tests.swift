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

import Testing

@testable import RFC_4007
@testable import RFC_4291

@Suite("RFC 4007: IPv6 Scoped Address Tests")
struct RFC4007Tests {

    // MARK: - Basic Construction

    @Test("ScopedAddress initialization with zone")
    func initWithZone() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")

        #expect(scoped.address == address)
        #expect(scoped.zone == "eth0")
    }

    @Test("ScopedAddress initialization without zone")
    func initWithoutZone() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: address, zone: nil)

        #expect(scoped.address == address)
        #expect(scoped.zone == nil)
    }

    @Test("ScopedAddress default zone is nil")
    func defaultZoneIsNil() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: address)

        #expect(scoped.zone == nil)
    }

    @Test("ScopedAddress accepts StringProtocol types")
    func acceptsStringProtocol() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)

        // Test with Substring
        let fullString = "eth0_interface"
        let substring = fullString.prefix(4)  // "eth0"
        let scoped1 = RFC_4007.IPv6.ScopedAddress(address: address, zone: substring)

        #expect(scoped1.zone == "eth0")
        #expect(String(scoped1) == "fe80::1%eth0")

        // Test with String
        let scoped2 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "wlan0")
        #expect(scoped2.zone == "wlan0")
        #expect(String(scoped2) == "fe80::1%wlan0")
    }

    // MARK: - Zone Requirements

    @Test("Link-local addresses require zone")
    func linkLocalRequiresZone() throws {
        let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal)

        #expect(scoped.requiresZone == true)
        #expect(scoped.isProperlyScoped == false)  // No zone provided
    }

    @Test("Link-local with zone is properly scoped")
    func linkLocalWithZone() throws {
        let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")

        #expect(scoped.requiresZone == true)
        #expect(scoped.isProperlyScoped == true)
    }

    @Test("Unique local addresses require zone")
    func uniqueLocalRequiresZone() throws {
        let ula = RFC_4291.IPv6.Address(0xfc00, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: ula)

        #expect(scoped.requiresZone == true)
        #expect(scoped.isProperlyScoped == false)
    }

    @Test("Global addresses don't require zone")
    func globalNoZoneRequired() throws {
        let global = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: global)

        #expect(scoped.requiresZone == false)
        #expect(scoped.isProperlyScoped == true)  // No zone needed
    }

    @Test("Loopback doesn't require zone")
    func loopbackNoZoneRequired() throws {
        let loopback = RFC_4291.IPv6.Address.loopback
        let scoped = RFC_4007.IPv6.ScopedAddress(address: loopback)

        #expect(scoped.requiresZone == false)
        #expect(scoped.isProperlyScoped == true)
    }

    // MARK: - String Representation (RFC 4007 Section 11.7)

    @Test("RFC 4007 Section 11.7: Link-local with zone string format")
    func linkLocalStringFormat() throws {
        let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")

        let text = String(scoped)
        #expect(text == "fe80::1%eth0")
    }

    @Test("RFC 4007 Section 11.7: Numeric zone ID")
    func numericZoneID() throws {
        let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "1")

        let text = String(scoped)
        #expect(text == "fe80::1%1")
    }

    @Test("Global address without zone")
    func globalAddressNoZone() throws {
        let global = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: global)

        let text = String(scoped)
        #expect(text == "2001:db8::1")
        #expect(!text.contains("%"))
    }

    @Test("Global address with zone (unusual but allowed)")
    func globalAddressWithZone() throws {
        let global = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: global, zone: "eth0")

        let text = String(scoped)
        #expect(text == "2001:db8::1%eth0")
    }

    @Test("Unspecified address without zone")
    func unspecifiedNoZone() throws {
        let unspecified = RFC_4291.IPv6.Address.unspecified
        let scoped = RFC_4007.IPv6.ScopedAddress(address: unspecified)

        let text = String(scoped)
        #expect(text == "::")
    }

    @Test("CustomStringConvertible description")
    func customStringConvertible() throws {
        let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")

        #expect(scoped.description == "fe80::1%eth0")
    }

    // MARK: - Equality & Hashing

    @Test("Equality with same address and zone")
    func equalitySame() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped1 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")
        let scoped2 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")

        #expect(scoped1 == scoped2)
    }

    @Test("Inequality with different zones")
    func inequalityDifferentZone() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped1 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")
        let scoped2 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth1")

        #expect(scoped1 != scoped2)
    }

    @Test("Inequality with zone vs no zone")
    func inequalityZoneVsNone() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped1 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")
        let scoped2 = RFC_4007.IPv6.ScopedAddress(address: address, zone: nil)

        #expect(scoped1 != scoped2)
    }

    @Test("Hashable allows use in Set")
    func hashableInSet() throws {
        let address1 = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let address2 = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 2)

        let scoped1 = RFC_4007.IPv6.ScopedAddress(address: address1, zone: "eth0")
        let scoped2 = RFC_4007.IPv6.ScopedAddress(address: address1, zone: "eth1")
        let scoped3 = RFC_4007.IPv6.ScopedAddress(address: address2, zone: "eth0")

        var set: Set<RFC_4007.IPv6.ScopedAddress> = []
        set.insert(scoped1)
        set.insert(scoped2)
        set.insert(scoped3)

        #expect(set.count == 3)
    }

    // MARK: - Real-World Examples

    @Test("Link-local on multiple interfaces")
    func multipleInterfaces() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0x0200, 0x5eff, 0xfe00, 0x0001)

        let eth0 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")
        let eth1 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth1")

        #expect(String(eth0) == "fe80::200:5eff:fe00:1%eth0")
        #expect(String(eth1) == "fe80::200:5eff:fe00:1%eth1")
        #expect(eth0 != eth1)  // Different zones distinguish them
    }

    @Test("Multicast with zone")
    func multicastWithZone() throws {
        // ff02::1 (all nodes link-local multicast)
        let multicast = RFC_4291.IPv6.Address(0xff02, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: multicast, zone: "eth0")

        #expect(String(scoped) == "ff02::1%eth0")
    }

    @Test("Documentation address (global scope)")
    func documentationAddress() throws {
        let docs = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: docs)

        #expect(scoped.requiresZone == false)
        #expect(String(scoped) == "2001:db8::1")
    }
}
