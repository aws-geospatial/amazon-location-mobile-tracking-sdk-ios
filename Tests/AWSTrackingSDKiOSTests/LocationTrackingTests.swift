import XCTest
import CoreLocation
@testable import AmazonLocationiOSTrackingSDK
import AmazonLocationiOSAuthSDK
import AWSLocation

final class LocationTrackingTests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func readTestConfig() -> [String: String] {
        // Implement reading from your chosen config file. This is an example for a plist.
        guard let plistURL = Bundle.module.url(forResource: "TestConfig", withExtension: "plist"),
              let plistData = try? Data(contentsOf: plistURL) else {
            fatalError("Test configuration file not found.")
        }
        do {
            if let plistDict = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: String] {
                return plistDict
            }
        } catch {
            XCTFail("Error reading plist: \(error)")
        }
        return [:]
    }
    
    func testSetDeviceIDNoID() throws {
        DeviceIdProvider.clearDeviceID()
        DeviceIdProvider.setDeviceID()
        
        XCTAssertNotNil(DeviceIdProvider.getDeviceID())
    }
    
    func testSetDeviceIDWithID() throws {
        let deviceID = UUID().uuidString
        DeviceIdProvider.clearDeviceID()
        DeviceIdProvider.setDeviceID(deviceID: deviceID)
        
        XCTAssertEqual(deviceID, DeviceIdProvider.getDeviceID())
    }
    
    func testSaveLocationToDisk() throws {
        let locationDatabase = LocationDatabase()
        let location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let locationEntity = locationDatabase.save(location: location)
        XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude, "Location Entity is saved")
        
        let locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 1, "Location Entity is saved")
        locationDatabase.delete(locationID: locations.first!.id!.uuidString)
    }
    
    func testDeleteLocationToDisk() throws {
        let locationDatabase = LocationDatabase()
        var location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        var locationEntity = locationDatabase.save(location: location)
        XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude, "Location Entity is saved")
        
        var locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 1, "Location Entity is saved")
        locationDatabase.delete(locationID: locations.first!.id!.uuidString)
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        locationEntity = locationDatabase.save(location: location)
        XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude, "Location Entity is saved")
        
        locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 1, "Location Entity is greater than 1")
        locationDatabase.delete(locations: locations)
        
        locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 0, "Location delete locations is 0")
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        locationEntity = locationDatabase.save(location: location)
        XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude, "Location Entity is saved")
        
        locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 1, "Location Entity is greater than 1")
        locationDatabase.deleteAll()

        XCTAssertGreaterThanOrEqual(locationDatabase.count(), 0, "Location delete all result is 0")
    }
    
    func testLocationTrackerInitialization() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let authHelper = AuthHelper()
        let authProvider = try await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolID)

        let locationTracker = LocationTracker(provider: authProvider!, trackerName: trackerName)

        XCTAssertNotNil(locationTracker, "Tracker should be successfully initialized")
        XCTAssertGreaterThanOrEqual(locationTracker.getTrackerConfig().trackingTimeInterval, 30, "Tracker time interval ")
        XCTAssertNotNil(locationTracker.getDeviceId(), "Tracker device Id")
        XCTAssertNotNil(Logger.getLoggerKey())
    }
    
    func testLocationStartTracking() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let authHelper = AuthHelper()
        let authProvider = try await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolID)
        
        let locationTracker = LocationTracker(provider: authProvider!, trackerName: trackerName)

        try locationTracker.startTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has started")
        
        let location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        
        _ = try await locationTracker.trackLocation(location: location)
        
        locationTracker.stopTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
        
        try locationTracker.resumeTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has resumed")
        locationTracker.stopTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
    }
    
    func testLocationStartBackgroundTracking() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let authHelper = AuthHelper()
        let authProvider = try await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolID)
        
        let locationTracker = LocationTracker(provider: authProvider!, trackerName: trackerName)
        try locationTracker.startBackgroundTracking(mode: .None)
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has started")
        
        let location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        
        _ = try await locationTracker.trackLocation(location: location)
        
        locationTracker.stopBackgroundTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
        
        try locationTracker.resumeBackgroundTracking(mode: .None)
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has resumed")
        locationTracker.stopBackgroundTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
    }
    
    func testLocationTrackingConfig() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let authHelper = AuthHelper()
        let authProvider = try await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolID)
        
        let locationTracker = LocationTracker(provider: authProvider!, trackerName: trackerName)
        let trackerConfig = LocationTrackerConfig(locationFilters: [TimeLocationFilter(), DistanceLocationFilter(), AccuracyLocationFilter()], trackingDistanceInterval: 30, trackingTimeInterval: 30, trackingAccuracyLevel: 1, uploadFrequency: 60, desiredAccuracy: kCLLocationAccuracyBest, activityType: CLActivityType.fitness, logLevel: .debug)
        locationTracker.setTrackerConfig(config: trackerConfig)
        let trackerConfig1 = locationTracker.getTrackerConfig()
        XCTAssertEqual(trackerConfig.trackingTimeInterval, trackerConfig1.trackingTimeInterval, "Location tracker config set successfully")
    }
    
    func testUserDefaultsHelper() {
        UserDefaultsHelper.removeObject(for: .DeviceID)
      XCTAssertNil(UserDefaultsHelper.getObject(value: String.self, key: .DeviceID), "Device ID is nil")
    }
    
    func testLocationTrackingConfigDefault() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let authHelper = AuthHelper()
        let authProvider = try await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolID)
        
        let locationTracker = LocationTracker(provider: authProvider!, trackerName: trackerName)
        let trackerConfig = LocationTrackerConfig()
        locationTracker.setTrackerConfig(config: trackerConfig)
        let trackerConfig1 = locationTracker.getTrackerConfig()
        XCTAssertEqual(trackerConfig.trackingTimeInterval, trackerConfig1.trackingTimeInterval, "Location tracker config set successfully")
    }
    
    
    func testTimeFilter() async throws {
        let locationDatabase = LocationDatabase()
        let filter = TimeLocationFilter()
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let authHelper = AuthHelper()
        let authProvider = try await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolID)
        
        let locationTracker = LocationTracker(provider: authProvider!, trackerName: trackerName)
        var location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let currentLocationEntity = locationDatabase.save(location: location)
        currentLocationEntity?.timestamp = Date()
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let previousLocationEntity = locationDatabase.save(location: location)
        previousLocationEntity?.timestamp = Calendar.current.date(byAdding: .minute, value: -2, to: Date())
        
        let shouldUpload = filter.shouldUpload(currentLocation: currentLocationEntity!, previousLocation: previousLocationEntity!, trackerConfig: locationTracker.getTrackerConfig())
        
        XCTAssertEqual(shouldUpload, true, "TimeFilter location should upload")
    }
    
    func testDistanceFilter() async throws {
        let locationDatabase = LocationDatabase()
        let filter = DistanceLocationFilter()
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let authHelper = AuthHelper()
        let authProvider = try await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolID)
        
        let locationTracker = LocationTracker(provider: authProvider!, trackerName: trackerName)
        var location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        let currentLocationEntity = locationDatabase.save(location: location)
        currentLocationEntity?.timestamp = Date()
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let previousLocationEntity = locationDatabase.save(location: location)
        previousLocationEntity?.timestamp = Calendar.current.date(byAdding: .minute, value: -2, to: Date())
        
        let shouldUpload = filter.shouldUpload(currentLocation: currentLocationEntity!, previousLocation: previousLocationEntity!, trackerConfig: locationTracker.getTrackerConfig())
        
        XCTAssertEqual(shouldUpload, true, "DistanceFilter location should upload")
    }
    
    func testAccuracyFilter() async throws {
        let locationDatabase = LocationDatabase()
        let filter = AccuracyLocationFilter()
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let authHelper = AuthHelper()
        let authProvider = try await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolID)
        
        let locationTracker = LocationTracker(provider: authProvider!, trackerName: trackerName)
        var location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        let currentLocationEntity = locationDatabase.save(location: location)
        currentLocationEntity?.timestamp = Date()
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let previousLocationEntity = locationDatabase.save(location: location)
        previousLocationEntity?.timestamp = Calendar.current.date(byAdding: .minute, value: -2, to: Date())
        
        let shouldUpload = filter.shouldUpload(currentLocation: currentLocationEntity!, previousLocation: previousLocationEntity!, trackerConfig: locationTracker.getTrackerConfig())
        
        XCTAssertEqual(shouldUpload, true, "AccuracyFilter location should upload")
    }
    
    func testArrayChunk() {
        let chunks = Utils.chunked(Array(0...99), size: 10)
        
        XCTAssertEqual(chunks.count, 10, "Chunk value is 10")
    }
    
    func testGetTrackingLocations() async throws {
        let config = readTestConfig()
        let identityPoolId = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let cognitoProvider = try await AuthHelper().authenticateWithCognitoIdentityPool(identityPoolId: identityPoolId)
        let tracker = LocationTracker(provider: cognitoProvider!, trackerName: trackerName)
        let startTime: Date = Date().addingTimeInterval(-86400)
        let endTime: Date = Date()
        let result = try await tracker.getTrackerDeviceLocation(nextToken: nil, startTime: startTime, endTime: endTime)
        
        XCTAssertNotNil(result, "Found device's tracker locations")
    }

    func testLocationManager() {
        let locationProvider = LocationProvider()
        locationProvider.locationPermissionManager!.setBackgroundMode(mode: .None)
        
        XCTAssertEqual(locationProvider.locationPermissionManager!.hasLocationPermission(), false)
        XCTAssertEqual(locationProvider.locationPermissionManager!.hasAlwaysLocationPermission(), false)
        XCTAssertEqual(locationProvider.locationPermissionManager!.hasLocationPermissionDenied(), false)
        XCTAssertEqual(locationProvider.locationPermissionManager!.checkPermission() , .notDetermined)
    }
    
    func testBatchUpdateDevicePosition() async throws {
        let config = readTestConfig()
        let identityPoolId = config["identityPoolID"]!
        let region = config["region"]!
        let trackerName = config["trackerName"]!
        
        let authHelper = AuthHelper()
        _ = try? await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolId, region: region)
        
        let amazonClient = authHelper.getLocationClient()
        
        let update = DevicePositionUpdate(accuracy: DevicePositionalAccuracy.init(horizontal: 1), deviceId: "DeviceID", position: [-71.985564, 41.758023], positionProperties: nil, sampleTime: Date())
        let updates = [update]
        let request = BatchUpdateDevicePositionRequest(trackerName: trackerName, updates: updates)
        
        let positionUpdateResponse = try? await amazonClient!.batchUpdateDevicePosition(request: request)
        
        XCTAssertEqual(positionUpdateResponse?.errors?.count, 0, "Device Position updated successfully")
    }
    
    private func getCurrentDate() -> String {
        let currentDate = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let formattedDateString = dateFormatter.string(from: currentDate)

        return formattedDateString
    }
}
