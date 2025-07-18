//
//  VastXMLParserVast4_3Tests.swift
//  VastClientTests
//
//  Created by AIVars on 17/07/2025.
//

import XCTest
@testable import VastClient

class VastXMLParserVast4_3Tests: XCTestCase {
    
    var parser: VastXMLParser?
    
    override func setUp() {
        super.setUp()
        parser = VastXMLParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    func test_Vast4_3_full_parsing() {
        let vastUrl = VastTesting.getVastUrl(for: "Vast4.3_full")
        
        do {
            let vastModel = try parser!.parse(url: vastUrl)
            
            // Ad
            let ad = vastModel.ads.first
            XCTAssertNotNil(ad, "Ad should not be nil")
            
            // AdVerifications
            let adVerifications = ad?.adVerifications
            XCTAssertNotNil(adVerifications, "AdVerifications should not be nil")
            XCTAssertEqual(adVerifications?.verifications.count, 1, "Should have 1 primary verification")
            XCTAssertEqual(adVerifications?.supplementalAdVerifications.count, 1, "Should have 1 supplemental verification")
            
            let supplementalVerification = adVerifications?.supplementalAdVerifications.first
            XCTAssertEqual(supplementalVerification?.vendor, "iVoox-Ver-2", "Supplemental verification vendor mismatch")
            
            // Creative
            let creative = ad?.creatives.first
            XCTAssertNotNil(creative, "Creative should not be nil")
            
            // VAST 4.3 Attributes
            XCTAssertEqual(creative?.adServingId, "ad-id-987", "adServingId mismatch")
            XCTAssertEqual(creative?.creativeType, "video", "creativeType mismatch")
            
            // CreativeDimensions
            let dimensions = creative?.creativeDimensions
            XCTAssertNotNil(dimensions, "CreativeDimensions should not be nil")
            XCTAssertEqual(dimensions?.width, 1280, "CreativeDimensions width mismatch")
            XCTAssertEqual(dimensions?.height, 720, "CreativeDimensions height mismatch")
            
            // CreativeBehaviors
            let behaviors = creative?.creativeBehaviors
            XCTAssertNotNil(behaviors, "CreativeBehaviors should not be nil")
            XCTAssertEqual(behaviors?.count, 2, "Should have 2 behaviors")
            XCTAssertEqual(behaviors?.first?.type, "closeable", "First behavior type mismatch")
            XCTAssertEqual(behaviors?.first?.value, "true", "First behavior value mismatch")
            
            // CreativeMediaFile
            let creativeMedia = creative?.creativeMediaFiles
            XCTAssertNotNil(creativeMedia, "CreativeMediaFiles should not be nil")
            XCTAssertEqual(creativeMedia?.count, 1, "Should have 1 creative media file")
            XCTAssertEqual(creativeMedia?.first?.id, "media-file-1", "CreativeMediaFile id mismatch")
            
            // CreativeTrackingEvents
            let creativeTracking = creative?.creativeTrackingEvents
            XCTAssertNotNil(creativeTracking, "CreativeTrackingEvents should not be nil")
            XCTAssertEqual(creativeTracking?.count, 1, "Should have 1 creative tracking event")
            XCTAssertEqual(creativeTracking?.first?.event, "creativeView", "CreativeTracking event mismatch")
            
        } catch {
            XCTFail("Parsing failed with error: \(error)")
        }
    }
}
