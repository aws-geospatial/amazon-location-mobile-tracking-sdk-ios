import XCTest
import CoreLocation
@testable import AmazonLocationiOSTrackingSDK
import AmazonLocationiOSAuthSDK
import AWSLocation

final class LocationPermissionTests: XCTestCase {
    
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

    func testLocationStartTracking() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)

        try locationTracker.startTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has started")
        
        let location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        
        locationTracker.trackLocation(location: location)
        
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

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
        try locationTracker.startBackgroundTracking(mode: .None)
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has started")
        
        let location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        
        locationTracker.trackLocation(location: location)
        
        locationTracker.stopBackgroundTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
        
        try locationTracker.resumeBackgroundTracking(mode: .None)
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has resumed")
        locationTracker.stopBackgroundTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
    }

    func testLocationManager() throws {
        let locationProvider = LocationProvider()
        locationProvider.locationPermissionManager!.setBackgroundMode(mode: .None)
        
        XCTAssertEqual(locationProvider.locationPermissionManager!.hasLocationPermission(), false)
        XCTAssertEqual(locationProvider.locationPermissionManager!.hasAlwaysLocationPermission(), false)
        XCTAssertEqual(locationProvider.locationPermissionManager!.hasLocationPermissionDenied(), false)
        XCTAssertEqual(locationProvider.locationPermissionManager!.checkPermission() , .notDetermined)
    }
}