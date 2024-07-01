import Foundation
import AmazonLocationiOSAuthSDK
import AWSLocation
import AWSClientRuntime

@objc public extension AmazonLocationClient {
    
    @objc func batchUpdateDevicePosition(request: BatchUpdateDevicePositionRequest) async throws -> BatchUpdateDevicePositionResponse? {
        do {
            if locationProvider.getCredentialsProvider() != nil {
                if locationClient == nil {
                    try await initialiseLocationClient()
                }
                
                var updates:[LocationClientTypes.DevicePositionUpdate]? = nil
                if let requestUpdates = request.updates {
                    updates = []
                    for item in requestUpdates {
                        var accuracy: LocationClientTypes.PositionalAccuracy? = nil
                        if let itemAccuracy = item.accuracy, let horizontal = itemAccuracy.horizontal {
                            let accuracyHorizontal = horizontal.doubleValue
                            accuracy = LocationClientTypes.PositionalAccuracy(horizontal: accuracyHorizontal)
                        }
                        let inputUpdate: LocationClientTypes.DevicePositionUpdate = LocationClientTypes.DevicePositionUpdate(accuracy: accuracy, deviceId: item.deviceId, position: item.position, positionProperties: item.positionProperties, sampleTime: item.sampleTime)
                        updates?.append(inputUpdate)
                    }
                }
                
                let input = BatchUpdateDevicePositionInput(trackerName: request.trackerName, updates: updates)
                let response = try await locationClient!.batchUpdateDevicePosition(input: input)
                return BatchUpdateDevicePositionResponse.fromStruct(response)
            }
        }
        catch {
            throw error
        }
        return nil
    }
    
    @objc func getDevicePositionHistory(request: GetDevicePositionHistoryRequest) async throws -> GetDevicePositionHistoryResponse? {
        do {
            if locationProvider.getCredentialsProvider() != nil {
                if locationClient == nil {
                    try await initialiseLocationClient()
                }
                let input = GetDevicePositionHistoryInput(deviceId: request.deviceId, endTimeExclusive: request.endTimeExclusive, maxResults: request.maxResults as? Int, nextToken: request.nextToken, startTimeInclusive: request.startTimeInclusive, trackerName: request.trackerName)
                let response = try await locationClient!.getDevicePositionHistory(input: input)
                return GetDevicePositionHistoryResponse.fromStruct(response)
            }
        }
        catch {
            throw error
        }
        return nil
    }
    
    @objc func batchEvaluateGeofences(request: BatchEvaluateGeofencesRequest) async throws -> BatchEvaluateGeofencesResponse? {
        do {
            if locationProvider.getCredentialsProvider() != nil {
                if locationClient == nil {
                    try await initialiseLocationClient()
                }
                let response = try await locationClient!.batchEvaluateGeofences(input: request.toStruct())
                return BatchEvaluateGeofencesResponse.fromStruct(response)
            }
        }
        catch {
            throw error
        }
        return nil
    }
}
