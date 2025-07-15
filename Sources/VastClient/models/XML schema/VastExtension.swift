//
//  VastExtension.swift
//  VastClient
//
//  Created for VAST 4.2 Compliance
//  Copyright © 2025 iVoox. All rights reserved.
//

import Foundation

struct ExtensionAttributes {
    static let type = "type"
}

struct ExtensionElements {
    static let creativeparameters = "CreativeParameters"
    static let creativeparameter = "CreativeParameter"
    
    // VAST 4.2 nuevos elementos para extensiones
    static let customTracking = "CustomTracking"
    static let playerState = "PlayerState"
    static let content = "Content"
}

/// Modelo para extensiones en VAST 4.2
/// Las extensiones permiten incluir funcionalidades personalizadas o integraciones con sistemas propietarios
public struct VastExtension: Codable {
    // Atributos básicos
    public let type: String?
    
    // Elementos
    public var creativeParameters = [VastCreativeParameter]()
    public var content: String?
    
    // VAST 4.2 elementos específicos para audio
    public var customTracking: [URL] = []
    public var playerState: VastPlayerState?
    
    // Elementos adicionales que pueden ser útiles para iVoox
    public var isAudioExtension: Bool {
        return type?.lowercased().contains("audio") ?? false
    }
    
    public var isAnalyticsExtension: Bool {
        return type?.lowercased().contains("analytics") ?? false
    }
}

/// Enum que representa los diferentes estados del reproductor de audio
/// Útil para tracking avanzado en aplicaciones como iVoox
public enum VastPlayerState: String, Codable {
    case playing = "playing"
    case paused = "paused"
    case stopped = "stopped"
    case buffering = "buffering"
    case fullscreen = "fullscreen"
    case minimized = "minimized"
    case collapsed = "collapsed"
    case expanded = "expanded"
    case normal = "normal"
}

extension VastExtension {
    public init(attrDict: [String: String]) {
        var type: String?
        
        for (key, value) in attrDict {
            switch key {
            case ExtensionAttributes.type:
                type = value
            default:
                break
            }
        }
        
        self.type = type
    }
}

extension VastExtension: Equatable {
    public static func == (lhs: VastExtension, rhs: VastExtension) -> Bool {
        return lhs.type == rhs.type
    }
}