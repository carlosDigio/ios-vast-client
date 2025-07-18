//
//  VastParser.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation
/**
 Basic Vast 4.0 XML schema complient parser
 
 Use this class to parse VAST model from single VAST XML file
 */
class VastXMLParser: NSObject {
    // allows other xml parsing delegates to use this class's delegate to parse a VastModel out of a much larger XML document
    var completeClosure: ((_ error: Error?, _ vastModel: VastModel) -> Void)?

    var xmlParser: XMLParser?
    var validVastDocument = false
    var parsedFirstElement = false
    var fatalError: Error?

    var vastModel: VastModel?

    var currentVastAd: VastAd?
    var currentWrapper: VastWrapper?
    var currentAdSystem: VastAdSystem?
    var currentVastImpression: VastImpression?
    
    var currentVastCategory: VastAdCategory?
    var currentVastPricing: VastPricing?
    var currentSurvey: VastSurvey?
    var currentViewableImpression: VastViewableImpression?
    var currentVerification: VastVerification?
    var currentAdVerifications: VastAdVerifications?
    var currentResource: VastResource?
    var currentVerificationViewableImpression: VastViewableImpression?
    var currentAdVerificationParameters: VastAdVerificationParameters?
    
    var currentCreative: VastCreative?
    
    var currentLinearCreative: VastLinearCreative?
    var currentNonLinearAdsCreative: VastNonLinearAdsCreative?
    var currentNonLinear: VastNonLinear?
    var currentUniversalAdId: VastUniversalAdId?
    var currentCreativeExtension: VastCreativeExtension?
    var currentTrackingEvent: VastTrackingEvent?
    var currentVideoClick: VastVideoClick?
    var currentMediaFile: VastMediaFile?
    var currentInteractiveCreativeFile: VastInteractiveCreativeFile?
    var currentIcon: VastIcon?
    var currentStaticResource: VastStaticResource?
    var currentIconClickTracking: VastIconClickTracking?
    var currentVastExtension: VastExtension?
    var currentAdParameters: VastAdParameters?
    var creativeParameters = [VastCreativeParameter]()
    var currentCreativeParameter: VastCreativeParameter?
    var currentCondition: VastCondition?
    
    var currentCompanionCreative: VastCompanionCreative?

    var currentContent = ""
    
    func parse(url: URL) throws -> VastModel {
        xmlParser = XMLParser(contentsOf: url)
        guard let parser = xmlParser else {
            throw VastError.unableToCreateXMLParser
        }

        parser.delegate = self

        if parser.parse() {
            if !validVastDocument {
                throw VastError.invalidVASTDocument
            }

            if fatalError != nil {
                throw VastError.invalidXMLDocument
            }
        } else {
            throw VastError.unableToParseDocument
        }

        guard var vm = vastModel else {
            throw VastError.internalError
        }

        finalizeModel(&vm)
        
        return vm
    }
}

extension VastXMLParser: XMLParserDelegate {

    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        
        if !validVastDocument && !parsedFirstElement {
            parsedFirstElement = true
            if elementName == VastElements.vast {
                validVastDocument = true
                vastModel = VastModel(attrDict: attributeDict)
            }
        }

