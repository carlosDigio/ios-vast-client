//
//  VastBlockedAdCategories.swift
//  VastClient
//
//  Created for VAST 4.2 Compliance
//  Copyright © 2025 iVoox. All rights reserved.
//

import Foundation

struct BlockedAdCategoriesElements {
    static let category = "Category"
}

// VAST 4.2 - BlockedAdCategories para filtrado de contenido
public struct VastBlockedAdCategories: Codable {
    public var categories: [VastAdCategory] = []
}

extension VastBlockedAdCategories: Equatable {}