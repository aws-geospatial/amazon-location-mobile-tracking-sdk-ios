import Foundation

@objc public class GetDevicePositionHistoryRequest: NSObject {
    @objc public var deviceId: String?
    @objc public var endTimeExclusive: Date?
    @objc public var maxResults: NSNumber?
    @objc public var nextToken: String?
    @objc public var startTimeInclusive: Date?
    @objc public var trackerName: String?

    @objc public init(
        deviceId: String? = nil,
        endTimeExclusive: Date? = nil,
        maxResults: NSNumber? = nil,
        nextToken: String? = nil,
        startTimeInclusive: Date? = nil,
        trackerName: String? = nil
    )
    {
        self.deviceId = deviceId
        self.endTimeExclusive = endTimeExclusive
        self.maxResults = maxResults
        self.nextToken = nextToken
        self.startTimeInclusive = startTimeInclusive
        self.trackerName = trackerName
    }
}
