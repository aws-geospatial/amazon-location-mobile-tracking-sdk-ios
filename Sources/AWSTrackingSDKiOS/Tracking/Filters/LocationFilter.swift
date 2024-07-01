import Foundation

@objc public protocol LocationFilter {
    func shouldUpload(currentLocation: LocationEntity, previousLocation: LocationEntity?, trackerConfig: LocationTrackerConfig) -> Bool
}

public struct LocationFilterOptionSet: OptionSet, Codable, Hashable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let time = LocationFilterOptionSet(rawValue: 1 << 0)
    public static let distance = LocationFilterOptionSet(rawValue: 1 << 1)
    public static let accuracy = LocationFilterOptionSet(rawValue: 1 << 2)
}
