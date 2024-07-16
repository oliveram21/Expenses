//
//  ContentView.swift
//  receipts
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var expensesStore: ExpensesStore
    @State private var showAddExpenceView = false
   
    @MainActor
    init(modelContext: ModelContext, createDataHandler: @escaping DataProvider.DataHandlerCreator) {
        let expenseStore =  ExpensesStore(createHandler: createDataHandler, mainContext: modelContext)
        _expensesStore = State(initialValue: expenseStore)
    }
    
    var body: some View {
        NavigationStack {
               ExpensesView(expensesStore: $expensesStore)
                .navigationTitle("Expenses")
                .navigationDestination(for: Expense.self) { expense in
                    ExpenseView(expense: expense, expensesStore: $expensesStore)
                }
                .toolbar {
                    ToolbarItem {
                        Button("Add", action: {addExpense()})
                            .sheet(isPresented: $showAddExpenceView,
                                   content: {
                                //embbed ExpenseView in navigation stack in order to decorate it with cancel and add button
                                addExpenseSheetView()
                            })
                    }
                }
        }.tint(.expenseTint)
    }
    
    @MainActor @ViewBuilder
    func addExpenseSheetView() -> some View {
        NavigationStack {
            ExpenseView(expense: nil, expensesStore: $expensesStore)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {showAddExpenceView.toggle()}
                    }
                    
                }
        }
    }
    fileprivate func addExpense() {
        showAddExpenceView.toggle()
    }
}

#Preview {
    let previewer = Previewer()
    return ContentView(modelContext: previewer.container.mainContext, createDataHandler: previewer.dataHandlerCreator)
}
