//
//  VastAdVerificationParameters.swift
//  VastClient
//
//  Created by Austin Christensen on 7/11/19.
//  Copyright © 2019 John Gainfort Jr. All rights reserved.
//

import Foundation

public struct VastAdVerificationParameters: Codable {
    public var data: String?
}

extension VastAdVerificationParameters: Equatable {
}

fileprivate enum VastAdVerificationAttribute: String, CaseIterable {
    case vendor
    
    init?(rawValue: String) {
        guard let value = VastAdVerificationAttribute.allCases.first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) else {
            return nil
        }
        self = value
    }
}

public struct VastAdVerification: Codable {
    public let vendor: String?
    public var resources: [VastResource] = []
    public var verificationParameters: String?
}

extension VastAdVerification {
    public init(attrDict: [String: String]) {
        var vendor: String?
        
        attrDict.compactMap { key, value -> (VastAdVerificationAttribute, String)? in
            guard let newKey = VastAdVerificationAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
        }.forEach { (key, value) in
            switch key {
            case .vendor:
                vendor = value
            }
        }
        
        self.vendor = vendor
    }
}

extension VastAdVerification: Equatable {}
