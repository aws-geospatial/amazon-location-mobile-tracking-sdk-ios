import XCTest
import CoreLocation
@testable import AmazonLocationiOSTrackingSDK

class MockLocationDatabase {
    var mockLocations: [MockLocationEntity] = []
    var saveCallCount = 0
    var deleteCallCount = 0
    var shouldFailSave = false
    
    func save(location: CLLocation?) -> MockLocationEntity? {
        saveCallCount += 1
        guard let location = location, !shouldFailSave else { return nil }
        
        let entity = MockLocationEntity()
        entity.latitude = location.coordinate.latitude
        entity.longitude = location.coordinate.longitude
        entity.accuracy = location.horizontalAccuracy
        entity.timestamp = Date()
        entity.id = UUID()
        
        mockLocations.append(entity)
        return entity
    }
    
    func fetchAll() -> [MockLocationEntity] {
        return mockLocations
    }
    
    func delete(locations: [MockLocationEntity]) {
        deleteCallCount += 1
        mockLocations.removeAll { entity in
            locations.contains { $0.id == entity.id }
        }
    }
    
    func deleteAll() {
        mockLocations.removeAll()
    }
    
    func count() -> Int {
        return mockLocations.count
    }
    
    func delete(locationID: String) {
         deleteCallCount += 1
         mockLocations.removeAll { $0.id?.uuidString == locationID }
     }
}

class MockLocationEntity {
    var id: UUID?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var accuracy: Double = 0.0
    var timestamp: Date?
}

class MockLocationFilter: LocationFilter {
    var shouldUploadResult = true
    var callCount = 0
    
    func shouldUpload(currentLocation: LocationEntity, previousLocation: LocationEntity?, trackerConfig: LocationTrackerConfig) -> Bool {
        callCount += 1
        return shouldUploadResult
    }
    
    func shouldUploadMock(currentLocation: MockLocationEntity, previousLocation: MockLocationEntity?, trackerConfig: LocationTrackerConfig) -> Bool {
        callCount += 1
        return shouldUploadResult
    }
}

class MockDeviceIdProvider {
    static var mockDeviceId: String?
    
    static func getDeviceID() -> String? {
        return mockDeviceId
    }
    
    static func setDeviceID(deviceID: String? = nil) {
        mockDeviceId = deviceID ?? UUID().uuidString
    }
    
    static func clearDeviceID() {
        mockDeviceId = nil
    }
}

class MockUserDefaults {
    static var storage: [String: Any] = [:]
    
    static func save<T>(value: T, key: String) {
        storage[key] = value
    }
    
    static func get<T>(for type: T.Type, key: String) -> T? {
        return storage[key] as? T
    }
    
    static func removeObject(for key: String) {
        storage.removeValue(forKey: key)
    }
    
    static func clear() {
        storage.removeAll()
    }
}

class MockLocationTracker {
    var isTrackingActive = false
    var mockConfig = LocationTrackerConfig()
    var mockDeviceId = "mock-device-123"
    var startTrackingCallCount = 0
    var stopTrackingCallCount = 0
    var startBackgroundTrackingCallCount = 0
    var stopBackgroundTrackingCallCount = 0
    var shouldThrowError = false
    var trackLocationCallCount = 0
    
    func startTracking() throws {
        startTrackingCallCount += 1
        if shouldThrowError {
            throw TrackingLocationError.permissionDenied
        }
        isTrackingActive = true
    }
    
    func stopTracking() {
        stopTrackingCallCount += 1
        isTrackingActive = false
    }
    
    func resumeTracking() throws {
        try startTracking()
    }
    
    func startBackgroundTracking(mode: BackgroundTrackingMode) throws {
        startBackgroundTrackingCallCount += 1
        if shouldThrowError {
            throw TrackingLocationError.permissionDenied
        }
        isTrackingActive = true
    }
    
    func stopBackgroundTracking() {
        stopBackgroundTrackingCallCount += 1
        isTrackingActive = false
    }
    
    func resumeBackgroundTracking(mode: BackgroundTrackingMode) throws {
        try startBackgroundTracking(mode: mode)
    }
    
    func trackLocation(location: CLLocation) {
        trackLocationCallCount += 1
    }
    
    func setTrackerConfig(config: LocationTrackerConfig) {
        mockConfig = config
    }
    
    func getTrackerConfig() -> LocationTrackerConfig {
        return mockConfig
    }
    
    func getDeviceId() -> String {
        return mockDeviceId
    }
}


class MockLocationPermissionManager {
    var mockPermissionStatus: CLAuthorizationStatus = .notDetermined
    var mockBackgroundMode: BackgroundTrackingMode = .None
    var requestPermissionCallCount = 0
    var requestAlwaysPermissionCallCount = 0
    var setBackgroundModeCallCount = 0
    var allowsBackgroundLocationUpdates = false
    var pausesLocationUpdatesAutomatically = true
    
    func hasLocationPermission() -> Bool {
           #if os(iOS)
           return mockPermissionStatus == .authorizedWhenInUse || mockPermissionStatus == .authorizedAlways
           #else
           return mockPermissionStatus == .authorizedAlways
           #endif
       }
    
    func hasAlwaysLocationPermission() -> Bool {
        return mockPermissionStatus == .authorizedAlways
    }
    
    func hasLocationPermissionDenied() -> Bool {
        return mockPermissionStatus == .denied || mockPermissionStatus == .restricted
    }
    
    func checkPermission() -> CLAuthorizationStatus {
        return mockPermissionStatus
    }
    
    func requestPermission() {
        requestPermissionCallCount += 1
    }
    
    func requestAlwaysPermission() {
        requestAlwaysPermissionCallCount += 1
    }
    
    func setBackgroundMode(mode: BackgroundTrackingMode) {
        setBackgroundModeCallCount += 1
        mockBackgroundMode = mode
        
        switch mode {
        case .Active:
            allowsBackgroundLocationUpdates = true
            pausesLocationUpdatesAutomatically = false
        case .BatterySaving:
            allowsBackgroundLocationUpdates = true
            pausesLocationUpdatesAutomatically = true
        case .None:
            allowsBackgroundLocationUpdates = false
            pausesLocationUpdatesAutomatically = false
        }
    }
}

class MockLocationProvider {
    var mockLocationPermissionManager: MockLocationPermissionManager?
    
    init() {
        mockLocationPermissionManager = MockLocationPermissionManager()
    }
}

