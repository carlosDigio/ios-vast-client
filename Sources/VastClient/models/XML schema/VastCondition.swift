//
//  VastCondition.swift
//  VastClient
//
//  Created by John Gainfort Jr on 6/5/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

enum ConditionalElements {
    static let condition = "Condition"
}

fileprivate enum VastConditionAttribute: String, CaseIterable {
    case type
    case name
    
    init?(rawValue: String) {
        guard let value = VastConditionAttribute.allCases.first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) else {
            return nil
        }
        self = value
    }
}

public struct VastCondition: Codable {
    public let type: String?
    public let name: String?
    public var value: String?
}

extension VastCondition {
    public init(attrDict: [String: String]) {
        var type: String?
        var name: String?
        
        attrDict.compactMap { key, value -> (VastConditionAttribute, String)? in
            guard let newKey = VastConditionAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
        }.forEach { (key, value) in
            switch key {
            case .type:
                type = value
            case .name:
                name = value
            }
        }
        
        self.type = type
        self.name = name
        self.value = nil
    }
}

extension VastCondition: Equatable {}
