import Foundation
import AWSLocation

@objc public class BatchEvaluateGeofencesRequest: NSObject {
    /// The geofence collection used in evaluating the position of devices against its geofences.
    /// This member is required.
    public var collectionName: Swift.String?
    /// Contains device details for each device to be evaluated against the given geofence collection.
    /// This member is required.
    public var devicePositionUpdates: [DevicePositionUpdate]?

    public init(
        collectionName: Swift.String? = nil,
        devicePositionUpdates: [DevicePositionUpdate]? = nil
    )
    {
        self.collectionName = collectionName
        self.devicePositionUpdates = devicePositionUpdates
    }
    
    internal func toStruct() -> BatchEvaluateGeofencesInput {
        var deviceUpdates: [LocationClientTypes.DevicePositionUpdate]? = nil
        if let updates = devicePositionUpdates {
            deviceUpdates = []
            for updateItem in updates {
                var accuracy: LocationClientTypes.PositionalAccuracy? = nil
                if let deviceAccuray = updateItem.accuracy {
                    accuracy = LocationClientTypes.PositionalAccuracy(horizontal: deviceAccuray.horizontal?.doubleValue)
                }
                let update: LocationClientTypes.DevicePositionUpdate = LocationClientTypes.DevicePositionUpdate(accuracy: accuracy, deviceId: updateItem.deviceId, position: updateItem.position, positionProperties: updateItem.positionProperties, sampleTime: updateItem.sampleTime)
                deviceUpdates?.append(update)
            }
        }
        return BatchEvaluateGeofencesInput(collectionName: self.collectionName, devicePositionUpdates: deviceUpdates)
    }
}
