//
//  VastValidator.swift
//  VastClient
//
//  Created for VAST 4.2 Compliance
//  Copyright © 2025 iVoox. All rights reserved.
//

import Foundation

// VAST 4.2 - Validador completo para compliance
public class VastValidator {
    
    public enum ValidationError: Error, LocalizedError {
        case unsupportedVersion(String)
        case missingRequiredElements
        case invalidCompanionAd
        case missingUniversalAdId
        case invalidRenderingMode
        case invalidAdVerifications
        case invalidAdPod
        
        public var errorDescription: String? {
            switch self {
            case .unsupportedVersion(let version):
                return "Versión VAST no soportada: \(version)"
            case .missingRequiredElements:
                return "Faltan elementos requeridos en VAST 4.2"
            case .invalidCompanionAd:
                return "Companion ad inválido para VAST 4.2"
            case .missingUniversalAdId:
                return "UniversalAdId requerido para VAST 4.2"
            case .invalidRenderingMode:
                return "RenderingMode inválido para audio apps"
            case .invalidAdVerifications:
                return "AdVerifications inválidas"
            case .invalidAdPod:
                return "AdPod inválido o mal configurado"
            }
        }
    }
    
    public static let shared = VastValidator()
    private init() {}
    
    // Validación principal para VAST 4.2
    public func validate(_ vastModel: VastModel) throws {
        // Validar versión
        try validateVersion(vastModel.version)
        
        // Validar anuncios
        for ad in vastModel.ads {
            try validateAd(ad)
        }
        
        // Validar Ad Pods si existen
        if !vastModel.adPods.isEmpty {
            for pod in vastModel.adPods {
                try validateAdPod(pod)
            }
        }
    }
    
    // Validación específica para apps de audio como iVoox
    public func validateForAudio(_ vastModel: VastModel) throws {
        try validate(vastModel)
        
        // Validaciones específicas para audio
        for ad in vastModel.ads {
            try validateAudioCompatibility(ad)
        }
    }
    
    // MARK: - Validaciones específicas
    
    private func validateVersion(_ version: String) throws {
        let supportedVersions = ["3.0", "4.0", "4.1", "4.2"]
        guard supportedVersions.contains(version) else {
            throw ValidationError.unsupportedVersion(version)
        }
    }
    
    private func validateAd(_ ad: VastAd) throws {
        // Validar que tiene elementos esenciales
        guard ad.adSystem != nil else {
            throw ValidationError.missingRequiredElements
        }
        
        // Para VAST 4.2, validar UniversalAdId si está presente
        if let universalAdId = ad.universalAdId {
            try validateUniversalAdId(universalAdId)
        }
        
        // Validar AdVerifications si están presentes
        let adVerifications = ad.adVerifications
        try validateAdVerifications(VastAdVerifications(verifications: adVerifications))
        
        // Validar companion ads
        for creative in ad.creatives {
            if let companionAds = creative.companionAds {
                for companion in companionAds.companions {
                    try validateCompanionAd(companion)
                }
            }
        }
    }
    
    private func validateCompanionAd(_ companion: VastCompanionCreative) throws {
        // Validar dimensiones básicas
        guard companion.width > 0 && companion.height > 0 else {
            throw ValidationError.invalidCompanionAd
        }
        
        // Validar renderingMode para VAST 4.2
        if let renderingMode = companion.renderingMode {
            try validateRenderingMode(renderingMode)
        }
        
        // Validar que tiene al least un recurso
        let hasResource = !companion.staticResource.isEmpty ||
                         !companion.htmlResource.isEmpty ||
                         !companion.iFrameResource.isEmpty
        
        guard hasResource else {
            throw ValidationError.invalidCompanionAd
        }
    }
    
    private func validateRenderingMode(_ mode: VastCompanionRenderingMode) throws {
        // Para audio apps, validar que el rendering mode es apropiado
        switch mode {
        case .concurrent, .endCard:
            // Válidos para audio
            break
        case .overlay:
            // Puede ser válido dependiendo del contexto
            break
        }
    }
    
    private func validateUniversalAdId(_ universalAdId: VastUniversalAdId) throws {
        guard !universalAdId.idRegistry.isEmpty && !universalAdId.idValue.isEmpty else {
            throw ValidationError.missingUniversalAdId
        }
    }
    
    private func validateAdVerifications(_ adVerifications: VastAdVerifications) throws {
        guard adVerifications.hasVerifications() else {
            throw ValidationError.invalidAdVerifications
        }
        
        // Validar cada verificación
        for verification in adVerifications.verifications {
            guard verification.vendor != nil else {
                throw ValidationError.invalidAdVerifications
            }
        }
    }
    
    private func validateAdPod(_ pod: VastAdPod) throws {
        guard pod.isComplete else {
            throw ValidationError.invalidAdPod
        }
    }
    
    private func validateAudioCompatibility(_ ad: VastAd) throws {
        // Validaciones específicas para audio apps
        // Por ejemplo, verificar que los companion ads tienen renderingMode apropiado
        for creative in ad.creatives {
            if let companionAds = creative.companionAds {
                for companion in companionAds.companions {
                    if companion.renderingMode == nil && companion.required == true {
                        // Companion requerido sin renderingMode específico podría ser problemático en audio
                        print("⚠️ Warning: Required companion ad without renderingMode in audio context")
                    }
                }
            }
        }
    }
}

// MARK: - Extensiones de conveniencia

public extension VastModel {
    var isVast42Compatible: Bool {
        do {
            try VastValidator.shared.validate(self)
            return true
        } catch {
            return false
        }
    }
    
    var isAudioCompatible: Bool {
        do {
            try VastValidator.shared.validateForAudio(self)
            return true
        } catch {
            return false
        }
    }
}
