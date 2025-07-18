//
//  VastNonLinear.swift
//  VastClient
//
//  Created by Austin Christensen on 9/4/19.
//  Copyright © 2019 John Gainfort Jr. All rights reserved.
//

import Foundation

fileprivate enum NonLinearAttribute: String {
    case height
    case id
    case width
    case nonLinearClickTracking
    case nonLinearClickThrough
    
    // VAST 4.3 Attributes
    case expandedWidth
    case expandedHeight
    case scalable
    case maintainAspectRatio
    case minSuggestedDuration
    case apiFramework
    case adServingId
    case pxratio
    case renderingMode
}

public struct VastNonLinear: Codable {
    public var height: String
    public var id: String
    public var width: String
    
    public var staticResource: VastStaticResource?
    public var htmlResource: URL?
    public var iFrameResource: URL?
    public var nonLinearClickTracking: URL?
    public var nonLinearClickThrough: URL?
    
    // VAST 4.3 additions
    public var expandedWidth: String?
    public var expandedHeight: String?
    public var scalable: Bool?
    public var maintainAspectRatio: Bool?
    public var minSuggestedDuration: String?
    public var apiFramework: String?
    public var adServingId: String?
    public var pxratio: Float?
    public var renderingMode: String?
    
    // Ad Parameters (VAST 4.3)
    public var adParameters: String?
    public var adParametersXmlEncoded: Bool?
    
    // Additional tracking events specific to non-linear ad (VAST 4.3)
    public var trackingEvents: [VastTrackingEvent] = []
    
    // Alternate text for accessibility (VAST 4.3)
    public var altText: String?
    
    // Additional verification resources (VAST 4.3)
    public var adVerifications: [VastVerification] = []
}

extension VastNonLinear {
    public init(attrDict: [String: String]) {
        var height = ""
        var id = ""
        var width = ""
        var nonLinearClickTracking: URL?
        var nonLinearClickThrough: URL?
        
        // VAST 4.3 attributes
        var expandedWidth: String?
        var expandedHeight: String?
        var scalable: Bool?
        var maintainAspectRatio: Bool?
        var minSuggestedDuration: String?
        var apiFramework: String?
        var adServingId: String?
        var pxratio: Float?
        var renderingMode: String?
        
        attrDict.compactMap { key, value -> (NonLinearAttribute, String)? in
            guard let newKey = NonLinearAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
            }.forEach { (key, value) in
                switch key {
                case .height:
                    height = value
                case .id:
                    id = value
                case .width:
                    width = value
                case .nonLinearClickThrough:
                    nonLinearClickThrough = URL(string: value)
                case .nonLinearClickTracking:
                    nonLinearClickTracking = URL(string: value)
                case .expandedWidth:
                    expandedWidth = value
                case .expandedHeight:
                    expandedHeight = value
                case .scalable:
                    scalable = value.boolValue
                case .maintainAspectRatio:
                    maintainAspectRatio = value.boolValue
                case .minSuggestedDuration:
                    minSuggestedDuration = value
                case .apiFramework:
                    apiFramework = value
                case .adServingId:
                    adServingId = value
                case .pxratio:
                    pxratio = Float(value)
                case .renderingMode:
                    renderingMode = value
                }
        }
        self.height = height
        self.id = id
        self.width = width
        self.nonLinearClickTracking = nonLinearClickTracking
        self.nonLinearClickThrough = nonLinearClickThrough
        
        // Assign VAST 4.3 attributes
        self.expandedWidth = expandedWidth
        self.expandedHeight = expandedHeight
        self.scalable = scalable
        self.maintainAspectRatio = maintainAspectRatio
        self.minSuggestedDuration = minSuggestedDuration
        self.apiFramework = apiFramework
        self.adServingId = adServingId
        self.pxratio = pxratio
        self.renderingMode = renderingMode
    }
}

extension VastNonLinear: Equatable {
    public static func == (lhs: VastNonLinear, rhs: VastNonLinear) -> Bool {
        return lhs.id == rhs.id &&
               lhs.width == rhs.width &&
               lhs.height == rhs.height &&
               lhs.staticResource == rhs.staticResource &&
               lhs.htmlResource == rhs.htmlResource &&
               lhs.iFrameResource == rhs.iFrameResource &&
               lhs.nonLinearClickTracking == rhs.nonLinearClickTracking &&
               lhs.nonLinearClickThrough == rhs.nonLinearClickThrough &&
               lhs.expandedWidth == rhs.expandedWidth &&
               lhs.expandedHeight == rhs.expandedHeight &&
               lhs.scalable == rhs.scalable &&
               lhs.maintainAspectRatio == rhs.maintainAspectRatio &&
               lhs.minSuggestedDuration == rhs.minSuggestedDuration &&
               lhs.apiFramework == rhs.apiFramework &&
               lhs.adServingId == rhs.adServingId &&
               lhs.pxratio == rhs.pxratio &&
               lhs.renderingMode == rhs.renderingMode &&
               lhs.adParameters == rhs.adParameters &&
               lhs.adParametersXmlEncoded == rhs.adParametersXmlEncoded &&
               lhs.altText == rhs.altText &&
               lhs.trackingEvents == rhs.trackingEvents &&
               lhs.adVerifications == rhs.adVerifications
    }
}
