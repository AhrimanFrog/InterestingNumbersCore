import Combine

extension Publisher {
    func sink(_ resultHandler: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
        return sink(
            receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure(let error): resultHandler(.failure(error))
                }
            },
            receiveValue: { value in resultHandler(.success(value)) }
        )
    }
}
