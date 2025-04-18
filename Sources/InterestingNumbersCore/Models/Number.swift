import RealmSwift

struct Number: Decodable {
    let number: Int
    let text: String
}

public typealias Numbers = [String: String]

final class NumberObject: Object {
    @Persisted(primaryKey: true)
    var number: Int

    @Persisted var text: String

    var asDict: [String: String] { [String(number): text] }
}
