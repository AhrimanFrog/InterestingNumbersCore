@preconcurrency import Combine
import Network

public final class InterestingNumbers: DataProvider {
    private let networkProvider: QueryHandler
    private let dbProvider: QueryHandler & Preserver
    private let networkMonitor = NWPathMonitor()
    private let monitoringQueue = DispatchQueue(label: "NetworkQueue")

    private var preservationSubscription: AnyCancellable?

    public let isConnected = CurrentValueSubject<Bool, Never>(true)

    public init(networkProvider: QueryHandler, dbProvider: QueryHandler & Preserver) {
        self.networkProvider = networkProvider
        self.dbProvider = dbProvider
        startMonitoringConnection()
    }

    public convenience init() {
        self.init(networkProvider: NetworkManager(), dbProvider: DBManager())
    }

    public func request(query: Query) -> AnyPublisher<Numbers, Error> {
        return dbProvider.request(query: query)
            .catch { [weak self] error -> AnyPublisher<Numbers, Error> in
                guard let self else { return Fail(error: error).eraseToAnyPublisher() }
                return getDataFromInternet(query)
            }
            .eraseToAnyPublisher()
    }

    private func getDataFromInternet(_ query: Query) -> AnyPublisher<Numbers, Error> {
        let pub = networkProvider.request(query: query)
        preservationSubscription = pub.sink { [weak self] result in
            switch result {
            case .success(let numbers): self?.dbProvider.preserve(numbers: numbers)
            case .failure: break
            }
        }
        return pub
    }

    private func startMonitoringConnection() {
        networkMonitor.pathUpdateHandler = { [isConnected] path in
            isConnected.send(path.status == .satisfied)
        }
        networkMonitor.start(queue: monitoringQueue)
    }
}
