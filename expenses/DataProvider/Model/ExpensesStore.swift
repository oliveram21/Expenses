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
    var expenses: [SendableExpenseModel] = []
    let currencies: [String] = NSLocale.isoCurrencyCodes
    var storeError: ErrorWrapper?
    
    init(createHandler: @escaping DataProvider.DataHandlerCreator) {
        self.createHandler = createHandler
    }
}

extension ExpensesStore {
    func loadMoreExpenses(expense: SendableExpenseModel? = nil) async {
        var isLastExpense = (expense == nil && expenses.isEmpty) ? true : false
        if let lastItem = expenses.last, let expense, lastItem == expense {
            isLastExpense = true
        }
        //load more expenses only if user reached the end of the loaded expenses list
        guard isLastExpense == true else {
            return
        }
        let moreExpenses = await loadMoreRecords(shoudLoadMore: isLastExpense, loadOffset: expenses.count)
        
        //don't trigger ui refresh if there is nothing to load
        guard !moreExpenses.isEmpty else { return }
        
        self.expenses += moreExpenses
    }
    
    //fetch a limited number of expenses from a given offset
    //Using custom descriptor instead of @Query has some disavantages: model changes arent' tracked by default,
    //iCloud sync is not automatically done
    public func loadMoreRecords(shoudLoadMore: Bool, loadOffset: Int, fetchLimit: Int = ExpensesStore.fetchPageSize)  async -> [SendableExpenseModel] {
        let dataHandler = await createHandler()

        let expenses = await dataHandler.loadMore(shoudLoadMore: shoudLoadMore, loadOffset: loadOffset, fetchLimit: fetchLimit)
        return expenses
    }
    
    func reloadExpenses() async {
        let loadedExpensesCount = max(expenses.count,ExpensesStore.fetchPageSize)
        self.expenses.removeAll()
        self.expenses = await loadMoreRecords(shoudLoadMore: true, loadOffset: 0, fetchLimit: loadedExpensesCount)
        print("total reloaded:\(self.expenses.count)")
    }
    
    func searchExpenseById(id: UUID) async -> SendableExpenseModel? {
        let predicate =  #Predicate<SendableExpenseModel>{ expense in
            expense.id == id
        }
        //search in local list
        if let expense = try? expenses.filter(predicate).first {
            return expense
        }
        
        //search in DB
        let dataHandler = await createHandler()
        return await dataHandler.searchById(id: id)
    }
        
}

extension ExpensesStore {
    func saveExpense(_ expense: SendableExpenseModel, isNew: Bool = false) async {
        let createDataHandler = createHandler
       // Task.detached {
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
                 self.setError(error: error)
            }
        catch {
            
        }
        //}
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
