import Foundation

public enum NetworkError: LocalizedError {
    case networkProblem
    case invalidData
    case badRequest
    case badResponse
    case wrongStatusCode(Int)

    var errorDescription: String {
        return switch self {
        case .networkProblem: "Cannot send request. Check your network connection"
        case .badRequest: "Cannot fetch data. Bad request"
        case .invalidData: "Cannot form request. Invalid data input"
        case .badResponse: "Cannot convert data, try again"
        case .wrongStatusCode(let code): "Wrong status code received - \(code). Cannot convert data"
        }
    }

    var localizedDescription: String { errorDescription }
}
