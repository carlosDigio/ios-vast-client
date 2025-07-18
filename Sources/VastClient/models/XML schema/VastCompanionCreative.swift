//
//  VastCompanionCreative.swift
//  VastClient
//
//  Created by John Gainfort Jr on 6/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct CompanionElements {
    static let alttext = "AltText"
    static let companionclickthrough = "CompanionClickThrough"
    static let companionclicktracking = "CompanionClickTracking"
    static let trackingevents = "TrackingEvents"
    static let adparameters = "adparameters"
    static let htmlResource = "HTMLResource"
    static let iframeResource = "IFrameResource"
    static let staticResource = "StaticResource"
    
    // VAST 4.2 nuevos elementos
    static let universalAdId = "UniversalAdId"
    static let adVerifications = "AdVerifications"
}

struct CompanionAttributes {
    static let width = "width"
    static let height = "height"
    static let id = "id"
    static let assetwidth = "assetWidth"
    static let assetheight = "assetHeight"
    static let expandedwidth = "expandedWidth"
    static let expandedheight = "expandedHeight"
    static let apiframework = "apiFramework"
    static let adslotid = "adSlotId" //vast 3
    static let adslotid4 = "adSlotID" //vast 4
    static let pxRatio = "pxratio"
    
    // VAST 4.2 nuevos atributos
    static let renderingMode = "renderingMode"
    static let required = "required"
}

public struct VastCompanionClickTracking {
    public let id: String?
}

public struct VastCompanionCreative: Codable {
    // Attributes
    public let width: Int
    public let height: Int
    public let id: String?
    public let assetWidth: Int?
    public let assetHeight: Int?
    public let expandedWidth: Int?
    public let expandedHeight: Int?
    public let apiFramework: String?
    public let adSlotId: String?
    public let pxRatio: Double?
    
    // VAST 4.2 nuevos atributos
    public let renderingMode: VastCompanionRenderingMode?
    public let required: Bool?
    
    // Sub Elements
    public var staticResource: [VastStaticResource] = []
    public var iFrameResource: [URL] = []
    public var htmlResource: [URL] = []
    public var altText: String?
    public var companionClickThrough: URL?
    public var companionClickTracking: [URL] = []
    public var trackingEvents: [VastTrackingEvent] = []
    public var adParameters: VastAdParameters?
    
    // VAST 4.2 nuevos elementos
    public var universalAdId: VastUniversalAdId?
    public var adVerifications: VastAdVerifications?
}

extension VastCompanionCreative {
    public init(attrDict: [String: String]) {
        var width = 0
        var height = 0
        var id: String?
        var assetWidth: Int?
        var assetHeight: Int?
        var expandedWidth: Int?
        var expandedHeight: Int?
        var apiFramework: String?
        var adSlotId: String?
        var pxRatio: Double?
        
        // VAST 4.2 nuevas variables
        var renderingMode: VastCompanionRenderingMode?
        var required: Bool?

        for (key, value) in attrDict {
            switch key {
            case CompanionAttributes.width:
                width = Int(value) ?? 0
            case CompanionAttributes.height:
                height = Int(value) ?? 0
            case CompanionAttributes.id:
                id = value
            case CompanionAttributes.assetwidth:
                assetWidth = Int(value)
            case CompanionAttributes.assetheight:
                assetHeight = Int(value)
            case CompanionAttributes.expandedwidth:
                expandedWidth = Int(value)
            case CompanionAttributes.expandedheight:
                expandedHeight = Int(value)
            case CompanionAttributes.apiframework:
                apiFramework = value
            case CompanionAttributes.adslotid, CompanionAttributes.adslotid4:
                adSlotId = value
            case CompanionAttributes.pxRatio:
                pxRatio = Double(value)
            case CompanionAttributes.renderingMode:
                renderingMode = VastCompanionRenderingMode(rawValue: value)
            case CompanionAttributes.required:
                required = (value.lowercased() == "true")
            default:
                break
            }
        }

        self.width = width
        self.height = height
        self.id = id
        self.assetWidth = assetWidth
        self.assetHeight = assetHeight
        self.expandedWidth = expandedWidth
        self.expandedHeight = expandedHeight
        self.apiFramework = apiFramework
        self.adSlotId = adSlotId
        self.pxRatio = pxRatio
        self.renderingMode = renderingMode
        self.required = required
    }
}

extension VastCompanionCreative: Equatable {}

// VAST 4.2 - Enum para renderingMode específico para audio apps
public enum VastCompanionRenderingMode: String, Codable, CaseIterable {
    case concurrent = "concurrent"  // Mostrar durante el audio (ideal para iVoox)
    case endCard = "end-card"      // Mostrar al final del audio
    case overlay = "overlay"       // Superponer sobre el contenido
}
