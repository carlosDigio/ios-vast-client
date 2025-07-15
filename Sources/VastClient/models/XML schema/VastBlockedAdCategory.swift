//
//  VastBlockedAdCategory.swift
//  VastClient
//
//  Created by GitHub Copilot on 7/14/2025.
//  Copyright © 2025 iVoox. All rights reserved.
//

import Foundation

/// Estructura que representa una categoría de anuncio bloqueada en VAST 4.2
/// Las categorías bloqueadas permiten a los publishers especificar qué tipos de anuncios no deberían servirse
public struct VastBlockedAdCategory: Codable, Equatable {
    /// El valor de la categoría bloqueada
    public let value: String
    
    /// El esquema de autoridad que define la taxonomía de la categoría
    /// Por ejemplo: "IAB" para el esquema de IAB Tech Lab
    public let authority: String?
    
    public init(value: String, authority: String? = nil) {
        self.value = value
        self.authority = authority
    }
}

// Extensión para inicializar desde un diccionario de atributos (XML)
extension VastBlockedAdCategory {
    public init(attrDict: [String: String], value: String? = nil) {
        var authority: String?
        
        // La autoridad suele aparecer como un atributo "authority" en el XML
        if let authorityValue = attrDict["authority"] {
            authority = authorityValue
        }
        
        self.authority = authority
        self.value = value ?? ""
    }
}