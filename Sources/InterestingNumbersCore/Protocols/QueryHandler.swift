import Combine

public protocol QueryHandler {
    func request(query: Query) -> AnyPublisher<Numbers, Error>
}
