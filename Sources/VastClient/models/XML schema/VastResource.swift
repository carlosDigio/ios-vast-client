//
//  VastResource.swift
//  Nimble
//
//  Created by Jan Bednar on 14/11/2018.
//

import Foundation

enum VastResourceAttribute: String {
    case apiFramework
}

public struct VastResource: Codable {
    public let apiFramework: String?
    public let browserOptional: Bool?
    public var url: URL?
    
    public init(attrDict: [String: String]) {
        var apiFramework: String?
        var browserOptional: Bool? = false
        
        for (key, value) in attrDict {
            switch key {
            case VerificationAttributes.apiFramework:
                apiFramework = value
            case VerificationAttributes.browserOptional:
                browserOptional = (value.lowercased() == "true")
            default:
                break
            }
        }
        
        self.apiFramework = apiFramework
        self.browserOptional = browserOptional
        self.url = nil // Se asignará después cuando se parsee el contenido
    }
}

extension VastResource: Equatable {}

