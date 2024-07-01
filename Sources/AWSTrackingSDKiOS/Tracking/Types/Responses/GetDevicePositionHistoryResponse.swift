import Foundation
import AWSLocation

@objc public class GetDevicePositionHistoryResponse: NSObject {
    @objc public var devicePositions: [DevicePosition]?
    @objc public var nextToken: String?

    @objc public init(
        devicePositions: [DevicePosition]? = nil,
        nextToken: String? = nil
    ) {
        self.devicePositions = devicePositions
        self.nextToken = nextToken
    }
    
    internal static func fromStruct(_ output: GetDevicePositionHistoryOutput) -> GetDevicePositionHistoryResponse {
        var devicePositions: [DevicePosition]? = nil
        if let positions = output.devicePositions {
            devicePositions = []
            for item in positions {
                var accuracy: DevicePositionalAccuracy? = nil
                if let itemAccuracy = item.accuracy, let horizontal = itemAccuracy.horizontal {
                    let accuracyHorizontal = NSNumber(value: horizontal)
                    accuracy = DevicePositionalAccuracy(horizontal: accuracyHorizontal)
                }
                let position = DevicePosition(accuracy: accuracy, deviceId: item.deviceId, position: item.position, positionProperties: item.positionProperties, receivedTime: item.receivedTime, sampleTime: item.sampleTime)
                devicePositions?.append(position)
            }
        }
        return GetDevicePositionHistoryResponse(devicePositions: devicePositions, nextToken: output.nextToken)
    }
}

@objc public class DevicePosition: NSObject {
    @objc public var accuracy: DevicePositionalAccuracy?
    @objc public var deviceId: String?
    @objc public var position: [Double]?
    @objc public var positionProperties: [String: String]?
    @objc public var receivedTime: Date?
    @objc public var sampleTime: Date?

    @objc public init(
        accuracy: DevicePositionalAccuracy? = nil,
        deviceId: String? = nil,
        position: [Double]? = nil,
        positionProperties: [String: String]? = nil,
        receivedTime: Date? = nil,
        sampleTime: Date? = nil
    ) {
        self.accuracy = accuracy
        self.deviceId = deviceId
        self.position = position
        self.positionProperties = positionProperties
        self.receivedTime = receivedTime
        self.sampleTime = sampleTime
    }
}

@objc public class DevicePositionalAccuracy: NSObject {
    @objc public var horizontal: NSNumber?

    @objc public init(horizontal: NSNumber? = nil) {
        self.horizontal = horizontal
    }
}
