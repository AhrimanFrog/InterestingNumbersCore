import Foundation
import Combine
import RealmSwift

final class DBManager: QueryHandler, Preserver {
    private let queue = DispatchQueue(label: "dbQueue", qos: .background, attributes: .concurrent)

    func request(query: Query) -> AnyPublisher<Numbers, Error> {
        queue.sync {
            let realm = try? Realm()
            switch query {
            case .userValue(let number): return retrieveSingleNumber(using: realm, byKey: number)
            case .random: return retrieveSingleNumber(using: realm)
            case .range(let range): return retrieveFrom(Set(range), using: realm)
            case .multiple(let multiple): return retrieveFrom(Set(multiple), using: realm)
            }
        }
    }

    private func retrieveSingleNumber(using realm: Realm?, byKey key: Int? = nil) -> AnyPublisher<Numbers, Error> {
        let obj = key != nil
            ? realm?.object(ofType: NumberObject.self, forPrimaryKey: key)
            : realm?.objects(NumberObject.self).randomElement()
        guard let obj else { return Fail(error: DBError.cannotRetrieveNumber).eraseToAnyPublisher() }
        return Just(obj.asDict).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    private func retrieveFrom(_ set: Set<Int>, using realm: Realm?) -> AnyPublisher<Numbers, Error> {
        let results = realm?.objects(NumberObject.self)
            .filter { set.contains($0.number) }
            .reduce(into: [:]) { $0[String($1.number)] = $1.text }
        guard let results, !results.isEmpty else {
            return Fail(error: DBError.cannotRetrieveNumber).eraseToAnyPublisher()
        }
        return Just(results).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func preserve(numbers: [String: String]) {
        queue.sync {
            let realm = try? Realm()
            let objects = numbers.map { key, value in NumberObject(value: ["number": Int(key) ?? 0, "text": value]) }
            try? realm?.write { realm?.add(objects, update: .modified) }
        }
    }

    func clearStorage() {
        queue.sync {
            let realm = try? Realm()
            try? realm?.write { realm?.deleteAll() }
        }
    }
}
