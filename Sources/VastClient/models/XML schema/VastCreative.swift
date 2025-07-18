//
//  VastCreative.swift
//  VastClient
//
//  Created by Jan Bednar on 13/11/2018.
//

import Foundation

struct VastCreativeElements {
    static let universalAdId = "UniversalAdId"
    static let linear = "Linear"
    static let nonLinearAds = "NonLinearAds"
    static let creativeExtension = "CreativeExtension"
    static let companionAds = "CompanionAds"
    
    // VAST 4.x Elements
    static let adVerifications = "AdVerifications"
    // Corrected to support VAST 4.2 SIMID specification.
    static let interactiveCreativeFile = "InteractiveCreativeFile"
    static let supplementalAdVerification = "SupplementalAdVerification"
}

fileprivate enum VastCreativeAttribute: String, CaseIterable {
    case id
    case adId
    case sequence
    case apiFramework
    
    // VAST 4.3 Attributes
    case adServingId
    case universalAdIdRegistry
    case universalAdIdValue
    case creativeType
    
    // Vast 2.0 adId tag is "AdID" instead of adId
    init?(rawValue: String) {
        guard let value = VastCreativeAttribute.allCases.first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) else {
            return nil
        }
        self = value
    }
}

public struct VastCreative: Codable {
    public let id: String?
    public let adId: String?
    public let sequence: Int?
    public let apiFramework: String?
    
    public var universalAdId: VastUniversalAdId?
    public var creativeExtensions: [VastCreativeExtension] = []
    public var linear: VastLinearCreative?
    public var nonLinearAds: VastNonLinearAdsCreative?
    public var companionAds: VastCompanionAds?
    public var rotation: VastRotation?
    
    // VAST 4.2 elements
    public var adVerifications: VastAdVerifications?
    // Corrected property to support VAST 4.2 SIMID.
    // The 'VastInteractiveCreative' type was incorrect and did not exist.
    // It now uses 'VastInteractiveCreativeFile' which is the correct model.
    public var interactiveCreativeFile: VastInteractiveCreativeFile?
    
    // Nuevos atributos VAST 4.3
    public let adServingId: String?
    public let creativeType: String?
    public var supplementalAdVerifications: [VastSupplementalAdVerification]?
    
    // Metadatos específicos de VAST 4.3
    public var creativeDimensions: VastCreativeDimensions?
    public var creativeBehaviors: [VastCreativeBehavior]?
    
    // MediaFiles específicos a nivel de creative (VAST 4.3)
    public var creativeMediaFiles: [VastCreativeMediaFile]?
    
    // Tracking específico a nivel de creative (VAST 4.3)
    public var creativeTrackingEvents: [VastTrackingEvent]?
}

/// Dimensions for creative (VAST 4.3)
public struct VastCreativeDimensions: Codable, Equatable {
    public let width: Int
    public let height: Int
    public let expandedWidth: Int?
    public let expandedHeight: Int?
    
    public init(width: Int, height: Int, expandedWidth: Int? = nil, expandedHeight: Int? = nil) {
        self.width = width
        self.height = height
        self.expandedWidth = expandedWidth
        self.expandedHeight = expandedHeight
    }
}

/// Creative behavior metadata (VAST 4.3)
public struct VastCreativeBehavior: Codable, Equatable {
    public let type: String
    public let value: String
    
    // Computed properties for common behavior types according to VAST 4.3 spec
    public var boolValue: Bool? {
        switch value.lowercased() {
        case "true", "1", "yes":
            return true
        case "false", "0", "no":
            return false
        default:
            return nil
        }
    }
    
    public var intValue: Int? {
        return Int(value)
    }
    
    public var doubleValue: Double? {
        return Double(value)
    }
    
    // Common behavior types defined in VAST 4.3
    public enum BehaviorType: String, CaseIterable {
        case closeable = "closeable"
        case userInitiated = "user-initiated"
        case expandable = "expandable"
        case resizable = "resizable"
        case autoplay = "autoplay"
        case muted = "muted"
        case skippable = "skippable"
        case fullscreen = "fullscreen"
        case pausable = "pausable"
        case minimizable = "minimizable"
        case accessibility = "accessibility"
        case viewability = "viewability"
        case completion = "completion"
        case interaction = "interaction"
    }
    
    public var behaviorType: BehaviorType? {
        return BehaviorType(rawValue: type)
    }
    
    public init(type: String, value: String) {
        self.type = type
        self.value = value
    }
    
    // Convenience initializers for common behavior patterns
    public init(type: BehaviorType, boolValue: Bool) {
        self.type = type.rawValue
        self.value = boolValue ? "true" : "false"
    }
    
    public init(type: BehaviorType, intValue: Int) {
        self.type = type.rawValue
        self.value = String(intValue)
    }
    
    public init(type: BehaviorType, doubleValue: Double) {
        self.type = type.rawValue
        self.value = String(doubleValue)
    }
}

/// Media file specific to creative level (VAST 4.3)
public struct VastCreativeMediaFile: Codable, Equatable {
    public let url: URL?
    public let delivery: String
    public let type: String
    public let width: Int
    public let height: Int
    public let codec: String?
    public let id: String?
    public let fileSize: Int?
    public let mediaType: String?
    
    public init(url: URL?, delivery: String, type: String, width: Int, height: Int,
                codec: String? = nil, id: String? = nil, fileSize: Int? = nil, mediaType: String? = nil) {
        self.url = url
        self.delivery = delivery
        self.type = type
        self.width = width
        self.height = height
        self.codec = codec
        self.id = id
        self.fileSize = fileSize
        self.mediaType = mediaType
    }
}

extension VastCreative {
    public init(attrDict: [String: String]) {
        var id: String?
        var adId: String?
        var sequence: String?
        var apiFramework: String?
        var adServingId: String?
        var creativeType: String?
        
        attrDict.compactMap { key, value -> (VastCreativeAttribute, String)? in
            guard let newKey = VastCreativeAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
            }.forEach { (key, value) in
                switch key {
                case .id:
                    id = value
                case .adId:
                    adId = value
                case .sequence:
                    sequence = value
                case .apiFramework:
                    apiFramework = value
                case .adServingId:
                    adServingId = value
                case .creativeType:
                    creativeType = value
                default:
                    break
                }
        }
        self.id = id
        self.adId = adId
        self.sequence = sequence?.intValue
        self.apiFramework = apiFramework
        self.adServingId = adServingId
        self.creativeType = creativeType
        
        if let rotationType = attrDict["rotation"] {
            self.rotation = VastRotation(type: rotationType)
        }
    }
}

extension VastCreative: Equatable {}
