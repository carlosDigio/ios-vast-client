//
//  VastVerification.swift
//  VastClient
//
//  Created for VAST 4.2 Compliance
//  Copyright © 2025 iVoox. All rights reserved.
//

import Foundation

struct VerificationElements {
    static let javaScriptResource = "JavaScriptResource"
    static let flashResource = "FlashResource"
    static let executableResource = "ExecutableResource" // VAST 4.2 preferencia sobre FlashResource
    static let viewableImpression = "ViewableImpression"
    static let verificationParameters = "VerificationParameters"
}

struct VerificationAttributes {
    static let vendor = "vendor"
    static let apiFramework = "apiFramework"
    static let browserOptional = "browserOptional"
}

// VAST 4.2 - Verification para Ad Verification (MOAT, IAS, etc.)
public struct VastVerification: Codable {
    public let vendor: String?
    public let apiFramework: String?  // Atributo a nivel de Verification
    
    // Sub Elements - Arrays para los recursos que pueden aparecer múltiples veces
    public var javaScriptResources: [VastResource] = []
    public var flashResources: [VastResource] = []      // Deprecated pero mantenido por compatibilidad
    public var executableResources: [VastResource] = [] // VAST 4.2 preferencia
    public var viewableImpression: VastViewableImpression?
    public var verificationParameters: VastAdVerificationParameters?
}


extension VastVerification {
    public init(attrDict: [String: String]) {
        var vendor: String?
        var apiFramework: String?
        
        for (key, value) in attrDict {
            switch key {
            case VerificationAttributes.vendor:
                vendor = value
            case VerificationAttributes.apiFramework:
                apiFramework = value
            default:
                break
            }
        }
        
        self.vendor = vendor
        self.apiFramework = apiFramework
    }
}

extension VastVerification: Equatable {}
