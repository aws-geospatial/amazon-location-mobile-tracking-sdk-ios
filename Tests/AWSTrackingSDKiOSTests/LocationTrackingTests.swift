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

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)

        XCTAssertNotNil(locationTracker, "Tracker should be successfully initialized")
        XCTAssertGreaterThanOrEqual(locationTracker.getTrackerConfig().trackingTimeInterval, 30, "Tracker time interval ")
        XCTAssertNotNil(locationTracker.getDeviceId(), "Tracker device Id")
        XCTAssertNotNil(Logger.getLoggerKey())
    }    

    func testLocationTrackingConfig() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
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

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
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

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
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

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
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

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
        var location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        let currentLocationEntity = locationDatabase.save(location: location)
        currentLocationEntity?.timestamp = Date()
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let previousLocationEntity = locationDatabase.save(location: location)
        previousLocationEntity?.timestamp = Calendar.current.date(byAdding: .minute, value: -2, to: Date())
        
        let shouldUpload = filter.shouldUpload(currentLocation: currentLocationEntity!, previousLocation: previousLocationEntity!, trackerConfig: locationTracker.getTrackerConfig())
        
        XCTAssertEqual(shouldUpload, true, "AccuracyFilter location should upload")
    }


    func testGetTrackingLocations() async throws {
        let config = readTestConfig()
        let identityPoolId = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let tracker = try await LocationTracker(identityPoolId: identityPoolId, trackerName: trackerName)
        let startTime: Date = Date().addingTimeInterval(-86400)
        let endTime: Date = Date()
        let result = try await tracker.getTrackerDeviceLocation(nextToken: nil, startTime: startTime, endTime: endTime)
        
        XCTAssertNotNil(result, "Found device's tracker locations")
    }

    func testLocationPermissionManagerSetBackgroundModeNone() {
        let locationManager = CLLocationManager()
        let permissionManager = LocationPermissionManager(locationManager: locationManager)
        
        permissionManager.setBackgroundMode(mode: .None)
        
        XCTAssertFalse(locationManager.allowsBackgroundLocationUpdates)
        XCTAssertFalse(locationManager.pausesLocationUpdatesAutomatically)
    }


    func testBackgroundTrackingModeDescription() {
        XCTAssertEqual(BackgroundTrackingMode.Active.description, "Active")
        XCTAssertEqual(BackgroundTrackingMode.BatterySaving.description, "BatterySaving")
        XCTAssertEqual(BackgroundTrackingMode.None.description, "None")
    }


    func testLocationPermissionManagerRequestPermissions() {
        let locationManager = CLLocationManager()
        let permissionManager = LocationPermissionManager(locationManager: locationManager)
        
        // These methods should execute without crashing
        permissionManager.requestPermission()
        permissionManager.requestAlwaysPermission()
        
        XCTAssertNotNil(permissionManager)
    }


    func testLocationPermissionManagerCheckPermission() {
        let locationManager = CLLocationManager()
        let permissionManager = LocationPermissionManager(locationManager: locationManager)
        
        let status = permissionManager.checkPermission()
        
        XCTAssertNotNil(status)
    }


    func testLocationProviderInitialization() {
        let locationProvider = LocationProvider()
        
        XCTAssertNotNil(locationProvider.locationPermissionManager)
        XCTAssertNotNil(locationProvider.locationManager)
        XCTAssertNil(locationProvider.lastKnownLocation)
    }


    func testLocationProviderDidFailWithError() {
        let locationProvider = LocationProvider()
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        locationProvider.locationManager(locationProvider.locationManager, didFailWithError: testError)
        
        XCTAssertNotNil(locationProvider)
    }


    func testLocationProviderMonitoringDidFail() {
        let locationProvider = LocationProvider()
        let testRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 49.246559, longitude: -123.063554), radius: 100, identifier: "test")
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        locationProvider.locationManager(locationProvider.locationManager, monitoringDidFailFor: testRegion, withError: testError)
        
        XCTAssertNotNil(locationProvider)
    }

}

    
