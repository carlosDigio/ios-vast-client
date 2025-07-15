//
//  VastTrackingEvent.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

public enum TrackingEventType: String, Codable {
    // Eventos básicos VAST
    case firstQuartile
    case midpoint
    case thirdQuartile
    case complete
    case creativeView
    case start
    case mute
    case unmute
    case pause
    case rewind
    case resume
    case fullscreen
    case exitFullscreen
    case playerExpand
    case playerCollapse
    case acceptInvitationLinear
    case closeLinear
    case skip
    case progress
    case collapse
    case expand
    case acceptInvitation
    case close
    case overlayViewDuration
    case otherAdInteraction
    
    // VAST 4.2 - Nuevos eventos críticos para audio apps
    case loaded                    // Companion ad loaded (crítico para iVoox)
    case viewableImpression        // Viewability metrics
    case notViewable              // Not viewable tracking
    case viewUndetermined         // Viewability undetermined
    case playerCollapsed          // Player state changes
    case playerExpanded           // Player state changes
    case adExpand                 // Ad expansion
    case adCollapse               // Ad collapse
    case minimized                // Ad minimized
    case companionAdView          // Companion ad view (ideal para audio)
    case companionAdClick         // Companion ad interaction
    case iconView                 // Icon view tracking
    case iconClick                // Icon click tracking
    
    // Audio específicos
    case audioStart               // Audio playback start
    case audioFirstQuartile       // Audio 25% progress
    case audioMidpoint           // Audio 50% progress
    case audioThirdQuartile      // Audio 75% progress
    case audioComplete           // Audio playback complete
    
    case unknown
}

struct TrackingEventAttributes {
    static let event = "event"
    static let offset = "offset"
    static let playerSize = "playerSize"    // VAST 4.2
}

public struct VastTrackingEvent: Codable {
    public let type: TrackingEventType
    public let offset: Double?
    public let playerSize: String?          // VAST 4.2 nuevo atributo
    
    public var url: URL?
    public var tracked = false
}

extension VastTrackingEvent {
    public init(attrDict: [String: String]) {
        var type: TrackingEventType = .unknown
        var offset: Double?
        var playerSize: String?
        
        for (key, value) in attrDict {
            switch key {
            case TrackingEventAttributes.event:
                type = TrackingEventType(rawValue: value) ?? .unknown
            case TrackingEventAttributes.offset:
                offset = value.secondsFromVastOffset()
            case TrackingEventAttributes.playerSize:
                playerSize = value
            default:
                break
            }
        }
        
        self.type = type
        self.offset = offset
        self.playerSize = playerSize
    }
}

extension VastTrackingEvent: Equatable {}
