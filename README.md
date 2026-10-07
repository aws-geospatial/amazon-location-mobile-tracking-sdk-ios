# Amazon Location Service Mobile Tracking SDK for iOS

These utilities help you track your location when making Amazon Location Service API calls from their iOS applications.

## Installation

1. Go to File -> Add Package Dependencies in your XCode project.
2. Type the package URL (https://github.com/aws-geospatial/amazon-location-mobile-tracking-sdk-ios/) into the search bar and press the enter key.
3. Select the "amazon-location-mobile-tracking-sdk-ios" package and click on "Add Package".
4. Select the "AmazonLocationiOSTrackingSDK" package product and click on "Add Package".

## Functions

These are the functions available from this SDK:

  <table>
  <tr><th>Class</th><th>Function</th><th>Description</th></tr>

  <tr><td>LocationTracker</td><td>init(identityPoolId: String, trackerName: String, config: LocationTrackerConfig? = nil)</td><td>This is an initializer function to create a LocationTracker object. It requires an identityPoolId and trackerName and an optional LocationTrackingConfig. If config is not provided it will be initialized with default values</td></tr>

<tr><td>LocationTracker</td><td>init(authHelper: AuthHelper, trackerName: String, config: LocationTrackerConfig? = nil)</td><td>This is an initializer function to create a LocationTracker object from a pre-built <code>AuthHelper</code>. Use this when your credentials come from a source other than a Cognito Identity Pool (for example, custom SigV4 credentials via <code>AuthHelper.withCredentialsProvider</code>). It requires an AuthHelper and trackerName and an optional LocationTrackerConfig. If config is not provided it will be initialized with default values</td></tr>

<tr><td>LocationTracker</td><td>setTrackerConfig(config: LocationTrackerConfig)</td><td>This sets Tracker's config to take effect at any point after initialization of location tracker</td></tr>

<tr><td>LocationTracker</td><td>getTrackerConfig() -> LocationTrackerConfig</td><td>This gets the location tracking config to use or modify in your app</td></tr>

<tr><td>LocationTracker</td><td>getDeviceId() -> String?</td><td>Gets the location tracker's generated device Id</td></tr>

<tr><td>LocationTracker</td><td>startTracking()</td><td>Starts the process of accessing the user's location and sending it to the AWS tracker</td></tr>

<tr><td>LocationTracker</td><td>resumeTracking()</td><td>Resumes the process of accessing the user's location and sending it to the AWS tracker</td></tr>

<tr><td>LocationTracker</td><td>stopTracking()</td><td>Stops the process of tracking the user's location</td></tr>

<tr><td>LocationTracker</td><td>startBackgroundTracking(mode: BackgroundTrackingMode)</td><td>Starts the process of accessing the user's location and sending it to the AWS tracker while the application is in the background.
BackgroundTrackingMode has the following options:
<br/>
- <b>Active:</b> This option doesn't automatically pauses location updates<br/>
- <b>BatterySaving:</b> This option automatically pauses location updates<br/>
- <b>None:</b> This option overall disables background location updates<br/>
</td></tr>

<tr><td>LocationTracker</td><td>resumeBackgroundTracking(mode: BackgroundTrackingMode)</td><td>Resumes the process of accessing the user's location and sending it to the AWS tracker while the application is in the background.</td></tr>

<tr><td>LocationTracker</td><td>stopBackgroundTracking()</td><td>Stops the process of accessing the user's location and sending it to the AWS tracker while the application is in the background.</td></tr>

<tr><td>LocationTracker</td><td>getTrackerDeviceLocation(nextToken: String?, startTime: Date? = nil, endTime: Date? = nil, completion: @escaping (Result<GetLocationResponse, Error>) -> Void) </td><td>Retrieves the uploaded tracking locations for the user's device between start and end date & time</td></tr>

  <tr><td>LocationTrackerConfig</td><td>init()</td><td>This initializes the LocationTrackerConfig with default values</td></tr>

  <tr><td>LocationTrackerConfig</td><td>init(locationFilters: [LocationFilter]? = nil,
                trackingDistanceInterval: Double? = nil,
                trackingTimeInterval: Double? = nil,
                trackingAccuracyLevel: Double? = nil,
                uploadFrequency: Double? = nil,
                desiredAccuracy: CLLocationAccuracy? = nil,
                activityType: CLActivityType? = nil,
                logLevel: LogLevel? = nil)</td><td>This initializes the LocationTrackerConfig with user-defined parameter values. If a parameter value is not provided it will be set to a default value</td></tr>

  <tr><td>LocationFilter</td><td>shouldUpload(currentLocation: LocationEntity, previousLocation: LocationEntity?, trackerConfig: LocationTrackerConfig)</td><td>The LocationFilter is a protocol that users can implement for their custom filter implementation. A user would need to implement `shouldUpload` function to compare previous and current location and return if the current location should be uploaded</td></tr>

  </table>

## Usage

After installing the library, You will need to add one or both of the following descriptions in info.plist:

- Privacy - Location When In Use Usage Description
- Privacy - Location Always and When In Use Usage Description

Import the Tracking SDK in your class:

```
import AmazonLocationiOSTrackingSDK
```

Create `LocationTracker` and use it with the AWS SDK:

```swift
// Create a LocationTracker using an Amazon Cognito Identity Pool ID
let locationTracker = try await LocationTracker(identityPoolId: "<Cognito Identity Pool ID>", trackerName: "<My-tracker-name>")

// Optionally you can set ClientConfig with your own values in either initialize or in a separate function
let trackerConfig = LocationTrackerConfig(locationFilters: [TimeLocationFilter(), DistanceLocationFilter()],
            trackingDistanceInterval: 30,
            trackingTimeInterval: 30,
            logLevel: .debug)
let locationTracker = try await LocationTracker(identityPoolId: "<Cognito Identity Pool ID>", trackerName: "<My-tracker-name>", config: trackerConfig)
locationTracker.setConfig(config: trackerConfig)
```

If your credentials come from a source other than a Cognito Identity Pool (for example, short-lived SigV4 credentials vended by your backend), build an `AuthHelper` with `AuthHelper.withCredentialsProvider(...)` from the [Auth SDK](https://github.com/aws-geospatial/amazon-location-mobile-auth-sdk-ios) and pass it to `LocationTracker`:

```swift
import AmazonLocationiOSAuthSDK
import AmazonLocationiOSTrackingSDK
import SmithyIdentity

// Build a resolver from credentials your app obtained (e.g. from your backend / STS)
let credentialsIdentity = AWSCredentialIdentity(
    accessKey: "<Access key>",
    secret: "<Secret key>",
    sessionToken: "<Session token>"
)
let resolver = try StaticAWSCredentialIdentityResolver(credentialsIdentity)
let authHelper = try await AuthHelper.withCredentialsProvider(credentialsProvider: resolver, region: "<Region>")

// Create the LocationTracker using the custom-credentials AuthHelper
let locationTracker = try LocationTracker(authHelper: authHelper, trackerName: "<My-tracker-name>")
```

You can use the location client to make calls to Amazon Location Service. Here are a few simple examples for tracking operations:

```swift
// Required in info.plist: Privacy - Location When In Use Usage Description
do {
    try locationTracker.startTracking()
} catch TrackingLocationError.permissionDenied {
    // Handle permissionDenied by showing the alert message or open the app settings
}

do {
    try locationTracker.resumeTracking()
} catch TrackingLocationError.permissionDenied {
    // Handle permissionDenied by showing the alert message or open the app settings
}

locationTracker.stopTracking()

// Required in info.plist: Privacy - Location Always and When In Use Usage Description
do {
    locationTracker.startBackgroundTracking(mode: .Active) // .Active, .BatterySaving, .None
} catch TrackingLocationError.permissionDenied {
    // Handle permissionDenied by showing the alert message or open the app settings
}

do {
    locationTracker.resumeBackgroundTracking(mode: .Active)
} catch TrackingLocationError.permissionDenied {
    // Handle permissionDenied by showing the alert message or open the app settings
}

locationTracker.stopBackgroundTracking()

// To retrieve device's tracked locations from a tracker
func getTrackingPoints(nextToken: String? = nil) {
    let startTime: Date = Date().addingTimeInterval(-86400) // Yesterday's day date & time
    let endTime: Date = Date()
    locationTracker.getTrackerDeviceLocation(nextToken: nextToken, startTime: startTime, endTime: endTime, completion: { [weak self] result in
        switch result {
        case .success(let response):

            let positions = response.devicePositions
            // You can draw positions on map or use it further as per your requirement

            // If nextToken is available, recursively call to get more data
            if let nextToken = response.nextToken {
                self?.getTrackingPoints(nextToken: nextToken)
            }
        case .failure(let error):
            print(error)
        }
    })
}
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## Getting Help

The best way to interact with our team is through GitHub.
You can [open an issue](https://github.com/aws-geospatial/amazon-location-mobile-tracking-sdk-ios/issues/new/choose) and choose from one of our templates for
[bug reports](https://github.com/aws-geospatial/amazon-location-mobile-tracking-sdk-ios/issues/new?assignees=&labels=bug%2C+needs-triage&template=---bug-report.md&title=),
[feature requests](https://github.com/aws-geospatial/amazon-location-mobile-tracking-sdk-ios/issues/new?assignees=&labels=feature-request&template=---feature-request.md&title=)
or [guidance](https://github.com/aws-geospatial/amazon-location-mobile-tracking-sdk-ios/issues/new?assignees=&labels=guidance%2C+needs-triage&template=---questions---help.md&title=).
If you have a support plan with [AWS Support](https://aws.amazon.com/premiumsupport/), you can also create a new support case.

Please make sure to check out the following resources before opening an issue:

- Our [Changelog](CHANGELOG.md) for recent changes.

## Contributing

We welcome community contributions and pull requests. See [CONTRIBUTING.md](CONTRIBUTING.md) for information on how to set up a development environment and submit code.

## License

The Amazon Location Service Mobile Tracking SDK for iOS is distributed under the
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0),
see LICENSE.txt and NOTICE.txt for more information.
