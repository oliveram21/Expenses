//
//  ContentView.swift
//  receipts
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.createDataHandler) private var createDataHandler
    @State var showAddExpenceView = false
    @State var didAdd = false
    
    var body: some View {
        NavigationStack {
            ExpensesView(shouldRefreshAfterAdd: $didAdd)
                .navigationTitle("Expenses")
                .navigationDestination(for: Expense.self) { expense in
                    ExpenseView(expense: expense)
                }
                .toolbar {
                    ToolbarItem {
                        Button("Add", action: {addExpense()})
                            .sheet(isPresented: $showAddExpenceView,
                                   content: {
                                //embbed ExpenseView in navigation stack in order to decorate it with cancel and add button
                                NavigationStack {
                                    let newExpense = Expense(date: Date(), total: 0, currency: "RON", photoData: nil, type: .invoice)
                                    ExpenseView(expense: newExpense)
                                        .toolbar {
                                            ToolbarItem(placement: .topBarLeading) {
                                                Button("Cancel") {showAddExpenceView.toggle()}
                                            }
                                            
                                            ToolbarItem(placement: .topBarTrailing) {
                                                Button("Done") {doneAddExpense(expense: newExpense)}
                                            }
                                        }
                                }
                            })
                    }
                }
        }
    }
    
    fileprivate func addExpense() {
        didAdd = false
        showAddExpenceView.toggle()
    }
    
    @MainActor
    fileprivate func doneAddExpense(expense: Expense) {
        Task.detached {
            if let dataHandler = await createDataHandler() {
                do {
                    try await dataHandler.newData(dataModel: expense)
                } catch {
                    print(error)
                }
            }
        }
        didAdd = true
        showAddExpenceView.toggle()
    }
}

#Preview {
    let previewer = Previewer()
    return ContentView()
        .environment(\.createDataHandlerWithMainContext, DataProvider.shared.dataHandlerWithMainContextCreator(preview: true))
        .modelContainer(previewer.container)
        .environment(\.createDataHandler, DataProvider.shared.dataHandlerCreator(preview: true))
}
