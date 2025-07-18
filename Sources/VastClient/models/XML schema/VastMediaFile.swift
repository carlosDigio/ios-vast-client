//
//  VastMediaFile.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

fileprivate enum MediaFileAttribute: String {
    case delivery
    case height
    case id
    case type
    case width
    case codec
    case bitrate
    case minBitrate
    case maxBitrate
    case scalable
    case maintainAspectRatio
    case apiFramework
    case audioCodec
    case sampleRate
    case channels
    case streamingDelivery
    case mimeType
    case mediaType
    case language
}

public struct VastMediaFile: Codable {
    public let delivery: String
    public let type: String
    public let width: String
    public let height: String
    public let codec: String?
    public let id: String?
    public let bitrate: Int?
    public let minBitrate: Int?
    public let maxBitrate: Int?
    public let scalable: Bool?
    public let maintainAspectRatio: Bool?
    public let apiFramework: String?
    
    // VAST 4.2 additions
    public let audioCodec: String?       // Codec for audio
    public let sampleRate: Int?          // Audio sample rate
    public let channels: Int?            // Number of audio channels
    public let streamingDelivery: String? // Type of streaming delivery
    public let mimeType: String?         // Explicit MIME type
    public let mediaType: String?        // Type of media (audio/video)
    public let language: String?         // Content language
    
    // content
    public var url: URL?
}

extension VastMediaFile {
    public init(attrDict: [String: String]) {
        var delivery = ""
        var height = ""
        var id = ""
        var type = ""
        var width = ""
        var codec: String?
        var bitrate: String?
        var minBitrate: String?
        var maxBitrate: String?
        var scalable: String?
        var maintainAspectRatio: String?
        var apiFramework: String?
        var audioCodec: String?
        var sampleRate: String?
        var channels: String?
        var streamingDelivery: String?
        var mimeType: String?
        var mediaType: String?
        var language: String?
        
        attrDict.compactMap { key, value -> (MediaFileAttribute, String)? in
            guard let newKey = MediaFileAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
            }.forEach { (key, value) in
                switch key {
                case .delivery:
                    delivery = value
                case .height:
                    height = value
                case .id:
                    id = value
                case .type:
                    type = value
                case .width:
                    width = value
                case .codec:
                    codec = value
                case .bitrate:
                    bitrate = value
                case .minBitrate:
                    minBitrate = value
                case .maxBitrate:
                    maxBitrate = value
                case .scalable:
                    scalable = value
                case .maintainAspectRatio:
                    maintainAspectRatio = value
                case .apiFramework:
                    apiFramework = value
                case .audioCodec:
                    audioCodec = value
                case .sampleRate:
                    sampleRate = value
                case .channels:
                    channels = value
                case .streamingDelivery:
                    streamingDelivery = value
                case .mimeType:
                    mimeType = value
                case .mediaType:
                    mediaType = value
                case .language:
                    language = value
                }
        }
        self.delivery = delivery
        self.height = height
        self.width = width
        self.id = id
        self.type = type
        self.codec = codec
        self.bitrate = bitrate?.intValue
        self.minBitrate = minBitrate?.intValue
        self.maxBitrate = maxBitrate?.intValue
        self.scalable = scalable?.boolValue
        self.maintainAspectRatio = maintainAspectRatio?.boolValue
        self.apiFramework = apiFramework
        self.audioCodec = audioCodec
        self.sampleRate = sampleRate?.intValue
        self.channels = channels?.intValue
        self.streamingDelivery = streamingDelivery
        self.mimeType = mimeType
        self.mediaType = mediaType
        self.language = language
    }
}

extension VastMediaFile: Equatable {
}
