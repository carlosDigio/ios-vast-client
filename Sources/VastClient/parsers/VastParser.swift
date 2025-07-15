//
//  VastParser.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

/**
 Vast Parser
 
 Use this parser to receive final unwrapped VastModel.
 
 When wrapper VAST response is received it recursively fetches the file specified in VastAdTagURI element and flattens the responses
 */
class VastParser {
    
    let options: VastClientOptions
    
    // for testing of local files only
    private let testFileBundle: Bundle?
    private let queue: DispatchQueue
    
    init(options: VastClientOptions, queue: DispatchQueue = DispatchQueue.init(label: "parser", qos: .userInitiated), testFileBundle: Bundle? = nil) {
        self.options = options
        self.queue = queue
        self.testFileBundle = testFileBundle
    }
    
    private var completion: ((VastModel?, Error?) -> ())?
    
    private func finish(vastModel: VastModel?, error: Error?) {
        DispatchQueue.main.async {
            self.completion?(vastModel, error)
            self.completion = nil
        }
    }
    
    func parse(url: URL, completion: @escaping (VastModel?, Error?) -> ()) {
        self.completion = completion
        let timer = Timer.scheduledTimer(withTimeInterval: options.timeLimit, repeats: false) { [weak self] _ in
            self?.finish(vastModel: nil, error: VastError.wrapperTimeLimitReached)
        }
        queue.async {
            do {
                let vastModel = try self.internalParse(url: url)
                timer.invalidate()
                self.finish(vastModel: vastModel, error: nil)
            } catch {
                timer.invalidate()
                self.finish(vastModel: nil, error: error)
            }
        }
    }
    
    private func internalParse(url: URL, count: Int = 0) throws -> VastModel {
        guard count < options.wrapperLimit else {
            throw VastError.wrapperLimitReached
        }
        let parser = VastXMLParser()
        
        var vm: VastModel
        if url.scheme?.contains("test") ?? false, let bundle = testFileBundle {
            let filename = url.absoluteString.replacingOccurrences(of: "test://", with: "")
            let filepath = bundle.path(forResource: filename, ofType: "xml")!
            let url = URL(fileURLWithPath: filepath)
            vm = try internalParse(url: url)
        } else {
            vm = try parser.parse(url: url)
        }
        
        let flattenedVastAds = unwrap(vm: vm, count: count)
        vm.ads = flattenedVastAds
        
        processAdPods(vastModel: &vm)
        
        return vm
    }
    
    // Método para procesar y organizar Ad Pods
    private func processAdPods(vastModel: inout VastModel) {
        // Agrupar anuncios por Ad Pod
        var adPods: [String: [VastAd]] = [:]
        
        // Filtrar anuncios que pertenecen a Ad Pods (tienen sequence)
        let podAds = vastModel.ads.filter { $0.sequence != nil }
        let nonPodAds = vastModel.ads.filter { $0.sequence == nil }
        
        // Agrupar por adId (los anuncios del mismo Pod deben compartir el mismo adId)
        for ad in podAds {
            if let adId = ad.id {
                if adPods[adId] == nil {
                    adPods[adId] = [ad]
                } else {
                    adPods[adId]?.append(ad)
                }
            }
        }
        
        // Ordenar anuncios dentro de cada Pod por sequence
        for (podId, ads) in adPods {
            adPods[podId] = ads.sorted { ($0.sequence ?? 0) < ($1.sequence ?? 0) }
        }
        
        // Actualizar el modelo con los Ad Pods ordenados
        var newAds: [VastAd] = nonPodAds
        
        // Añadir los anuncios de los Pods ordenados
        for (_, ads) in adPods {
            newAds.append(contentsOf: ads)
            
            // Añadir metadatos de Pod a los anuncios
            if ads.count > 0 {
                for i in 0..<ads.count {
                    var ad = ads[i]
                    ad.podPosition = i + 1
                    ad.podSize = ads.count
                    
                    // Calcular tiempo total del Pod si es posible
                    let totalDuration = ads.compactMap { $0.podDuration }.reduce(0, +)
                    if totalDuration > 0 {
                        ad.podDuration = totalDuration
                    }
                    
                    // Actualizar el anuncio en el array
                    if let index = newAds.firstIndex(where: { $0.id == ad.id && $0.sequence == ad.sequence }) {
                        newAds[index] = ad
                    }
                }
            }
        }
        
        // Actualizar los anuncios en el modelo
        vastModel.ads = newAds
    }
    
    // Método para determinar si un anuncio es parte de un Ad Pod
    private func isPartOfAdPod(_ ad: VastAd) -> Bool {
        return ad.sequence != nil
    }
    
    // Método para calcular metadatos adicionales de Ad Pod
    private func calculateAdPodMetadata(forAd ad: inout VastAd, inPod podAds: [VastAd]) {
        guard let sequence = ad.sequence, !podAds.isEmpty else { return }
        
        // Posición en el Pod (1-indexed)
        ad.podPosition = Int(sequence)
        
        // Tamaño total del Pod
        ad.podSize = podAds.count
        
        // Duración total del Pod
        let totalDuration = podAds.compactMap { $0.podDuration }.reduce(0, +)
        if totalDuration > 0 {
            ad.podDuration = totalDuration
        }
    }
    
    func unwrap(vm: VastModel, count: Int) -> [VastAd] {
        return vm.ads.map { ad -> VastAd in
            var copiedAd = ad
            
            guard ad.type == .wrapper, let wrapperUrl = ad.wrapper?.adTagUri else { return ad }
            
            do {
                let wrapperModel = try internalParse(url: wrapperUrl, count: count + 1)
                wrapperModel.ads.forEach { wrapperAd in
                    if let adSystem = wrapperAd.adSystem {
                        copiedAd.adSystem = adSystem
                    }
                    
                    if let title = wrapperAd.adTitle, !title.isEmpty {
                        copiedAd.adTitle = title
                    }
                    
                    if !wrapperAd.errors.isEmpty {
                        copiedAd.errors = wrapperAd.errors
                    }
                    
                    if wrapperAd.type != AdType.unknown {
                        copiedAd.type = wrapperAd.type
                    }
                    
                    copiedAd.impressions.append(contentsOf: wrapperAd.impressions)
                    
                    var copiedCreatives = copiedAd.creatives
                    for (idx, creative) in copiedCreatives.enumerated() {
                        var creative = creative
                        if idx < wrapperAd.creatives.count {
                            let wrapperCreative = wrapperAd.creatives[idx]
                            
                            // Copy values from previous wrappers
                            if let linear = wrapperCreative.linear {
                                creative.linear?.duration = linear.duration
                                creative.linear?.files.mediaFiles.append(contentsOf: linear.files.mediaFiles)
                                creative.linear?.files.interactiveCreativeFiles.append(contentsOf: linear.files.interactiveCreativeFiles)
                                creative.linear?.trackingEvents.append(contentsOf: linear.trackingEvents)
                                creative.linear?.icons.append(contentsOf: linear.icons)
                                creative.linear?.videoClicks.append(contentsOf: linear.videoClicks)
                            }
                            
                            if let companionAds = wrapperCreative.companionAds {
                                if creative.companionAds == nil {
                                    creative.companionAds = companionAds
                                } else {
                                    creative.companionAds?.companions.append(contentsOf: companionAds.companions)
                                }
                            }
                        }
                        copiedCreatives[idx] = creative
                    }
                    
                    copiedAd.creatives = copiedCreatives
                    copiedAd.extensions.append(contentsOf: wrapperAd.extensions)
                }
            } catch {
                print("Unable to unwrap wrapper")
            }
            return copiedAd
        }
    }
    
}
