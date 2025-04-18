import Foundation

public enum DBError: LocalizedError {
    case cannotRetrieveNumber

    var errorDescription: String {
        switch self {
        case .cannotRetrieveNumber: "Cannot retrieve number. Restore connection and try again"
        }
    }
    var localizedDescription: String { errorDescription }
}
