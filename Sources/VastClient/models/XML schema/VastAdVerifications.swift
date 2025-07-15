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
}

// VAST 4.2 - AdVerifications contenedor principal para verificaciones
public struct VastAdVerifications: Codable {
    public var verifications: [VastVerification] = []
    
    // Métodos de conveniencia para iVoox
    public func hasVerifications() -> Bool {
        return !verifications.isEmpty
    }
    
    public func verificationsByVendor(_ vendor: String) -> [VastVerification] {
        return verifications.filter { $0.vendor?.lowercased() == vendor.lowercased() }
    }
    
    // Verificaciones comunes en el mercado publicitario
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