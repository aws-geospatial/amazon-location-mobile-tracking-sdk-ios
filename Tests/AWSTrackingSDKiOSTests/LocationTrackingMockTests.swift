import XCTest
import CoreLocation
@testable import AmazonLocationiOSTrackingSDK


final class LocationTrackerMockTests: XCTestCase {
    
    var mockDatabase: MockLocationDatabase!
   var mockTracker: MockLocationTracker!
   var mockPermissionManager: MockLocationPermissionManager!
   var mockLocationProvider: MockLocationProvider!
   
   override func setUpWithError() throws {
       mockDatabase = MockLocationDatabase()
       mockTracker = MockLocationTracker()
       mockPermissionManager = MockLocationPermissionManager()
       mockLocationProvider = MockLocationProvider()
       MockUserDefaults.clear()
   }
   
   override func tearDownWithError() throws {
       mockDatabase = nil
       mockTracker = nil
       mockPermissionManager = nil
       mockLocationProvider = nil
       MockUserDefaults.clear()
    }
    
    // Location Database testing
    
   
    func testMockLocationDatabaseSave() {
        let location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let entity = mockDatabase.save(location: location)
        
        XCTAssertNotNil(entity)
        XCTAssertEqual(entity?.latitude, 49.246559)
        XCTAssertEqual(mockDatabase.saveCallCount, 1)
        XCTAssertEqual(mockDatabase.count(), 1)
    }
    

    func testMockLocationDatabaseSaveFailure() {
        mockDatabase.shouldFailSave = true
        let location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let entity = mockDatabase.save(location: location)
        
        XCTAssertNil(entity)
        XCTAssertEqual(mockDatabase.saveCallCount, 1)
        XCTAssertEqual(mockDatabase.count(), 0)
    }
    
    

    func testMockLocationDatabaseDelete() {
        let location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let entity = mockDatabase.save(location: location)!
        
        XCTAssertEqual(mockDatabase.count(), 1)
        
        mockDatabase.delete(locations: [entity])
        
        XCTAssertEqual(mockDatabase.deleteCallCount, 1)
        XCTAssertEqual(mockDatabase.count(), 0)
    }
    
    
    func testMockLocationDatabaseDeleteAll() {
        let location1 = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let location2 = CLLocation(latitude: 50.246559, longitude: -124.063554)
        
        mockDatabase.save(location: location1)
        mockDatabase.save(location: location2)
        
        XCTAssertEqual(mockDatabase.count(), 2)
        
        mockDatabase.deleteAll()
        
        XCTAssertEqual(mockDatabase.count(), 0)
    }
    
  
    func testMockSaveLocationToDisk() {
        let location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let locationEntity = mockDatabase.save(location: location)
        
        XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude)
        XCTAssertEqual(mockDatabase.saveCallCount, 1)
        
