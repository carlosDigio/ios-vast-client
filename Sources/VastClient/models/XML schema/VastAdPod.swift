//
//  VastAdPod.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

public class VastAdPod: Equatable, Encodable, Decodable {
    // Colección ordenada de anuncios en el pod
    private(set) public var ads: [VastAd] = []
    
    // Identificador único para el pod
    public var id: String = UUID().uuidString
    
    // Propiedades específicas para VAST 4.2
    public var podId: String?
    public var podSize: Int?
    public var maxPodDuration: TimeInterval?
    
    // Duración total del pod
    public var totalDuration: TimeInterval {
        return ads.compactMap { $0.podDuration }.reduce(0, +)
    }
    
    // Número total de anuncios en el pod
    public var count: Int {
        return ads.count
    }
    
    // Indica si el pod está completo (contiene todos los anuncios esperados)
    public var isComplete: Bool {
        return podSize != nil ? ads.count == podSize : true
    }
    
    public init(podId: String? = nil, podSize: Int? = nil, maxPodDuration: TimeInterval? = nil) {
        self.podId = podId
        self.podSize = podSize
        self.maxPodDuration = maxPodDuration
    }
    
    // Añadir un anuncio al pod
    public func addAd(_ ad: VastAd) {
        // Solo añadir si tiene sequence
        if ad.sequence != nil {
            // Si este anuncio tiene podId o podSize, actualizar las propiedades del pod
            if self.podId == nil && ad.podId != nil {
                self.podId = ad.podId
            }
            
            if self.podSize == nil && ad.podSize != nil {
                self.podSize = ad.podSize
            }
            
            ads.append(ad)
            // Ordenar por sequence
            ads.sort { ($0.sequence ?? 0) < ($1.sequence ?? 0) }
            
            // Actualizar las posiciones de los anuncios dentro del pod
            updatePodPositions()
        }
    }
    
    // Actualizar las posiciones de cada anuncio en el pod
    private func updatePodPositions() {
        for (index, var ad) in ads.enumerated() {
            // Las posiciones comienzan en 1
            ad.podPosition = index + 1
        }
    }
    
    // Obtener el siguiente anuncio en la secuencia
    public func nextAd(after currentAd: VastAd) -> VastAd? {
        guard let currentSequence = currentAd.sequence,
              let currentIndex = ads.firstIndex(where: { $0.sequence == currentSequence }) else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        return nextIndex < ads.count ? ads[nextIndex] : nil
    }
    
    // Verificar si el pod cumple con las restricciones de duración
    public func isWithinDurationLimit() -> Bool {
        guard let maxDuration = maxPodDuration else {
            return true
        }
        
        return totalDuration <= maxDuration
    }
    
    public static func == (lhs: VastAdPod, rhs: VastAdPod) -> Bool {
        lhs.id == rhs.id
    }
}
