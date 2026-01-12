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

// RFC_4007.IPv6.ScopedAddress.Error.swift
// swift-rfc-4007

import ASCII

extension RFC_4007.IPv6.ScopedAddress {
    public enum Error: Swift.Error, Sendable, Equatable {
        case empty
        case invalidAddress(_ underlying: RFC_4291.IPv6.Address.Error)
        case invalidZone(_ value: String)
        case missingAddress
        case missingZone
    }
}

extension RFC_4007.IPv6.ScopedAddress.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Scoped address cannot be empty"
        case .invalidAddress(let error):
            return "Invalid IPv6 address: \(error)"
        case .invalidZone(let value):
            return "Invalid zone identifier: '\(value)'"
        case .missingAddress:
            return "Missing IPv6 address component"
        case .missingZone:
            return "Missing zone identifier after '%'"
        }
    }
}
