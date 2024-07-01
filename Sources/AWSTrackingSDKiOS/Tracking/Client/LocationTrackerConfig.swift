import CoreLocation

private struct TrackerConfigCodable: Codable  {
    public var locationFilters: LocationFilterOptionSet
    public var trackingDistanceInterval: Double
    public var trackingTimeInterval: Double
    public var trackingAccuracyLevel: Double
    public var uploadFrequency: Double
    public var desiredAccuracy: CLLocationAccuracy
    public var activityType: CLActivityType.RawValue
    public var logLevel: LogLevel
    
    public init(locationFilters: LocationFilterOptionSet? = nil,
                trackingDistanceInterval: Double? = nil,
                trackingTimeInterval: Double? = nil,
                trackingAccuracyLevel: Double? = nil,
                uploadFrequency: Double? = nil,
                desiredAccuracy: CLLocationAccuracy? = nil,
                activityType: CLActivityType? = nil,
                logLevel: LogLevel? = nil) {
        self.locationFilters = locationFilters ?? [.time]
        self.trackingDistanceInterval = trackingDistanceInterval ?? Constants.FilterDistanceInterval
        self.trackingTimeInterval = trackingTimeInterval ?? Constants.FilterTimeInterval
        self.trackingAccuracyLevel = trackingAccuracyLevel ?? Constants.FilterAccuracyInterval
        self.uploadFrequency = uploadFrequency ?? Constants.UploadFrequency
        self.desiredAccuracy = desiredAccuracy ?? kCLLocationAccuracyBest
        self.activityType = activityType?.rawValue ?? CLActivityType.fitness.rawValue
        self.logLevel = logLevel ?? .error
    }
}

@objc public class LocationTrackerConfig: NSObject {
    public var locationFilters: [LocationFilter]
    public var trackingDistanceInterval: Double
    public var trackingTimeInterval: Double
    public var trackingAccuracyLevel: Double
    public var uploadFrequency: Double
    public var desiredAccuracy: CLLocationAccuracy
    public var activityType: CLActivityType.RawValue
    public var logLevel: LogLevel
    
    public init(locationFilters: [LocationFilter]? = nil,
                trackingDistanceInterval: Double? = nil,
                trackingTimeInterval: Double? = nil,
                trackingAccuracyLevel: Double? = nil,
                uploadFrequency: Double? = nil,
                desiredAccuracy: CLLocationAccuracy? = nil,
                activityType: CLActivityType? = nil,
                logLevel: LogLevel? = nil) {
        self.locationFilters = locationFilters ?? [TimeLocationFilter()]
        self.trackingDistanceInterval = trackingDistanceInterval ?? Constants.FilterDistanceInterval
        self.trackingTimeInterval = trackingTimeInterval ?? Constants.FilterTimeInterval
        self.trackingAccuracyLevel = trackingAccuracyLevel ?? Constants.FilterAccuracyInterval
        self.uploadFrequency = uploadFrequency ?? Constants.UploadFrequency
        self.desiredAccuracy = desiredAccuracy ?? kCLLocationAccuracyBest
        self.activityType = activityType?.rawValue ?? CLActivityType.fitness.rawValue
        self.logLevel = logLevel ?? .error
    }
    
    internal static func getTrackerConfig() -> LocationTrackerConfig? {
        let trackerConfig = UserDefaultsHelper.getObject(value: TrackerConfigCodable.self, key: .LocaionTrackerConfig)
        if trackerConfig != nil {
            var locationFilters: [LocationFilter]? = nil
            if trackerConfig?.locationFilters != nil {
                locationFilters = []
                if (trackerConfig!.locationFilters.contains(.time)) {
                    locationFilters!.append(TimeLocationFilter())
                }
                if (trackerConfig!.locationFilters.contains(.distance)) {
                    locationFilters!.append(DistanceLocationFilter())
                }
                if (trackerConfig!.locationFilters.contains(.accuracy)) {
                    locationFilters!.append(AccuracyLocationFilter())
                }
            }
            
            let locationTrackerConfig = LocationTrackerConfig(locationFilters: locationFilters, trackingDistanceInterval: trackerConfig!.trackingDistanceInterval, trackingTimeInterval: trackerConfig!.trackingTimeInterval, trackingAccuracyLevel: trackerConfig!.trackingAccuracyLevel, uploadFrequency: trackerConfig!.uploadFrequency, desiredAccuracy: trackerConfig!.desiredAccuracy, activityType: CLActivityType(rawValue: trackerConfig!.activityType), logLevel: trackerConfig!.logLevel)
            return locationTrackerConfig
        }
        return nil
    }
    
    internal static func saveTrackerConfig(locationTrackerConfig: LocationTrackerConfig) {
        var locationFilters: LocationFilterOptionSet = []
        for filter in locationTrackerConfig.locationFilters {
            if filter is TimeLocationFilter {
                locationFilters = locationFilters.union(.time)
            }
            else if filter is DistanceLocationFilter {
                locationFilters = locationFilters.union(.distance)
            }
            else if filter is AccuracyLocationFilter {
                locationFilters = locationFilters.union(.accuracy)
            }
        }
        let trackerConfig = TrackerConfigCodable(locationFilters: locationFilters, trackingDistanceInterval: locationTrackerConfig.trackingDistanceInterval, trackingTimeInterval: locationTrackerConfig.trackingTimeInterval, trackingAccuracyLevel: locationTrackerConfig.trackingAccuracyLevel, uploadFrequency: locationTrackerConfig.uploadFrequency, desiredAccuracy: locationTrackerConfig.desiredAccuracy, activityType: CLActivityType(rawValue: locationTrackerConfig.activityType), logLevel: locationTrackerConfig.logLevel)
        
        UserDefaultsHelper.saveObject(value: trackerConfig, key: .LocaionTrackerConfig)
    }
}
