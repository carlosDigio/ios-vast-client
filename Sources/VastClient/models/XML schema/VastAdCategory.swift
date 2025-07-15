//
//  VastAdCategory.swift
//  VastClient
//
//  Created for VAST 4.2 Compliance
//  Copyright © 2025 iVoox. All rights reserved.
//

import Foundation

struct CategoryAttributes {
    static let authority = "authority"  // VAST 4.2 nuevo atributo
}

public struct VastAdCategory: Codable {
    public let authority: String?
    public var value: String?
}

extension VastAdCategory {
    public init(attrDict: [String: String]) {
        var authority: String?
        
        for (key, value) in attrDict {
            switch key {
            case CategoryAttributes.authority:
                authority = value
            default:
                break
            }
        }
        
        self.authority = authority
    }
}

extension VastAdCategory: Equatable {}
