//
//  VastMacros.swift
//  Nimble
//
//  Created by Jan Bednar on 14/11/2018.
//

import Foundation
import UIKit
import CoreTelephony
import WebKit

/// Class responsible for handling VAST macro substitution
public class VastMacroProcessor {
    
    /// Singleton for global access
    public static let shared = VastMacroProcessor()
    
    // Variables to store playhead values
    private var adPlayhead: TimeInterval?
    private var mediaPlayhead: TimeInterval?
    
    // Variables for error tracking
    private var vastErrorCode: Int?
    private var playerErrorCode: String?
    
    private init() {}
    
    /// Updates the current ad position
    /// - Parameter time: Current time in seconds
    public func updateAdPlayhead(_ time: TimeInterval) {
        self.adPlayhead = time
    }
    
    /// Updates the current main content position
    /// - Parameter time: Current time in seconds
    public func updateMediaPlayhead(_ time: TimeInterval) {
        self.mediaPlayhead = time
    }
    
    /// Sets error codes to use in macros
    /// - Parameters:
    ///   - vastError: VAST error code
    ///   - playerError: Player error code
    public func setErrorCodes(vastError: Int?, playerError: String?) {
        self.vastErrorCode = vastError
        self.playerErrorCode = playerError
    }
    
    /// Formats time in [HH:MM:SS.mmm] format
    /// - Parameter timeInterval: Time to format
    /// - Returns: Formatted string
    private func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let time = Int(timeInterval)
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 1000)
        
        return String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
    }
    
    /// Gets the device's IP address
    /// - Returns: IP address as a string or an empty string
    private func getDeviceIP() -> String {
        // Basic implementation - should use Network Framework in production
        return "0.0.0.0"
    }
    
    /// Gets the current mobile carrier
    /// - Returns: Carrier name or empty string
    private func getMobileCarrier() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        // Use serviceSubscriberCellularProviders instead of the deprecated subscriberCellularProvider
        if #available(iOS 12.0, *) {
            let carriers = networkInfo.serviceSubscriberCellularProviders
            return carriers?.values.first?.carrierName ?? ""
        } else {
            // Fallback for older iOS versions
            return networkInfo.subscriberCellularProvider?.carrierName ?? ""
        }
    }
    
    /// Gets the device's user agent
    /// - Returns: User agent string
    private func getDeviceUserAgent() -> String {
        // This is a simplified approach - for production use a proper User-Agent solution
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(UIDevice.current.systemVersion) like Mac OS X)"
    }
    
    /// Replaces all VAST macros in a URL
    /// - Parameters:
    ///   - url: URL with macros
    ///   - vastAd: Optional VastAd object for ad-specific macros
    /// - Returns: URL with replaced macros
    public func process(url: String, vastAd: VastAd? = nil) -> String {
        var processedUrl = url
        
        // VAST 4.0 Macros
        
        // [ADPLAYHEAD] - current position in the ad
        if let adPlayhead = adPlayhead {
            processedUrl = processedUrl.replacingOccurrences(
                of: "[ADPLAYHEAD]",
                with: formatTimeInterval(adPlayhead)
            )
        }
        
        // [MEDIAPLAYHEAD] - current position in the main content
        if let mediaPlayhead = mediaPlayhead {
            processedUrl = processedUrl.replacingOccurrences(
                of: "[MEDIAPLAYHEAD]",
                with: formatTimeInterval(mediaPlayhead)
            )
        }
        
        // [UNIVERSALADID] - Universal ad ID
        if let universalAdId = vastAd?.creatives.first?.universalAdId?.idValue {
            processedUrl = processedUrl.replacingOccurrences(
                of: "[UNIVERSALADID]",
                with: universalAdId
            )
        }
        
        // [DEVICEIP] - Device IP
        processedUrl = processedUrl.replacingOccurrences(
            of: "[DEVICEIP]",
            with: getDeviceIP()
        )
        
        // [SERVERSIDE] - Indicates if logic runs on server (0=client-side)
        processedUrl = processedUrl.replacingOccurrences(
            of: "[SERVERSIDE]",
            with: "0"
        )
        
        // [VASTVERSIONS] - Supported VAST versions
        processedUrl = processedUrl.replacingOccurrences(
            of: "[VASTVERSIONS]",
            with: "2.0,3.0,4.0"
        )
        
        // [ERRORCODE] - VAST error code
        if let vastErrorCode = vastErrorCode {
            processedUrl = processedUrl.replacingOccurrences(
                of: "[ERRORCODE]",
                with: String(vastErrorCode)
            )
        }
        
        // [PLAYERSTATE] - Player state
        // Note: This would require integration with the current player
        
        // [DEVICEUA] - Device User Agent
        processedUrl = processedUrl.replacingOccurrences(
            of: "[DEVICEUA]",
            with: getDeviceUserAgent()
        )
        
        // [CARRIER] - Mobile carrier
        processedUrl = processedUrl.replacingOccurrences(
            of: "[CARRIER]",
            with: getMobileCarrier()
        )
        
        // [VERIFICATIONVENDOR] - Verification vendor
        // Note: Would need access to the verification object
        
        return processedUrl
    }
}

// MARK: - Extension for VastAd
extension VastAd {
    /// Processes all tracking URLs of a VAST ad
    /// - Returns: A new VastAd object with processed URLs
    public func processAllUrls() -> VastAd {
        var processedAd = self
        
        // Process impressions
        processedAd.impressions = impressions.map { impression in
            var newImpression = impression
            if let urlString = impression.url?.absoluteString {
                let processedUrlString = VastMacroProcessor.shared.process(url: urlString, vastAd: self)
                newImpression.url = URL(string: processedUrlString)
            }
            return newImpression
        }
        
        // Process error URLs
        processedAd.errors = errors.compactMap { errorUrl in
            let processedUrlString = VastMacroProcessor.shared.process(url: errorUrl.absoluteString, vastAd: self)
            return URL(string: processedUrlString)
        }
        
        // Other URL processors can be added here
        
        return processedAd
    }
}
