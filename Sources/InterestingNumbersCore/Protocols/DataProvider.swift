import Combine

public protocol DataProvider: QueryHandler {
    var isConnected: CurrentValueSubject<Bool, Never> { get }
}
