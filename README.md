# IOS Vast Client

IOS Vast Client is a Swift Framework which implements the [VAST 4.3](https://iabtechlab.com/wp-content/uploads/2022/09/VAST_4.3.pdf) spec.

This project is ongoing and in very early stages of development. As this project is being developed we will only target a subset of the VAST spec to meet our immediate needs. We do not recommend to use this library at this time. 

## Features

* VAST 4.3 Spec Complient, backwards compatible with Vast 3.0
* Vast XML Parser and Validator
* VAST Impression and Ad Tracking
* VAST Error Tracking

## API docs

iOS Vast Client contains 2 interfaces for public use.

### VastClient

Fetch and parse VAST file from URL. You can customize behaviour with `VastClientOptions` during initialization of `VastClient`.
If you would like to cache the VMAPModel to prevent duplicate calls, change the value of shouldCacheVMAPModel to true.

`VastClient` result is `VastModel` structure or `Error` in case the fetch failed. You should pass this model to `VastTracker`.

### VastTracker

Handles tracking of ad quartiles. Performs tracking for ads/ad breaks. Notifies quartile state updates via delegate calls.

#### Initialization

Init `VastTracker` with `VastModel` structure but always make sure to use the actual `VastAd` and other information provided via delegate function calls - do not keep the `VastModel` as not all information from the `VastModel` might be valid for playback etc. 

#### Progress and Ad Tracking

`func updateProgress(time: Double) throws`
After you initialize `VastTracker` you should call this function with `time = playhead` parameter to start tracking process. Playhead should match the playhead value used in intialization of `VastTracker`.  (If you simply want to play pre-roll ads before your content, initialize `VastTracker` with `playhead = 0` and call `updateProgress(time:)` with `time = 0`)

You have to call this function periodically during ad playback.

Your client must track when ads/ad breaks start and end. You can pass this information to `Vast Tracker` via the following
- `func trackAdBreakStart(for adBreak: VMAPAdBreak)`
- `func trackAdBreakEnd(for adBreak: VMAPAdBreak)`
- `func trackAdStart(withId id: String) throws`
- `func trackAdComplete() throws`

`VastTracker` will track quartile updates while `func updateProgress(time: Double) throws` is being called.


These delegate functions will be called during normal ad playback and you do not have to react to them - they are only informative

```swift
func adFirstQuartile(vastTracker: VastTracker, ad: VastAd)
func adMidpoint(vastTracker: VastTracker, ad: VastAd)
func adThirdQuartile(vastTracker: VastTracker, ad: VastAd)
```

### Other Tracking

During ad break, other actions might be invoked by the user or the system.
`VastTracker` support tracking of these actions:

```
public func paused(_ val: Bool)
public func fullscreen(_ val: Bool)
public func rewind()
public func muted(_ val: Bool)
public func acceptedLinearInvitation()
public func closed()
public func clicked() -> URL?
public func clickedWithCustomAction() -> [URL]
public func error(withReason code: VastErrorCodes?)
```

## Supported tags

status:

- not parsed
- parsed - but not used currently, can be used by host app
- partial - partially supported - might be missing edge cases
- full - fully supported VAST tag

|tag|status|note|
|---|---|---|
|VAST|full|-|
|Ad|partial|single and AdPods supported, AdBuffet treated like single ad|
|InLine|full|-|
|AdSystem|full|Parsed and tracked completely|
|AdTitle|full|-|
|Impression|full|Parsed and tracked by VastTracker|
|Category|full|Parsed and available to the host app|
|Description|full|Parsed and available to the host app|
|Advertiser|full|Parsed and available to the host app|
|Pricing|full|Parsed and available to the host app|
|Survey|full|Parsed and available to the host app|
|Error|full|host app needs to initiate the error tracking|
|ViewableImpression|full|host app needs to call tracking function with appropriate type at appropriate time|
|AdVerifications|full|VAST 4.x feature|
|Creatives|full|-|
|Creative|full|Includes VAST 4.3 attributes|
|UniversalAdId|full|Parsed and available to the host app|
|CreativeExtensions|full|Parsed and available to the host app|
|CreativeExtension|full|Parsed and available to the host app|
|CreativeBehaviors|full|VAST 4.3 feature|
|Linear|full|-|
|Duration|full|-|
|AdParameters|parsed|but only as a string - this might be XML content that will need validation if it is necessary for use|
|MediaFiles|full|-|
|MediaFile|full|All attributes parsed, playback handled by host app|
|Mezzanine|not parsed|-|
|InteractiveCreativeFile|full|VAST 4.2 SIMID support|
|VideoClicks|full|host app has to initiate tracking events|
|ClickThrough|full|-|
|ClickTracking|full|-|
|CustomClick|full|Tracking supported via VastTracker|
|Icons|partial|iFrame and HTML resources not parsed|
|Icon|full|host app handles placement and visibility|
|IconViewTracking|full|Support for view tracking events|
|IconClicks|full|-|
|IconClickThrough|full|-|
|IconClickTracking|full|-|
|NonLinearAds|full|Full parsing and tracking support|
|CompanionAds|full|Full parsing and tracking support|
|Wrapper|full|-|
|VASTAdTagURI|full|Wrapper URI is parsed and resolved|
|Companion|full|Complete support including click tracking|


## Getting Started

Check out the VastClientWrapper project for example implementation

## Contributing

Please read [CONTRIBUTING.md](https://github.com/realeyes-media/ios-vast-client/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the MIT License - see [LICENSE](https://github.com/realeyes-media/ios-vast-client/LICENSE) file for details
