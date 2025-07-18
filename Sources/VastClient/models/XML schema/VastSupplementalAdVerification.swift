//
//  VastSupplementalAdVerification.swift
//  VastClient
//
//  Created by AIVars on 17/07/2025.
//

import Foundation

/// VAST 4.3 Supplemental Ad Verification
/// Used to declare a non-primary ad verification resource.
public struct VastSupplementalAdVerification: Codable, Equatable {
    public let vendor: String?
    public let apiFramework: String?
    public let parameters: String?
    public let browserOptional: Bool?
    public let resource: URL?
    
    public init(vendor: String?, apiFramework: String?, parameters: String?,
                browserOptional: Bool? = false, resource: URL?) {
        self.vendor = vendor
        self.apiFramework = apiFramework
        self.parameters = parameters
        self.browserOptional = browserOptional
        self.resource = resource
    }
}
