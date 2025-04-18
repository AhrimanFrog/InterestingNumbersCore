public enum Query: Equatable {
    case userValue(Int)
    case random
    case range(ClosedRange<Int>)
    case multiple([Int])
}