        if validVastDocument && fatalError == nil {
            switch elementName {
            case VastElements.ad:
                currentVastAd = VastAd(attrDict: attributeDict)
                // Ad Pods - Extraer información directamente de los atributos
                if let sequenceStr = attributeDict["sequence"],
                   let sequenceNum = Int(sequenceStr) {
                    currentVastAd?.sequence = sequenceNum
                }
            case AdElements.wrapper:
                currentWrapper = VastWrapper(attrDict: attributeDict)
            case AdElements.adSystem:
                currentAdSystem = VastAdSystem(attrDict: attributeDict)
            case AdElements.impression:
                currentVastImpression = VastImpression(attrDict: attributeDict)
            case AdElements.category:
                currentVastCategory = VastAdCategory(attrDict: attributeDict)
            case AdElements.pricing:
                currentVastPricing = VastPricing(attrDict: attributeDict)
            case AdElements.survey:
                currentSurvey = VastSurvey(attrDict: attributeDict)
            case AdElements.viewableImpression, VastAdVerificationElements.viewableImpression:
                if currentVerification != nil {
                    currentVerificationViewableImpression = VastViewableImpression(attrDict: attributeDict)
                } else {
                    currentViewableImpression = VastViewableImpression(attrDict: attributeDict)
                }
            // VAST 4.1+ AdVerifications container
            case AdElements.adVerifications:
                currentAdVerifications = VastAdVerifications()
            case AdElements.verification:
                currentVerification = VastVerification(attrDict: attributeDict)
            case VastAdVerificationElements.verificationParameters:
                currentAdVerificationParameters = VastAdVerificationParameters()
            case VastAdVerificationElements.flashResource,
                 VastAdVerificationElements.javaScriptResource,
                 VastAdVerificationElements.executableResource:
                currentResource = VastResource(attrDict: attributeDict)
            case AdElements.ext:
                currentVastExtension = VastExtension(attrDict: attributeDict)
            case AdElements.creative:
                currentCreative = VastCreative(attrDict: attributeDict)
            // Added case to handle InteractiveCreativeFile at the Creative level for VAST 4.2
            case VastCreativeElements.interactiveCreativeFile:
                currentInteractiveCreativeFile = VastInteractiveCreativeFile(attrDict: attributeDict)
            case VastCreativeElements.linear:
                currentLinearCreative = VastLinearCreative(attrDict: attributeDict)
            case VastCreativeElements.nonLinearAds:
                currentNonLinearAdsCreative = VastNonLinearAdsCreative()
            case CreativeNonLinearAdsElements.staticResource:
                currentStaticResource = VastStaticResource(attrDict: attributeDict)
            case CreativeNonLinearAdsElements.nonLinear:
                currentNonLinear = VastNonLinear(attrDict: attributeDict)
            case VastCreativeElements.universalAdId:
                currentUniversalAdId = VastUniversalAdId(attrDict: attributeDict)
            case VastCreativeElements.creativeExtension:
                currentCreativeExtension = VastCreativeExtension(attrDict: attributeDict)
            case CreativeLinearElements.tracking:
                currentTrackingEvent = VastTrackingEvent(attrDict: attributeDict)
            case CreativeNonLinearAdsElements.tracking:
                currentTrackingEvent = VastTrackingEvent(attrDict: attributeDict)
            case CreativeLinearElements.clickthrough, CreativeLinearElements.clicktracking, CreativeLinearElements.customclick:
                guard let type = ClickType(rawValue: elementName) else { break }
                currentVideoClick = VastVideoClick(type: type, attrDict: attributeDict)
            case CreativeLinearElements.adParameters, CompanionElements.adparameters:
                currentAdParameters = VastAdParameters(attrDict: attributeDict)
            case CreativeLinearElements.mediafile:
                currentMediaFile = VastMediaFile(attrDict: attributeDict)
            case CreativeLinearElements.icon:
                currentIcon = VastIcon(attrDict: attributeDict)
            case VastIconElements.staticResource:
                currentStaticResource = VastStaticResource(attrDict: attributeDict)
            case VastIconElements.iconClicks:
                currentIcon?.iconClicks = IconClicks()
            case VastElements.creative:
                currentCreative = VastCreative(attrDict: attributeDict)
            case IconClicksElements.iconClickTracking:
                currentIconClickTracking = VastIconClickTracking(attrDict: attributeDict)
            case ExtensionElements.creativeparameter:
                currentCreativeParameter = VastCreativeParameter(attrDict: attributeDict)
            case VastCreativeElements.companionAds:
                currentCreative?.companionAds = VastCompanionAds(attrDict: attributeDict)
            case CompanionAdsElements.companion:
                currentCompanionCreative = VastCompanionCreative(attrDict: attributeDict)
            case ConditionalElements.condition:
                currentCondition = VastCondition(attrDict: attributeDict)
            default:
                break
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentContent += string
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let content = String(data: CDATABlock, encoding: .utf8) {
            currentContent += content
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentContent = currentContent.trimmingCharacters(in: .whitespacesAndNewlines)

        if validVastDocument && fatalError == nil {
            switch elementName {
            case VastElements.vast:
                // If another class is using this delegate call complete
                if let vm = vastModel {
                    completeClosure?(fatalError, vm)
                }
            case VastElements.error:
                guard let url = URL(string: currentContent) else {
                    break
                }
                if currentVastAd != nil {
                    currentVastAd?.errors.append(url)
                } else {
                    vastModel?.errors.append(url)
                }
            case VastElements.ad:
                if let vastAd = currentVastAd {
                    vastModel?.ads.append(vastAd)
                    currentVastAd = nil
                }
            case AdElements.inLine:
                currentVastAd?.type = .inline
            case AdElements.wrapper:
                if let wrapper = currentWrapper {
                    currentVastAd?.wrapper = wrapper
                    currentWrapper = nil
                }
                currentVastAd?.type = .wrapper
            case AdElements.adSystem:
                currentAdSystem?.system = currentContent
                if let adSystem = currentAdSystem {
                    currentVastAd?.adSystem = adSystem
                    currentAdSystem = nil
                }
            case AdElements.adTitle:
                currentVastAd?.adTitle = currentContent
            case AdElements.impression:
                currentVastImpression?.url = URL(string: currentContent)
                if let vastImpression = currentVastImpression {
                    currentVastAd?.impressions.append(vastImpression)
                    currentVastImpression = nil
                }
            case AdElements.category:
                currentVastCategory?.value = currentContent.isEmpty ? nil : currentContent
                if let category = currentVastCategory {
                    currentVastAd?.adCategories.append(category)
                    currentVastCategory = nil
                }
            case AdElements.description:
                currentVastAd?.description = currentContent
            case AdElements.advertiser:
                currentVastAd?.advertiser = currentContent
            case AdElements.pricing:
                currentVastPricing?.pricing = currentContent.doubleValue
                if let pricing = currentVastPricing {
                    currentVastAd?.pricing = pricing
                    currentVastPricing = nil
                }
            case AdElements.survey:
                currentSurvey?.survey = URL(string: currentContent)
                if let survey = currentSurvey {
                    currentVastAd?.surveys.append(survey)
                    currentSurvey = nil
                }
            case AdElements.error:
                if let url = URL(string: currentContent) {
                    currentVastAd?.errors.append(url)
                }
            case AdElements.viewableImpression,
                VastAdVerificationElements.viewableImpression:
                if let url = URL(string: currentContent) {
                    currentVerificationViewableImpression?.url = url
                }
                if currentVerification != nil {
                    currentVerification?.viewableImpression = currentVerificationViewableImpression
                    currentVerificationViewableImpression = nil
                } else {
                    currentVastAd?.viewableImpression = currentViewableImpression
                    currentViewableImpression = nil
                }
            case VastViewableImpressionElements.notViewable:
                if let url = URL(string: currentContent) {
                    currentViewableImpression?.notViewable.append(url)
                }
            case VastViewableImpressionElements.viewable:
                if let url = URL(string: currentContent) {
                    currentViewableImpression?.viewable.append(url)
                }
            case VastViewableImpressionElements.viewUndetermined:
                if let url = URL(string: currentContent) {
                    currentViewableImpression?.viewUndetermined.append(url)
                }
            case AdElements.verification:
                if let verification = currentVerification {
                    currentVastAd?.adVerifications?.verifications.append(verification)
                    currentVerification = nil
                }
            case VastAdVerificationElements.flashResource:
                currentResource?.url = normalizeURL(currentContent)

                if let resource = currentResource {
                    currentVerification?.flashResources.append(resource)
                    currentVerification?.executableResources.append(resource)
                    currentResource = nil
                }
            case VastAdVerificationElements.executableResource:
                currentResource?.url = normalizeURL(currentContent)

                if let resource = currentResource {
                    currentVerification?.executableResources.append(resource)
                    currentResource = nil
                }
            case VastAdVerificationElements.javaScriptResource:
                currentResource?.url = normalizeURL(currentContent)

                if let resource = currentResource {
                    currentVerification?.javaScriptResources.append(resource)
                    currentResource = nil
                }
            case VastAdVerificationElements.verificationParameters:
                if var verificationParams = currentAdVerificationParameters {
                    verificationParams.data = currentContent
                    currentVerification?.verificationParameters = verificationParams
                    currentAdVerificationParameters = nil
                }
            case VastWrapperElements.vastAdTagUri:
                currentWrapper?.adTagUri = URL(string: currentContent)
            case AdElements.ext:
                if let vastExtension = currentVastExtension {
                    currentVastAd?.extensions.append(vastExtension)
                    currentVastExtension = nil
                }
            case AdElements.creative:
                if let creative = currentCreative {
                    currentVastAd?.creatives.append(creative)
                    currentCreative = nil
                }
                currentUniversalAdId = nil
                currentCreativeExtension = nil
            case VastCreativeElements.universalAdId:
                // Usando una variable temporal para manejar la modificación de la estructura
                if var adId = currentUniversalAdId {
                    adId.setUniqueCreativeId(currentContent)
                    currentUniversalAdId = adId
                }
                
                if let universalAdId = currentUniversalAdId {
                    currentCreative?.universalAdId = universalAdId
                    currentUniversalAdId = nil
                }
            case VastCreativeElements.creativeExtension:
                currentCreativeExtension?.content = currentContent
                if let creativeExtension = currentCreativeExtension {
                    currentCreative?.creativeExtensions.append(creativeExtension)
                    currentCreativeExtension = nil
                }
            case VastCreativeElements.linear:
                if let linear = currentLinearCreative {
                    currentCreative?.linear = linear
                    currentLinearCreative = nil
                }
            case CreativeLinearElements.duration:
                currentLinearCreative?.duration = currentContent.toSeconds ?? -1.0
            case CreativeLinearElements.adParameters, CompanionElements.adparameters:
                // TODO this might be XML encoded content that will need better parsing
                currentAdParameters?.content = currentContent
                if let adParameters = currentAdParameters {
                    if currentCompanionCreative != nil {
                        currentCompanionCreative?.adParameters = adParameters
                    } else {
                        currentLinearCreative?.adParameters = adParameters
                    }
                }
                currentAdParameters = nil
            case CreativeLinearElements.mediafile:
                currentMediaFile?.url = URL(string: currentContent)
                if let mediaFile = currentMediaFile {
                    currentLinearCreative?.files.mediaFiles.append(mediaFile)
                    currentMediaFile = nil
                }
            case VastCreativeElements.interactiveCreativeFile:
                currentInteractiveCreativeFile?.url = URL(string: currentContent)
                if let interactiveCreativeFile = currentInteractiveCreativeFile {
                    currentCreative?.interactiveCreativeFile = interactiveCreativeFile
                    currentInteractiveCreativeFile = nil
                }
            case CreativeLinearElements.clickthrough, CreativeLinearElements.clicktracking, CreativeLinearElements.customclick:
                currentVideoClick?.url = URL(string: currentContent)
                if let click = currentVideoClick {
                    currentLinearCreative?.videoClicks.append(click)
                    currentVideoClick = nil
                }
            case CreativeLinearElements.tracking, CompanionElements.trackingevents, CreativeNonLinearAdsElements.tracking:
                currentTrackingEvent?.url = URL(string: currentContent)
                if let trackingEvent = currentTrackingEvent {
                    if currentCompanionCreative != nil {
                        currentCompanionCreative?.trackingEvents.append(trackingEvent)
                    } else {
                        if currentNonLinearAdsCreative != nil {
                            currentNonLinearAdsCreative?.trackingEvents.append(trackingEvent)
                        } else {
                            currentLinearCreative?.trackingEvents.append(trackingEvent)
                        }
                    }
                    currentTrackingEvent = nil
                }
            case CreativeLinearElements.icon:
                if let currentIcon = currentIcon {
                    currentLinearCreative?.icons.append(currentIcon)
                    
                }
                currentIcon = nil
            case VastCreativeElements.nonLinearAds:
                if let nonLinearAds = currentNonLinearAdsCreative {
                    currentCreative?.nonLinearAds = nonLinearAds
                    currentLinearCreative = nil
                }
            case CreativeNonLinearAdsElements.nonLinear:
                if let nonLinear = currentNonLinear {
                    currentNonLinearAdsCreative?.nonLinear.append(nonLinear)
                    currentNonLinear = nil
                }
            case VastIconElements.staticResource, CompanionElements.staticResource, CreativeNonLinearAdsElements.staticResource:
                currentStaticResource?.url = URL(string: currentContent)
                
                if let staticResource = currentStaticResource {
                    if currentCompanionCreative != nil {
                        currentCompanionCreative?.staticResource.append(staticResource)
                    } else {
                        if currentNonLinear != nil {
                            currentNonLinear?.staticResource = staticResource
                        } else {
                            currentIcon?.staticResource.append(staticResource)
                        }
                    }
                }
                currentStaticResource = nil
            case CreativeNonLinearAdsElements.NonLinearClickTracking:
                if let url = URL(string: currentContent){
                    currentNonLinear?.nonLinearClickTracking = url
                }
            case CompanionElements.iframeResource:
                if let url = URL(string: currentContent) {
                    currentCompanionCreative?.iFrameResource.append(url)
                }
            case CompanionElements.htmlResource:
                if let url = URL(string: currentContent) {
                    currentCompanionCreative?.htmlResource.append(url)
                }
            case VastIconElements.iconViewTracking:
                if let url = URL(string: currentContent) {
                    currentIcon?.iconViewTracking.append(url)
                }
            case IconClicksElements.iconClickThrough:
                currentIcon?.iconClicks?.iconClickThrough = URL(string: currentContent)
            case IconClicksElements.iconClickTracking:
                currentIconClickTracking?.url = URL(string: currentContent)
                if let currentIconClickTracking = currentIconClickTracking {
                    currentIcon?.iconClicks?.iconClickTracking.append(currentIconClickTracking)
                }
                currentIconClickTracking = nil
            case CompanionAdsElements.companion:
                if let companion = currentCompanionCreative {
                    currentCreative?.companionAds?.companions.append(companion)
                    currentCompanionCreative = nil
                }
            case CompanionElements.alttext:
                currentCompanionCreative?.altText = currentContent
            case CompanionElements.companionclickthrough:
                currentCompanionCreative?.companionClickThrough = URL(string: currentContent)
            case CompanionElements.companionclicktracking:
                if let url = URL(string: currentContent) {
                    currentCompanionCreative?.companionClickTracking.append(url)
                }
            // TODO: external parameter - this needs to be defined outside the library
            case ExtensionElements.creativeparameter:
                currentCreativeParameter?.content = currentContent
                if let creative = currentCreativeParameter {
                    creativeParameters.append(creative)
                    currentCreativeParameter = nil
                }
            case ExtensionElements.creativeparameters:
                currentVastExtension?.creativeParameters = creativeParameters
                creativeParameters = [VastCreativeParameter]()

            default:
                break
            }
            currentContent = ""
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        fatalError = parseError
    }
    
    // Método auxiliar para convertir strings de duración a TimeInterval
    private func timeIntervalFromDurationString(_ durationStr: String) -> TimeInterval? {
        let components = durationStr.components(separatedBy: ":")
        guard components.count == 3,
              let hours = Double(components[0]),
              let minutes = Double(components[1]),
              let seconds = Double(components[2]) else {
            return nil
        }

        return hours * 3600 + minutes * 60 + seconds
    }

    // Método para finalizar el parsing y organizar Ad Pods
    private func finalizeModel(_ model: inout VastModel) {
        // Organizar anuncios en pods
        model.organizeAdPods()
        
        // Verificar si hay errores y si no hay anuncios
        if !model.errors.isEmpty, model.ads.count == 0 {
            let urls = model.errors.compactMap { $0.withErrorCode(VastErrorCodes.noAdsVastResponse) }
            // Error: track method is not defined. Replace with logging or remove.
            // track(urls: urls, eventName: "ERROR NO ADS")
            print("ERROR NO ADS: \(urls)")
        }
    }
    
    private func normalizeURL(_ urlString: String) -> URL? {
        // Eliminar espacios en blanco
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        return URL(string: trimmed)
    }
}
