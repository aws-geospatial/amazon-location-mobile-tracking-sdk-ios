import Foundation

@objc public class BatchUpdateDevicePositionRequest: NSObject {
    /// The name of the tracker resource to update.
    /// This member is required.
    public var trackerName: Swift.String?
    /// Contains the position update details for each device, up to 10 devices.
    /// This member is required.
    public var updates: [DevicePositionUpdate]?

    public init(
        trackerName: Swift.String? = nil,
        updates: [DevicePositionUpdate]? = nil
    )
    {
        self.trackerName = trackerName
        self.updates = updates
    }
}


@objc public class DevicePositionUpdate: NSObject {
    /// The accuracy of the device position.
    public var accuracy: DevicePositionalAccuracy?
    /// The device associated to the position update.
    /// This member is required.
    public var deviceId: Swift.String?
    /// The latest device position defined in [WGS 84](https://earth-info.nga.mil/index.php?dir=wgs84&action=wgs84) format: [X or longitude, Y or latitude].
    /// This member is required.
    public var position: [Swift.Double]?
    /// Associates one of more properties with the position update. A property is a key-value pair stored with the position update and added to any geofence event the update may trigger. Format: "key" : "value"
    public var positionProperties: [Swift.String: Swift.String]?
    /// The timestamp at which the device's position was determined. Uses [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format: YYYY-MM-DDThh:mm:ss.sssZ
    /// This member is required.
    public var sampleTime: Foundation.Date?

    public init(
        accuracy: DevicePositionalAccuracy? = nil,
        deviceId: Swift.String? = nil,
        position: [Swift.Double]? = nil,
        positionProperties: [Swift.String: Swift.String]? = nil,
        sampleTime: Foundation.Date? = nil
    )
    {
        self.accuracy = accuracy
        self.deviceId = deviceId
        self.position = position
        self.positionProperties = positionProperties
        self.sampleTime = sampleTime
    }
}
