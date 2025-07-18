//
//  VastMediaFiles.swift
//  VastClient
//
//  Created by Jan Bednar on 13/11/2018.
//

import Foundation

public struct VastMediaFiles: Codable {
    public var mediaFiles: [VastMediaFile] = []
}

extension VastMediaFiles: Equatable {
}
