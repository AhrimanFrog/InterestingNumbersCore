import Foundation
import Testing
import RealmSwift
import Combine
@testable import InterestingNumbersCore

struct DBManagerTests {
    @Test
    func testPreserveAndRetrieveSingle() async throws {
        let dbManager = DBManager()
        let numbers = ["7": "Lucky number"]

        dbManager.preserve(numbers: numbers)

        try await Task.sleep(nanoseconds: 3_000_000)

        for try await value in dbManager.request(query: .userValue(7)).values {
            #expect(value == numbers)
        }

        dbManager.clearStorage()
    }

    @Test
    func testRetrieveRandomFailsOnEmpty() throws {
        let dbManager = DBManager()

        _ = dbManager.request(query: .random)
            .sink { result in
                switch result {
                case .success: #expect(Bool(false))
                case .failure(let error): #expect((error as? DBError) == DBError.cannotRetrieveNumber)
                }
            }
    }

    @Test
    func testRetrieveFromRange() async throws {
        let dbManager = DBManager()

        let numbers = ["1": "One", "2": "Two", "3": "Three"]
        dbManager.preserve(numbers: numbers)

        try await Task.sleep(nanoseconds: 300_000_000)
        
        for try await value in dbManager.request(query: .range(1...3)).values {
            #expect(value == numbers)
        }

        dbManager.clearStorage()
    }
}
