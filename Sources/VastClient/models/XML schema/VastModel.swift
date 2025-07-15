//
//  VastModel.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct VastElements {
    static let vast = "VAST"
    static let error = "Error"
    static let ad = "Ad"
    static let creative = "Creative"
    static let extensions = "Extensions"
}

// Estructura para elementos de Verificación de Anuncios según VAST 4.2
struct VastAdVerificationElements {
    static let viewableImpression = "ViewableImpression"
    static let verificationParameters = "VerificationParameters"
    static let javaScriptResource = "JavaScriptResource"
    static let executableResource = "ExecutableResource"
    static let flashResource = "FlashResource" // Deprecated pero mantenido por compatibilidad
}

struct VastAttributes {
    static let version = "version"
    // VAST 4.2 puede tener namespaces adicionales
    static let xmlns = "xmlns"
}

// VAST 4.2 - Enum para versiones soportadas
public enum VastVersion: String, Codable, CaseIterable {
    case v2_0 = "2.0"
    case v3_0 = "3.0"
    case v4_0 = "4.0"
    case v4_1 = "4.1"
    case v4_2 = "4.2"   // Nueva versión objetivo
    case unknown = "unknown"
    
    // Validación de compatibilidad para iVoox
    public var isSupported: Bool {
        switch self {
        case .v4_0, .v4_1, .v4_2:
            return true
        case .v3_0:
            return true  // Retrocompatible
        default:
            return false
        }
    }
    
    public var supportsCompanionRenderingMode: Bool {
        switch self {
        case .v4_2:
            return true
        default:
            return false
        }
    }
}

public struct VastModel: Codable {
    public let version: String
    public let vastVersion: VastVersion  // VAST 4.2 - Versión parseada
    public var ads: [VastAd] = []
    public var errors: [URL] = []
    public var adPods: [VastAdPod] = []
    
    // VAST 4.2 extensiones
    public var extensions: [VastExtension] = []
    
    // Validaciones para VAST 4.2
    public var isValid: Bool {
        return vastVersion.isSupported && !ads.isEmpty
    }
    
    public var supportsAudioCompanionAds: Bool {
        return vastVersion.supportsCompanionRenderingMode
    }
}

extension VastModel {
    public init(attrDict: [String: String]) {
        var version = ""
        for (key, value) in attrDict {
            switch key {
            case VastAttributes.version:
                version = value
            default:
                break
            }
        }
        self.version = version
        self.vastVersion = VastVersion(rawValue: version) ?? .unknown
    }
}

extension VastModel: Equatable {
    public static func == (lhs: VastModel, rhs: VastModel) -> Bool {
        return lhs.version == rhs.version &&
               lhs.vastVersion == rhs.vastVersion &&
               lhs.ads == rhs.ads &&
               lhs.errors == rhs.errors &&
               lhs.adPods == rhs.adPods
    }
    
    // Método para organizar anuncios en pods basados en su atributo sequence
    public mutating func organizeAdPods() {
        // Limpiar pods existentes
        self.adPods = []
        
        // Filtrar anuncios que tengan sequence
        let sequencedAds = ads.filter { $0.sequence != nil }
        
        // Si no hay anuncios con sequence, no hay pods que crear
        if sequencedAds.isEmpty {
            return
        }
        
        // Primero intentamos agrupar por podId explícito (VAST 4.2)
        var podsByExplicitId: [String: VastAdPod] = [:]
        
        // Agrupar anuncios con podId explícito
        for ad in sequencedAds.filter({ $0.podId != nil }) {
            guard let podId = ad.podId else { continue }
            
            let pod = podsByExplicitId[podId] ?? VastAdPod(podId: podId, podSize: ad.podSize)
            pod.addAd(ad)
            podsByExplicitId[podId] = pod
        }
        
        // Añadir pods explícitos a la lista final
        adPods.append(contentsOf: podsByExplicitId.values)
        
        // Para anuncios sin podId explícito, usar el enfoque basado en sequences
        let remainingAds = sequencedAds.filter { $0.podId == nil }
        if !remainingAds.isEmpty {
            // Agrupar anuncios por rango de secuencia (cada 100 valores)
            var podGroups: [Int: VastAdPod] = [:]
            
            for ad in remainingAds {
                guard let sequence = ad.sequence else { continue }
                
                // El identificador de pod se basa en el rango de sequence (cada 100)
                let podIdentifier = sequence / 100
                
                let pod = podGroups[podIdentifier] ?? VastAdPod(podSize: ad.podSize)
                pod.addAd(ad)
                podGroups[podIdentifier] = pod
            }
            
            // Añadir pods inferidos a la lista final
            adPods.append(contentsOf: podGroups.values)
        }
        
        // Ordenar los pods (opcional, dependiendo de la necesidad)
        // Esto podría ordenarse por algún criterio específico si es necesario
    }

    // Método auxiliar para obtener anuncios organizados
    public var organizedAds: [Any] {
        var result: [Any] = []
        
        // Añadir anuncios individuales (que no forman parte de pods)
        let individualAds = ads.filter { $0.sequence == nil }
        result.append(contentsOf: individualAds)
        
        // Añadir pods
        result.append(contentsOf: adPods)
        
        return result
    }
    
    // Método para obtener un pod por su ID
    public func getPod(byId podId: String) -> VastAdPod? {
        return adPods.first { $0.podId == podId }
    }
    
    // Método para obtener todos los anuncios en orden de reproducción
    public var allAdsInPlaybackOrder: [VastAd] {
        var result: [VastAd] = []
        
        // Primero los anuncios individuales (sin sequence)
        result.append(contentsOf: ads.filter { $0.sequence == nil })
        
        // Luego los anuncios de pods en orden
        for pod in adPods {
            result.append(contentsOf: pod.ads)
        }
        
        return result
    }
}
