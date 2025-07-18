//
//  VastAdVerifications.swift
//  VastClient
//
//  Created for VAST 4.2 Compliance
//  Copyright © 2025 iVoox. All rights reserved.
//

import Foundation

struct AdVerificationsElements {
    static let verification = "Verification"
    // VAST 4.3 element
    static let supplementalAdVerification = "SupplementalAdVerification"
}

// VAST 4.2 - AdVerifications container for verifications
// Updated for VAST 4.3 to include supplemental verifications.
public struct VastAdVerifications: Codable {
    public var verifications: [VastVerification] = []
    // VAST 4.3 supplemental ad verifications
    public var supplementalAdVerifications: [VastSupplementalAdVerification] = []
    
    // Convenience methods
    public func hasVerifications() -> Bool {
        return !verifications.isEmpty || !supplementalAdVerifications.isEmpty
    }
    
    public func verificationsByVendor(_ vendor: String) -> [VastVerification] {
        return verifications.filter { $0.vendor?.lowercased() == vendor.lowercased() }
    }
    
    // Common verifications in the advertising market
    public var moatVerifications: [VastVerification] {
        return verificationsByVendor("moat")
    }
    
    public var iasVerifications: [VastVerification] {
        return verificationsByVendor("ias")
    }
    
    public var doubleverifyVerifications: [VastVerification] {
        return verificationsByVendor("doubleverify")
    }
}

extension VastAdVerifications: Equatable {}
