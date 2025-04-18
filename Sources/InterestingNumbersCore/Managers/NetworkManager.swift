import Foundation
import Combine

final class NetworkManager: NSObject, QueryHandler {
    private let endpoint = "http://numbersapi.com/"
    private let decoder = JSONDecoder()

    func request(query: Query) -> AnyPublisher<Numbers, Error> {
        switch query {
        case .userValue(let number):
            return makeApiCall(query: String(number), type: Number.self)
                .map { [String($0.number): $0.text] }
                .eraseToAnyPublisher()
        case .random:
            return makeApiCall(query: "random", type: Number.self)
                .map { [String($0.number): $0.text] }
                .eraseToAnyPublisher()
        case .range(let range):
            return makeApiCall(query: "\(range.lowerBound)..\(range.upperBound)", type: Numbers.self)
        case .multiple(let numbers):
            return makeApiCall(query: numbers.map { String($0) }.joined(separator: ","), type: Numbers.self)
        }
    }

    private func makeApiCall<T: Decodable>(query: String, type: T.Type) -> AnyPublisher<T, Error> {
        let query = endpoint + "\(query)?json"
        guard let url = URL(string: query) else { return Fail(error: NetworkError.invalidData).eraseToAnyPublisher() }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResp = response as? HTTPURLResponse else { throw NetworkError.badResponse }
                guard httpResp.statusCode == 200 else { throw NetworkError.wrongStatusCode(httpResp.statusCode) }
                return data
            }
            .decode(type: type, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
