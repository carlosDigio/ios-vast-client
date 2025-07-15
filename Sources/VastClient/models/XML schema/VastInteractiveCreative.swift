//
//  VastInteractiveCreative.swift
//  VastClient
//
//  Created for VAST 4.2 Compliance
//  Copyright © 2025 iVoox. All rights reserved.
//

import Foundation

struct InteractiveCreativeElements {
    static let staticResource = "StaticResource"
    static let htmlResource = "HTMLResource"
    static let iframeResource = "IFrameResource"
    static let interactiveCreativeFile = "InteractiveCreativeFile"
}

struct InteractiveCreativeAttributes {
    static let apiFramework = "apiFramework"
    static let variableDuration = "variableDuration"
}

// VAST 4.2 - InteractiveCreative para companion ads interactivos (crítico para audio apps)
public struct VastInteractiveCreative: Codable {
    public let apiFramework: String?
    public let variableDuration: Bool?
    
    // Resources
    public var staticResource: [VastStaticResource] = []
    public var htmlResource: [URL] = []
    public var iframeResource: [URL] = []
    public var interactiveCreativeFiles: [VastInteractiveCreativeFile] = []
    
    // Métodos de conveniencia para iVoox
    public var hasInteractiveElements: Bool {
        return !interactiveCreativeFiles.isEmpty || !htmlResource.isEmpty
    }
    
    public var isVariableDuration: Bool {
        return variableDuration ?? false
    }
}

extension VastInteractiveCreative {
    public init(attrDict: [String: String]) {
        var apiFramework: String?
        var variableDuration: Bool?
        
        for (key, value) in attrDict {
            switch key {
            case InteractiveCreativeAttributes.apiFramework:
                apiFramework = value
            case InteractiveCreativeAttributes.variableDuration:
                variableDuration = (value.lowercased() == "true")
            default:
                break
            }
        }
        
        self.apiFramework = apiFramework
        self.variableDuration = variableDuration
    }
}

extension VastInteractiveCreative: Equatable {}