//
//  ExpensesStore.swift
//  expenses
//
//  Created by Olivera Miatovici on 09.07.2024.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable class ExpensesStore {
    static let fetchPageSize = 20
    private var createHandler: DataProvider.DataHandlerCreator
    private var modelContext: ModelContext
    var expenses: [Expense] = []
    let currencies: [String] = NSLocale.isoCurrencyCodes
    
    init(createHandler: @escaping DataProvider.DataHandlerCreator, mainContext: ModelContext) {
        self.createHandler = createHandler
        self.modelContext = mainContext
    }
    
    func loadMoreExpenses(expense: Expense? = nil) {
        var isLastItem = (expense == nil && expenses.count == 0) ? true : false
        if let lastItem = expenses.last, let expense = expense, lastItem == expense {
            isLastItem = true
        }
        guard isLastItem == true else {
            return
        }
        self.expenses += loadMoreRecords(shoudLoadMore: isLastItem, loadOffset: expenses.count)
    }
    //fetch a limited number of expenses from a given offset
    //Using custom descriptor instead of @Query has some disavantages: model changes arent' tracked by default,
    //iCloud sync is not automatically done
    public func loadMoreRecords(shoudLoadMore: Bool, loadOffset: Int, fetchLimit: Int = ExpensesStore.fetchPageSize)  -> [Expense] {
       var fetchDescriptor = FetchDescriptor<Expense>()
        if shoudLoadMore {
            guard let totalRecords = try? modelContext.fetchCount(fetchDescriptor) else { return [] }
            guard totalRecords > loadOffset else {return []}
            
            fetchDescriptor.fetchLimit = fetchLimit
            fetchDescriptor.fetchOffset = loadOffset
            fetchDescriptor.sortBy = [.init(\Expense.date, order: .reverse)]
            print("fetch offset:\(loadOffset) currentIndex:\(shoudLoadMore) total:\(totalRecords) limit:\(fetchLimit)")
            do {
                return try modelContext.fetch(fetchDescriptor)
            } catch {
                print(error)
            }
        }
        return []
    }
    
    func reloadExpenses() {
        let loadedExpensesCount = max(expenses.count,ExpensesStore.fetchPageSize)
        self.expenses.removeAll()
        self.expenses = loadMoreRecords(shoudLoadMore: true, loadOffset: 0, fetchLimit: loadedExpensesCount)
        print("total reloaded:\(self.expenses.count)")
    }
    
    func saveExpense(_ expense: SendableExpenseModel, isNew: Bool = false) {
        let createDataHandler = createHandler
        Task.detached {
            let dataHandler = await createDataHandler()
            do {
                if isNew {
                    try await dataHandler.newData(expense)
                } else {
                    try await dataHandler.update(expense)
                }
                //fetch again the same number of expenses in order to preserv scroll position
                await self.reloadExpenses()
            } catch {
                print("save exception")
            }
        }
    }
    
   func deleteExpense(_ expense: SendableExpenseModel) {
        let createDataHandler = createHandler
        Task.detached {
            let dataHandler = await createDataHandler()
            do {
                try await dataHandler.delete(expense)
                //fetch again the same number of expenses in order to preserv scroll position.
                await self.reloadExpenses()
            } catch {
                print("delete exception")
            }
        }
    }
}
