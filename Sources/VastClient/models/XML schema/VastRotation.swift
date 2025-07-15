//
//  VastRotation.swift
//  VastClient
//
//  Created by Jan Bednar on 12/11/2018.
//

import Foundation

public struct VastRotation: Codable, Equatable {
    public enum RotationType: String, Codable {
        case none
        case normal
        case sequence
    }

    public let type: RotationType

    public init(type: String?) {
        if let typeStr = type?.lowercased() {
            self.type = RotationType(rawValue: typeStr) ?? .none
        } else {
            self.type = .none
        }
    }
}
