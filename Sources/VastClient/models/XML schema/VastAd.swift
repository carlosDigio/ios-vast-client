//
//  VastAd.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct AdElements {
    static let wrapper = "Wrapper"
    static let inLine = "InLine"
    static let adSystem = "AdSystem"
    static let adTitle = "AdTitle"
    static let description = "Description"
    static let error = "Error"
    static let impression = "Impression"
    static let category = "Category"
    static let advertiser = "Advertiser"
    static let pricing = "Pricing"
    static let survey = "Survey"
    static let creatives = "Creatives"
    static let creative = "Creative"
    static let extensions = "Extensions"
    static let ext = "Extension"
    
    // VAST 4.2 nuevos elementos
    static let viewableImpression = "ViewableImpression"
    static let adVerifications = "AdVerifications"
    static let verification = "Verification" // Elemento añadido para la verificación de anuncios
    static let universalAdId = "UniversalAdId"
    static let blockedAdCategories = "BlockedAdCategories"
}

struct AdAttributes {
    static let id = "id"
    static let sequence = "sequence"
    static let conditionalAd = "conditionalAd"
    
    // VAST 4.2 nuevos atributos
    static let podId = "podId"
    static let podPosition = "podPosition"
    static let podDuration = "podDuration"
    static let podSize = "podSize"
    static let maxAds = "maxAds"
}

public enum AdType: String, Codable {
    case inline
    case wrapper
    case unknown
}

public struct VastAd: Codable {
    public let podId: String?
    public var podPosition: Int?
    public var podSize: Int?
    public var podDuration: TimeInterval?
    public let maxAds: Int?
    
    // Elements comunes
    public var id: String?
    public var conditionalAd: Bool?
    public var type: AdType
    public var adSystem: VastAdSystem?
    public var adTitle: String?
    public var description: String?
    public var sequence: Int?
    public var errors: [URL] = []
    public var impressions: [VastImpression] = []
    public var adCategories: [VastAdCategory] = []
    public var advertiser: String?
    public var pricing: VastPricing?
    public var surveys: [VastSurvey] = []
    public var creatives: [VastCreative] = []
    public var extensions: [VastExtension] = []
    
    // VAST 4.2 nuevos elementos
    public var viewableImpression: VastViewableImpression?
    public var adVerifications: [VastVerification] = []
    public var universalAdId: VastUniversalAdId?
    public var blockedAdCategories: [VastBlockedAdCategory] = []
    public var icons: [VastIcon] = []
    public var mezzanine: URL?
    public var expires: TimeInterval?
    
    // Wrapper específico
    public var wrapper: VastWrapper?
    
    // Propiedades para seguimiento e interacción
    public var followAdditionalWrappers: Bool?
    public var allowMultipleAds: Bool?
    public var fallbackOnNoAd: Bool?
}

extension VastAd {
    public init(attrDict: [String: String]) {
        var id: String?
        var sequence: Int?
        var conditionalAd: Bool?
        var podId: String?
        var podPosition: Int?
        var podDuration: TimeInterval?
        var maxAds: Int?
        
        for (key, value) in attrDict {
            switch key {
            case AdAttributes.id:
                id = value
            case AdAttributes.sequence:
                sequence = Int(value)
            case AdAttributes.conditionalAd:
                conditionalAd = (value.lowercased() == "true")
            case AdAttributes.podId:
                podId = value
            case AdAttributes.podPosition:
                podPosition = Int(value)
            case AdAttributes.podDuration:
                podDuration = TimeInterval(value)
            case AdAttributes.maxAds:
                maxAds = Int(value)
            default:
                break
            }
        }
        
        self.id = id
        self.sequence = sequence
        self.conditionalAd = conditionalAd
        self.podId = podId
        self.podPosition = podPosition
        self.podDuration = podDuration
        self.maxAds = maxAds
        self.type = .unknown
    }
}

extension VastAd: Equatable {}
