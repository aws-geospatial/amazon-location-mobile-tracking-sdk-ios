import Foundation
import AWSLocation

@objc public class BatchUpdateDevicePositionResponse: NSObject {
    /// Contains error details for each device that failed to update its position.
    /// This member is required.
    public var errors: [BatchUpdateDevicePositionError]?

    public init(
        errors: [BatchUpdateDevicePositionError]? = nil
    )
    {
        self.errors = errors
    }
    
    internal static func fromStruct(_ output: BatchUpdateDevicePositionOutput) -> BatchUpdateDevicePositionResponse {
        var responseErrors: [BatchUpdateDevicePositionError]? = nil
        if let errors = output.errors {
            responseErrors = []
            for itemError in errors {
                let batchItemErrorCode: BatchItemErrorCode? = BatchItemErrorCode(rawValue: (itemError.error?.code?.rawValue)!)
                let batchItemError = BatchItemError(code: batchItemErrorCode, message: itemError.error?.message)
                let error = BatchUpdateDevicePositionError(deviceId: itemError.deviceId, error: batchItemError, sampleTime: itemError.sampleTime)
                responseErrors?.append(error)
            }
        }
        return BatchUpdateDevicePositionResponse(errors: responseErrors)
    }
}

/// Contains error details for each device that failed to update its position.
@objc public class BatchUpdateDevicePositionError: NSObject {
    /// The device associated with the failed location update.
    /// This member is required.
    public var deviceId: Swift.String?
    /// Contains details related to the error code such as the error code and error message.
    /// This member is required.
    public var error: BatchItemError?
    /// The timestamp at which the device position was determined. Uses [ ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format: YYYY-MM-DDThh:mm:ss.sssZ.
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

/// Contains the batch request error details associated with the request.
@objc public class BatchItemError: NSObject {
    /// The error code associated with the batch request error.
    public var code: BatchItemErrorCode?
    /// A message with the reason for the batch request error.
    public var message: Swift.String?

    public init(
        code: BatchItemErrorCode? = nil,
        message: Swift.String? = nil
    )
    {
        self.code = code
        self.message = message
    }
}

@objc public enum BatchItemErrorCode: Int, CaseIterable {
    case accessDeniedError
    case conflictError
    case internalServerError
    case resourceNotFoundError
    case throttlingError
    case validationError
    case sdkUnknown

    public static var allCases: [BatchItemErrorCode] {
        return [
            .accessDeniedError,
            .conflictError,
            .internalServerError,
            .resourceNotFoundError,
            .throttlingError,
            .validationError,
            .sdkUnknown
        ]
    }

    public init(rawValue: String) {
        switch rawValue {
        case "AccessDeniedError":
            self = .accessDeniedError
        case "ConflictError":
            self = .conflictError
        case "InternalServerError":
            self = .internalServerError
        case "ResourceNotFoundError":
            self = .resourceNotFoundError
        case "ThrottlingError":
            self = .throttlingError
        case "ValidationError":
            self = .validationError
        default:
            self = .sdkUnknown
        }
    }

    public var rawValue: String {
        switch self {
        case .accessDeniedError:
            return "AccessDeniedError"
        case .conflictError:
            return "ConflictError"
        case .internalServerError:
            return "InternalServerError"
        case .resourceNotFoundError:
            return "ResourceNotFoundError"
        case .throttlingError:
            return "ThrottlingError"
        case .validationError:
            return "ValidationError"
        case .sdkUnknown:
            return "SDKUnknown"
        }
    }
}
