//
//  DataHandlerTests.swift
//  expensesTests
//
//  Created by Olivera Miatovici on 08.07.2024.
//

import XCTest
import SwiftData
@testable import expenses
final class DataHandlerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    @MainActor
    func testNewExpense() async throws {
      let container = DataProvider.shared.testContainer()
      let hander = DataHandler(modelContainer: container)

      let amount = 20.2
      let dataModel = SendableExpenseModel(total: amount)
      
      try await hander.newData(dataModel)

      let fetchDescriptor = FetchDescriptor<Expense>()
      let expenses = try container.mainContext.fetch(fetchDescriptor)

      XCTAssertNotNil(expenses.first, "The expense should be created and fetched successfully.")
      XCTAssertEqual(expenses.count, 1, "There should be exactly one expense in the store.")

      if let firstExpense = expenses.first {
          XCTAssertEqual(firstExpense.total, amount, "The expense total should match the initially provided amount.")
      } else {
        XCTFail("Expected to find an expense but none was found.")
      }
    }
    
    @MainActor
    func testDeleteExpense() async throws {
        
        let container = DataProvider.shared.testContainer()
        let hander = DataHandler(modelContainer: container)
        
        let amount = 20.2
        let dataModel = SendableExpenseModel(total: amount)
        try await hander.newData(dataModel)
        
        let fetchDescriptor = FetchDescriptor<Expense>()
        let expenses = try container.mainContext.fetch(fetchDescriptor)
        
        XCTAssertNotNil(expenses.first, "The expense should be created and fetched successfully.")
        XCTAssertEqual(expenses.count, 1, "There should be exactly one expense in the store.")
        
        if let firstExpense = expenses.first {
            XCTAssertEqual(firstExpense.total, amount, "The expense total should match the initially provided amount.")
        } else {
            XCTFail("Expected to find an expense but none was found.")
        }
        do {
            try await hander.delete(SendableExpenseModel())
            XCTFail("model doesn't exist in the store. An exception is expected")
        } catch {
            
        }
        try await hander.delete(SendableExpenseModel(expenses.first!))
        try XCTAssertEqual(container.mainContext.fetchCount(fetchDescriptor),0, "The store should be empty")
    }
    
    @MainActor
    func testUpdateExpense() async throws {
     
      let container = DataProvider.shared.testContainer()
      let hander = DataHandler(modelContainer: container)

      let amount = 20.2
      let dataModel = SendableExpenseModel(total: amount)
      try await hander.newData(dataModel)

      let fetchDescriptor = FetchDescriptor<Expense>()
      let expenses = try container.mainContext.fetch(fetchDescriptor)

      XCTAssertNotNil(expenses.first, "The expense should be created and fetched successfully.")
      XCTAssertEqual(expenses.count, 1, "There should be exactly one expense in the store.")

      if let firstExpense = expenses.first {
          let expenseSend = SendableExpenseModel(date:firstExpense.date,
                                                 total: 0,
                                                 currency: firstExpense.currency,
                                                 photoData: firstExpense.photo,
                                                 type: firstExpense.type,
                                                 persistentId: firstExpense.persistentModelID)
          try await hander.update(expenseSend)
          let updatedExpenses = try container.mainContext.fetch(fetchDescriptor)
          if let firstExpense = updatedExpenses.first {
              XCTAssertEqual(firstExpense.total, 0, "The expense total should match the initially provided amount.")
          }else {
              XCTFail("Expected to find an item but none was found.")
          }
      } else {
        XCTFail("Expected to find an item but none was found.")
      }
        do {
            try await hander.update(SendableExpenseModel())
            XCTFail("Model doesn't exist in store. An exception is expected")
        } catch is DataHandlerError {
            
        }
    }
}