        let locations = mockDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 1)
        
        mockDatabase.delete(locations: [locationEntity!])
        XCTAssertEqual(mockDatabase.deleteCallCount, 1)
    }
    
    
    func testMockDeleteLocationToDisk() {
          var location = CLLocation(latitude: 49.246559, longitude: -123.063554)
          var locationEntity = mockDatabase.save(location: location)
          XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude)
          
          var locations = mockDatabase.fetchAll()
          XCTAssertGreaterThanOrEqual(locations.count, 1)
          mockDatabase.delete(locationID: locations.first!.id!.uuidString)
          
          location = CLLocation(latitude: 49.246559, longitude: -123.063554)
          locationEntity = mockDatabase.save(location: location)
          XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude)
          
          locations = mockDatabase.fetchAll()
          XCTAssertGreaterThanOrEqual(locations.count, 1)
          mockDatabase.delete(locations: locations)
          
          locations = mockDatabase.fetchAll()
          XCTAssertEqual(locations.count, 0)
          
          location = CLLocation(latitude: 49.246559, longitude: -123.063554)
          locationEntity = mockDatabase.save(location: location)
          XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude)
          
          locations = mockDatabase.fetchAll()
          XCTAssertGreaterThanOrEqual(locations.count, 1)
          mockDatabase.deleteAll()
          
          XCTAssertEqual(mockDatabase.count(), 0)
      }
    
    // Location Tracker Testing
    

    func testMockLocationTrackerPermissionError() {
        mockTracker.shouldThrowError = true
        
        XCTAssertThrowsError(try mockTracker.startTracking()) { error in
            XCTAssertTrue(error is TrackingLocationError)
        }
        
        XCTAssertFalse(mockTracker.isTrackingActive)
    }
    
    
    func testMockLocationTrackerConfig() {
        let config = LocationTrackerConfig(trackingDistanceInterval: 100, trackingTimeInterval: 60)
        
        mockTracker.setTrackerConfig(config: config)
        let retrievedConfig = mockTracker.getTrackerConfig()
        
        XCTAssertEqual(retrievedConfig.trackingTimeInterval, 60)
        XCTAssertEqual(retrievedConfig.trackingDistanceInterval, 100)
    }
    
    
    func testMockLocationTrackerInitialization() {
         XCTAssertNotNil(mockTracker)
         XCTAssertGreaterThanOrEqual(mockTracker.getTrackerConfig().trackingTimeInterval, 30)
         XCTAssertNotNil(mockTracker.getDeviceId())
         XCTAssertEqual(mockTracker.getDeviceId(), "mock-device-123")
     }
    
    
    
    func testMockLocationStartTracking() {
        XCTAssertFalse(mockTracker.isTrackingActive)
        
        try! mockTracker.startTracking()
        XCTAssertTrue(mockTracker.isTrackingActive)
        XCTAssertEqual(mockTracker.startTrackingCallCount, 1)
        
        let location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        mockTracker.trackLocation(location: location)
        XCTAssertEqual(mockTracker.trackLocationCallCount, 1)
        
        mockTracker.stopTracking()
        XCTAssertFalse(mockTracker.isTrackingActive)
        XCTAssertEqual(mockTracker.stopTrackingCallCount, 1)
        
        try! mockTracker.resumeTracking()
        XCTAssertTrue(mockTracker.isTrackingActive)
        XCTAssertEqual(mockTracker.startTrackingCallCount, 2)
        
        mockTracker.stopTracking()
        XCTAssertFalse(mockTracker.isTrackingActive)
        XCTAssertEqual(mockTracker.stopTrackingCallCount, 2)
    }
    
    
    func testMockLocationStartBackgroundTracking() {
        XCTAssertFalse(mockTracker.isTrackingActive)
        
        try! mockTracker.startBackgroundTracking(mode: .None)
        XCTAssertTrue(mockTracker.isTrackingActive)
        XCTAssertEqual(mockTracker.startBackgroundTrackingCallCount, 1)
        
        let location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        mockTracker.trackLocation(location: location)
        XCTAssertEqual(mockTracker.trackLocationCallCount, 1)
        
        mockTracker.stopBackgroundTracking()
        XCTAssertFalse(mockTracker.isTrackingActive)
        XCTAssertEqual(mockTracker.stopBackgroundTrackingCallCount, 1)
        
        try! mockTracker.resumeBackgroundTracking(mode: .None)
        XCTAssertTrue(mockTracker.isTrackingActive)
        XCTAssertEqual(mockTracker.startBackgroundTrackingCallCount, 2)
        
        mockTracker.stopBackgroundTracking()
        XCTAssertFalse(mockTracker.isTrackingActive)
        XCTAssertEqual(mockTracker.stopBackgroundTrackingCallCount, 2)
    }
    
    
    // Device Testing
    
    func testMockDeviceIdProvider() {
        MockDeviceIdProvider.clearDeviceID()
        XCTAssertNil(MockDeviceIdProvider.getDeviceID())
        
        MockDeviceIdProvider.setDeviceID()
        XCTAssertNotNil(MockDeviceIdProvider.getDeviceID())
        
        let customId = "custom-device-id"
        MockDeviceIdProvider.setDeviceID(deviceID: customId)
        XCTAssertEqual(MockDeviceIdProvider.getDeviceID(), customId)
    }
        
    
    func testMockSetDeviceIDWithID() {
        let deviceID = UUID().uuidString
        MockDeviceIdProvider.clearDeviceID()
        MockDeviceIdProvider.setDeviceID(deviceID: deviceID)
        
        XCTAssertEqual(deviceID, MockDeviceIdProvider.getDeviceID())
    }
    
    // Location Filters Testing
    
    
    func testMockLocationFilter() {
        let mockFilter = MockLocationFilter()
        let config = LocationTrackerConfig()
        let currentLocation = LocationEntity()
        let previousLocation = LocationEntity()
        
        // Test successful upload
        mockFilter.shouldUploadResult = true
        let shouldUpload1 = mockFilter.shouldUpload(currentLocation: currentLocation, previousLocation: previousLocation, trackerConfig: config)
        
        XCTAssertTrue(shouldUpload1)
        XCTAssertEqual(mockFilter.callCount, 1)
        
        // Test blocked upload
        mockFilter.shouldUploadResult = false
        let shouldUpload2 = mockFilter.shouldUpload(currentLocation: currentLocation, previousLocation: previousLocation, trackerConfig: config)
        
        XCTAssertFalse(shouldUpload2)
        XCTAssertEqual(mockFilter.callCount, 2)
    }
    
    // Location Permission Manager Testing
    
    
    func testMockLocationPermissionManagerPermissions() {
           // Test not determined status
           mockPermissionManager.mockPermissionStatus = .notDetermined
           XCTAssertFalse(mockPermissionManager.hasLocationPermission())
           XCTAssertFalse(mockPermissionManager.hasAlwaysLocationPermission())
           XCTAssertFalse(mockPermissionManager.hasLocationPermissionDenied())
           XCTAssertEqual(mockPermissionManager.checkPermission(), .notDetermined)
           
           // Test when in use permission
           #if os(iOS)
           mockPermissionManager.mockPermissionStatus = .authorizedWhenInUse
           XCTAssertTrue(mockPermissionManager.hasLocationPermission())
           XCTAssertFalse(mockPermissionManager.hasAlwaysLocationPermission())
           XCTAssertFalse(mockPermissionManager.hasLocationPermissionDenied())
            #endif
           
           // Test always permission
           mockPermissionManager.mockPermissionStatus = .authorizedAlways
           XCTAssertTrue(mockPermissionManager.hasLocationPermission())
           XCTAssertTrue(mockPermissionManager.hasAlwaysLocationPermission())
           XCTAssertFalse(mockPermissionManager.hasLocationPermissionDenied())
           
           // Test denied permission
           mockPermissionManager.mockPermissionStatus = .denied
           XCTAssertFalse(mockPermissionManager.hasLocationPermission())
           XCTAssertFalse(mockPermissionManager.hasAlwaysLocationPermission())
           XCTAssertTrue(mockPermissionManager.hasLocationPermissionDenied())
       }
       
    
       func testMockLocationPermissionManagerRequests() {
           mockPermissionManager.requestPermission()
           XCTAssertEqual(mockPermissionManager.requestPermissionCallCount, 1)
           
           mockPermissionManager.requestAlwaysPermission()
           XCTAssertEqual(mockPermissionManager.requestAlwaysPermissionCallCount, 1)
       }
       
    
       func testMockLocationPermissionManagerBackgroundModes() {
           // Test None mode
           mockPermissionManager.setBackgroundMode(mode: .None)
           XCTAssertEqual(mockPermissionManager.setBackgroundModeCallCount, 1)
           XCTAssertFalse(mockPermissionManager.allowsBackgroundLocationUpdates)
           XCTAssertFalse(mockPermissionManager.pausesLocationUpdatesAutomatically)
           
           // Test Active mode
           mockPermissionManager.setBackgroundMode(mode: .Active)
           XCTAssertEqual(mockPermissionManager.setBackgroundModeCallCount, 2)
           XCTAssertTrue(mockPermissionManager.allowsBackgroundLocationUpdates)
           XCTAssertFalse(mockPermissionManager.pausesLocationUpdatesAutomatically)
           
           // Test BatterySaving mode
           mockPermissionManager.setBackgroundMode(mode: .BatterySaving)
           XCTAssertEqual(mockPermissionManager.setBackgroundModeCallCount, 3)
           XCTAssertTrue(mockPermissionManager.allowsBackgroundLocationUpdates)
           XCTAssertTrue(mockPermissionManager.pausesLocationUpdatesAutomatically)
       }
    
    // Location Provider Testing
    
    
    func testMockLocationProvider() {
        XCTAssertNotNil(mockLocationProvider.mockLocationPermissionManager)
        
        mockLocationProvider.mockLocationPermissionManager?.setBackgroundMode(mode: .None)
        XCTAssertEqual(mockLocationProvider.mockLocationPermissionManager?.setBackgroundModeCallCount, 1)
        XCTAssertFalse(mockLocationProvider.mockLocationPermissionManager?.hasLocationPermission() ?? true)
        XCTAssertFalse(mockLocationProvider.mockLocationPermissionManager?.hasAlwaysLocationPermission() ?? true)
        XCTAssertFalse(mockLocationProvider.mockLocationPermissionManager?.hasLocationPermissionDenied() ?? true)
        XCTAssertEqual(mockLocationProvider.mockLocationPermissionManager?.checkPermission(), .notDetermined)
    }
    
    
    // Misc Testing
    
    
    func testMockUtilsChunked() {
        let array = Array(0...19)
        let chunks = Utils.chunked(array, size: 5)

        XCTAssertEqual(chunks.count, 4)
        XCTAssertEqual(chunks[0], [0, 1, 2, 3, 4])
        XCTAssertEqual(chunks[3], [15, 16, 17, 18, 19])
    }
    
    
    func testMockUserDefaults() {
        let key = "test-key"
        let value = "test-value"
        
        MockUserDefaults.save(value: value, key: key)
        let retrieved = MockUserDefaults.get(for: String.self, key: key)
        
        XCTAssertEqual(retrieved, value)
        
        MockUserDefaults.removeObject(for: key)
        let removed = MockUserDefaults.get(for: String.self, key: key)
        
        XCTAssertNil(removed)
    }
    
}
