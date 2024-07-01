import Foundation
import AWSLocation

@objc public class BatchEvaluateGeofencesResponse: NSObject {
    /// Contains error details for each device that failed to evaluate its position against the given geofence collection.
    /// This member is required.
    public var errors: [BatchEvaluateGeofencesError]?

    public init(
        errors: [BatchEvaluateGeofencesError]? = nil
    )
    {
        self.errors = errors
    }
    
    internal static func fromStruct(_ output: BatchEvaluateGeofencesOutput) -> BatchEvaluateGeofencesResponse {
        var responseErrors: [BatchEvaluateGeofencesError]? = nil
        if let errors = output.errors {
            responseErrors = []
            for itemError in errors {
                let batchItemErrorCode: BatchItemErrorCode? = BatchItemErrorCode(rawValue: (itemError.error?.code?.rawValue)!)
                let batchItemError = BatchItemError(code: batchItemErrorCode, message: itemError.error?.message)
                let error = BatchEvaluateGeofencesError(deviceId: itemError.deviceId, error: batchItemError, sampleTime: itemError.sampleTime)
                responseErrors?.append(error)
            }
        }
        return BatchEvaluateGeofencesResponse(errors: responseErrors)
    }
}

@objc public class BatchEvaluateGeofencesError: NSObject {
    /// The device associated with the position evaluation error.
    /// This member is required.
    public var deviceId: Swift.String?
    /// Contains details associated to the batch error.
    /// This member is required.
    public var error: BatchItemError?
    /// Specifies a timestamp for when the error occurred in [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format: YYYY-MM-DDThh:mm:ss.sssZ
    /// This member is required.
    public var sampleTime: Foundation.Date?

    public init(
        deviceId: Swift.String? = nil,
        error: BatchItemError? = nil,
        sampleTime: Foundation.Date? = nil
    )
    {
        self.deviceId = deviceId
        self.error = error
        self.sampleTime = sampleTime
    }
}
