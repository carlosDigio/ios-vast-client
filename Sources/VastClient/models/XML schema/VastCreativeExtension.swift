//
//  VastCreativeExtension.swift
//  Nimble
//
//  Created by Jan Bednar on 09/11/2018.
//

import Foundation

enum VastCreativeExtensionAttribute: String, CaseIterable {
    case type
    case apiFramework // VAST 4.2
    case purpose      // VAST 4.2 - Purpose of the extension
    
    init?(rawValue: String) {
        guard let value = VastCreativeExtensionAttribute.allCases.first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) else {
            return nil
        }
        self = value
    }
}

public struct VastCreativeExtension: Codable {
    public let mimeType: String?
    public let apiFramework: String? // VAST 4.2
    public let purpose: String?      // VAST 4.2
    
    public var content: String? //XML
}

extension VastCreativeExtension {
    public init?(attrDict: [String: String]) {
        var type: String?
        var apiFramework: String?
        var purpose: String?
        
        attrDict.compactMap { key, value -> (VastCreativeExtensionAttribute, String)? in
            guard let newKey = VastCreativeExtensionAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
        }.forEach { (key, value) in
            switch key {
            case .type:
                type = value
            case .apiFramework:
                apiFramework = value
            case .purpose:
                purpose = value
            }
        }
        
        self.mimeType = type
        self.apiFramework = apiFramework
        self.purpose = purpose
    }
}

extension VastCreativeExtension: Equatable {
}
