import Foundation

public enum ValidationError: LocalizedError {
    case wrongSymbols
    case wrongMultipleFormat

    var errorDescription: String {
        switch self {
        case .wrongSymbols: "Wrong symbols!. Please use numbers only"
        case .wrongMultipleFormat: "Wrong format. Please input numbers separated by whitespaces (e.g 1 2 3)"
        }
    }
    var localizedDescription: String { errorDescription }
}
