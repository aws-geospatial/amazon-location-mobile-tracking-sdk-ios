import Foundation
import AmazonLocationiOSAuthSDK
import CoreLocation
import AWSLocation

internal class LocationUploadSerializer{
    private var deviceId: String
    private var trackerName: String
    private var client: AmazonLocationClient
    
    init(client: AmazonLocationClient, deviceId: String, trackerName: String) {
        self.deviceId = deviceId
        self.trackerName = trackerName
        self.client = client
    }
    
    func updateDeviceLocation(locations: [LocationEntity]) async throws -> BatchUpdateDevicePositionResponse? {
        var positions: [DevicePositionUpdate] = []
        
        for location in locations {
            let positionUpdate = DevicePositionUpdate(accuracy: .init(horizontal: location.accuracy as NSNumber), deviceId: deviceId, position: [location.longitude, location.latitude], positionProperties: [:], sampleTime: Date())
            positions.append(positionUpdate)
        }

        let request = BatchUpdateDevicePositionRequest(trackerName: trackerName, updates: positions)
        let result = try await client.batchUpdateDevicePosition(request: request)
        
        return result
    }
    
    func getDeviceLocation(nextToken: String? = nil, startTime: Date? = nil, endTime: Date? = nil, maxResults: Int? = nil) async throws -> GetDevicePositionHistoryResponse? {
        let request = GetDevicePositionHistoryRequest(deviceId: deviceId, endTimeExclusive: endTime, maxResults: maxResults as NSNumber?, nextToken: nextToken, startTimeInclusive: startTime, trackerName: trackerName)
        let result = try await client.getDevicePositionHistory(request: request)
        return result
    }
    
    func batchEvaluateGeofences(request: BatchEvaluateGeofencesRequest) async throws -> BatchEvaluateGeofencesResponse? {
        return try await client.batchEvaluateGeofences(request: request)
    }
}
