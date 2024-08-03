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
    var storeError: ErrorWrapper?
    
    init(createHandler: @escaping DataProvider.DataHandlerCreator, mainContext: ModelContext) {
        self.createHandler = createHandler
        self.modelContext = mainContext
    }
}

extension ExpensesStore {
    func loadMoreExpenses(expense: Expense? = nil) {
        var isLastExpense = (expense == nil && expenses.isEmpty) ? true : false
        if let lastItem = expenses.last, let expense, lastItem == expense {
            isLastExpense = true
        }
        //load more expenses only if user reached the end of the loaded expenses list
        guard isLastExpense == true else {
            return
        }
        let moreExpenses = loadMoreRecords(shoudLoadMore: isLastExpense, loadOffset: expenses.count)
        
        //don't trigger ui refresh if there is nothing to load
        guard !moreExpenses.isEmpty else { return }
        
        self.expenses += moreExpenses
    }
    
    //fetch a limited number of expenses from a given offset
    //Using custom descriptor instead of @Query has some disavantages: model changes arent' tracked by default,
    //iCloud sync is not automatically done
    public func loadMoreRecords(shoudLoadMore: Bool, loadOffset: Int, fetchLimit: Int = ExpensesStore.fetchPageSize)  -> [Expense] {
       
        if shoudLoadMore {
            var fetchDescriptor = FetchDescriptor<Expense>()
            guard let totalRecords = try? modelContext.fetchCount(fetchDescriptor) else { return [] }
            guard totalRecords > loadOffset else { return [] }
            
            fetchDescriptor.fetchLimit = fetchLimit
            fetchDescriptor.fetchOffset = loadOffset
            fetchDescriptor.sortBy = [.init(\Expense.date, order: .reverse)]
            print("fetch offset:\(loadOffset) currentIndex:\(shoudLoadMore) total:\(totalRecords) limit:\(fetchLimit)")
            let expenses = try? modelContext.fetch(fetchDescriptor)
            return expenses == nil ? [] : expenses!
        }
        return []
    }
    
    func reloadExpenses() {
        let loadedExpensesCount = max(expenses.count,ExpensesStore.fetchPageSize)
        self.expenses.removeAll()
        self.expenses = loadMoreRecords(shoudLoadMore: true, loadOffset: 0, fetchLimit: loadedExpensesCount)
        print("total reloaded:\(self.expenses.count)")
    }
    
    func searchExpenseById(id: UUID) -> Expense? {
       
        let predicate =  #Predicate<Expense>{ expense in
            expense.expenseID == id
        }
        //search in local list
        if let expense = try? expenses.filter(predicate).first {
            return expense
        }
        
        var fetcDescriptor = FetchDescriptor<Expense>()
        fetcDescriptor.predicate = predicate
        //search in DB
        return try? modelContext.fetch(fetcDescriptor).first
    }
}

extension ExpensesStore {
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
            } catch let error as DataHandlerError {
                await self.setError(error: error)
            }
        }
    }
    
   func deleteExpense(_ expense: SendableExpenseModel) {
        Task.detached {
            let dataHandler = await self.createHandler()
            do {
                try await dataHandler.delete(expense)
                await self.reloadExpenses()
            } catch let error as DataHandlerError {
                await self.setError(error: error)
            }
        }
    }
    
    func setError(message: String = "", error: DataHandlerError) {
        storeError = ErrorWrapper(message: error.localizedDescription, error: error)
    }
}
