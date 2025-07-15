//
//  VastHelper.swift
//  VastClient
//
//  Created for VAST 4.2 Compliance
//  Copyright © 2025 iVoox. All rights reserved.
//

import Foundation

// Clase helper para testing y validación de VAST 4.2
public class VastHelper {
    
    // Singleton
    public static let shared = VastHelper()
    private init() {}
    
    // Verificar si un VAST soporta companion ads para audio
    public func supportsAudioCompanions(_ vastModel: VastModel) -> Bool {
        // Verificar versión compatible
        guard vastModel.version == "4.2" || vastModel.version == "4.1" else {
            return false
        }
        
        // Buscar companion ads con renderingMode apropiado para audio
        for ad in vastModel.ads {
            for creative in ad.creatives {
                if let companionAds = creative.companionAds {
                    for companion in companionAds.companions {
                        // Companion con renderingMode adecuado para audio
                        if companion.renderingMode == .concurrent || 
                           companion.renderingMode == .endCard {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    // Obtener companion ads adecuados para audio
    public func getAudioCompanionAds(from vastModel: VastModel) -> [VastCompanionCreative] {
        var companions: [VastCompanionCreative] = []
        
        for ad in vastModel.ads {
            for creative in ad.creatives {
                if let companionAds = creative.companionAds {
                    for companion in companionAds.companions {
                        // Filtrar solo companions adecuados para audio
                        if companion.renderingMode == .concurrent || 
                           companion.renderingMode == .endCard {
                            companions.append(companion)
                        }
                    }
                }
            }
        }
        
        return companions
    }
    
    // Generar un documento VAST 4.2 de ejemplo para audio
    public func generateAudioVastExample() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <VAST version="4.2">
          <Ad id="20001">
            <InLine>
              <AdSystem version="1.0">iVoox Audio Ads</AdSystem>
              <AdTitle>Anuncio de Audio con Companion</AdTitle>
              <Impression><![CDATA[https://impression.example.com/track?imp=1]]></Impression>
              <Creatives>
                <Creative id="5480" sequence="1">
                  <Linear>
                    <Duration>00:00:30</Duration>
                    <TrackingEvents>
                      <Tracking event="start"><![CDATA[https://example.com/track/start]]></Tracking>
                      <Tracking event="audioStart"><![CDATA[https://example.com/track/audio-start]]></Tracking>
                      <Tracking event="audioFirstQuartile"><![CDATA[https://example.com/track/audio-q1]]></Tracking>
                      <Tracking event="audioMidpoint"><![CDATA[https://example.com/track/audio-mid]]></Tracking>
                      <Tracking event="audioThirdQuartile"><![CDATA[https://example.com/track/audio-q3]]></Tracking>
                      <Tracking event="audioComplete"><![CDATA[https://example.com/track/audio-complete]]></Tracking>
                    </TrackingEvents>
                    <MediaFiles>
                      <MediaFile id="1" delivery="progressive" type="audio/mpeg" bitrate="128" width="0" height="0">
                        <![CDATA[https://example.com/audio/sample.mp3]]>
                      </MediaFile>
                    </MediaFiles>
                  </Linear>
                </Creative>
                <Creative id="5480-companion" sequence="1">
                  <CompanionAds>
                    <Companion width="300" height="250" renderingMode="concurrent" required="false">
                      <StaticResource creativeType="image/jpeg">
                        <![CDATA[https://example.com/companion/300x250.jpg]]>
                      </StaticResource>
                      <TrackingEvents>
                        <Tracking event="companionAdView"><![CDATA[https://example.com/track/companion-view]]></Tracking>
                      </TrackingEvents>
                      <CompanionClickThrough>
                        <![CDATA[https://example.com/click]]>
                      </CompanionClickThrough>
                      <AdVerifications>
                        <Verification vendor="moat">
                          <JavaScriptResource>
                            <![CDATA[https://verification.example.com/moat.js]]>
                          </JavaScriptResource>
                        </Verification>
                      </AdVerifications>
                    </Companion>
                  </CompanionAds>
                </Creative>
              </Creatives>
            </InLine>
          </Ad>
        </VAST>
        """
    }
    
    // Verificar compatibilidad con iVoox
    public func isCompatibleWithIVoox(_ vastModel: VastModel) -> Bool {
        // iVoox necesita companion ads específicos para audio
        return supportsAudioCompanions(vastModel)
    }
    
    // Obtener string de diagnóstico
    public func getDiagnosticInfo(_ vastModel: VastModel) -> String {
        var info = "VAST Versión: \(vastModel.version)\n"
        info += "Anuncios: \(vastModel.ads.count)\n"
        
        // Contar companion ads por tipo
        var concurrentCompanions = 0
        var endCardCompanions = 0
        var overlayCompanions = 0
        
        for ad in vastModel.ads {
            for creative in ad.creatives {
                if let companionAds = creative.companionAds {
                    for companion in companionAds.companions {
                        switch companion.renderingMode {
                        case .concurrent:
                            concurrentCompanions += 1
                        case .endCard:
                            endCardCompanions += 1
                        case .overlay:
                            overlayCompanions += 1
                        case .none:
                            break
                        }
                    }
                }
            }
        }
        
        info += "Companion ads (concurrent): \(concurrentCompanions)\n"
        info += "Companion ads (end-card): \(endCardCompanions)\n"
        info += "Companion ads (overlay): \(overlayCompanions)\n"
        
        return info
    }
}