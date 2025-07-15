//
//  String+VastSeconds.swift
//  VastClient
//
//  Created for VAST 4.2 Compliance
//  Copyright © 2025 iVoox. All rights reserved.
//

import Foundation

extension String {
    // VAST 4.2 - Parser mejorado para offset de tiempo
    func secondsFromVastOffset() -> Double? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Formato de porcentaje (ej: "25%")
        if trimmed.hasSuffix("%") {
            let percentageString = String(trimmed.dropLast())
            if let percentage = Double(percentageString) {
                return percentage / 100.0  // Retorna como fracción para usar con duración total
            }
        }
        
        // Formato de tiempo HH:MM:SS.mmm
        if trimmed.contains(":") {
            let components = trimmed.components(separatedBy: ":")
            guard components.count >= 2 else { return nil }
            
            var totalSeconds: Double = 0
            let reversedComponents = components.reversed()
            
            // Segundos (puede incluir milisegundos)
            if let seconds = Double(reversedComponents.first ?? "0") {
                totalSeconds += seconds
            }
            
            // Minutos
            if reversedComponents.count > 1,
               let minutes = Double(Array(reversedComponents)[1]) {
                totalSeconds += minutes * 60
            }
            
            // Horas
            if reversedComponents.count > 2,
               let hours = Double(Array(reversedComponents)[2]) {
                totalSeconds += hours * 3600
            }
            
            return totalSeconds
        }
        
        // Formato simple de segundos (ej: "15", "30.5")
        return Double(trimmed)
    }
}