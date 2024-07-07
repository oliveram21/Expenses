//
//  ExpensesView.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.createDataHandler) private var createDataHandler
    @Environment(\.createDataHandlerWithMainContext) private var createDataHandlerWithMainContext
    @State private var expenses: [Expense] = []
    @State private var currentPage: Int = 0
    @Binding var shouldRefreshAfterAdd: Bool
    
    var body: some View {
        List {
            ForEach(expenses) { expense in
                NavigationLink(value: expense) {
                    VStack(alignment: .leading) {
                        HStack {
                            ExpenseTypeView(text: expense.type.description.first!.uppercased())
                            Text("amount: \(getTotalInCurrentCurrency(expense))")
                                .font(.headline)
                        }
                        Text("\(expense.date.formatted(date: .numeric, time: .standard))")
                            .font(.caption)
                    }
                }.onAppear(perform: {
                    loadMoreExpences(expense: expense, loadedExpensesCount: expenses.count)
                })
            }.onDelete(perform: deleteExpense)
        }.onAppear(perform: {
            loadMoreExpences(loadedExpensesCount: expenses.count)
        }).onChange(of: shouldRefreshAfterAdd) {
            //inserting new expence should trigger list refresh. 
            if shouldRefreshAfterAdd == true {
                self.expenses = []
                loadMoreExpences(loadedExpensesCount: expenses.count)
            }
        }
    }
    
    @MainActor
    private func loadMoreExpences(expense: Expense? = nil, loadedExpensesCount: Int) {
        var isLastItem = (expense == nil && loadedExpensesCount == 0) ? true : false
        if let lastItem = expenses.last, let expense = expense, lastItem == expense {
            isLastItem = true
        }
        guard isLastItem == true else {
            return
        }
        Task { @MainActor in
             if let dataHandler = await createDataHandlerWithMainContext() {
                 self.expenses +=  await dataHandler.loadMoreRecords(shoudLoadMore: isLastItem, loadOffset: loadedExpensesCount, sortBy: [.init(\Expense.date, order: .reverse)])
             }
        }
    }
    
    private func deleteExpense(offsets: IndexSet) {
        Task.detached {
            if let dataHandler = await createDataHandler() {
                for index in offsets {
                    do {
                        try await dataHandler.delete(dataModel: expenses[index])
                        expenses.remove(at: index)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func getTotalInCurrentCurrency(_ expense: Expense) -> String {
        return String(expense.total.formatted(.currency(code: expense.currency)))
    }
}

#Preview {
    let previewer = Previewer()
    return ExpensesView(shouldRefreshAfterAdd: .constant(true))
    .environment(\.createDataHandler, DataProvider.shared.dataHandlerCreator(preview: true))
    .environment(\.createDataHandlerWithMainContext, DataProvider.shared.dataHandlerWithMainContextCreator(preview: true))
    .modelContainer(previewer.container)
}


