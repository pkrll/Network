import Foundation

extension URLError {
    var httpErrorCode: HttpError.Code {
        let code: HttpError.Code
        
        switch self.code {
        case .badServerResponse,
             .cannotDecodeContentData,
             .cannotDecodeRawData,
             .cannotParseResponse:
            code = .invalidResponse
        case .badURL,
             .cannotFindHost,
             .unsupportedURL:
            code = .invalidRequest
        case .cancelled:
            code = .cancelled
        case .clientCertificateRejected,
             .clientCertificateRequired,
             .serverCertificateHasBadDate,
             .serverCertificateHasUnknownRoot,
             .serverCertificateNotYetValid,
             .serverCertificateUntrusted,
             .secureConnectionFailed:
            code = .insecureConnection
        case .dataLengthExceedsMaximum:
            code = .bodyExceedsMaximum
        case .notConnectedToInternet:
            code = .noConnection
        case .userAuthenticationRequired,
             .userCancelledAuthentication:
            code = .unauthorized
        default:
            code = .unknown
        }
        
        return code
    }
}
