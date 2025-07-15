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
}

public struct VastNonLinear: Codable {
    public var height: String
    public var id: String
    public var width: String
    
    public var staticResource: VastStaticResource?
    public var nonLinearClickTracking: URL?
    public var nonLinearClickThrough: URL?
}

extension VastNonLinear {
    public init(attrDict: [String: String]) {
        var height = ""
        var id = ""
        var width = ""
        var nonLinearClickTracking: URL?
        var nonLinearClickThrough: URL?
        
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
                }
        }
        self.height = height
        self.id = id
        self.width = width
        self.nonLinearClickTracking = nonLinearClickTracking
        self.nonLinearClickThrough = nonLinearClickThrough
    }
}

extension VastNonLinear: Equatable {
}
