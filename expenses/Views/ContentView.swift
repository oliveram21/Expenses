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
    @State var showAddExpenceView = false
    
    var body: some View {
        NavigationStack {
            ExpensesView()
                .navigationTitle("Expenses")
                .navigationDestination(for: Expense.self) { expense in
                    ExpenseView(expense: expense)
                }
                .toolbar {
                    ToolbarItem {
                        Button("Add", action: { showAddExpenceView.toggle()})
                            .sheet(isPresented: $showAddExpenceView,
                                   content: {
                                AddExpenseWrapperView(showAddExpenceView: $showAddExpenceView)
                            })
                        
                    }
            }
        }
    }
    
}

struct AddExpenseWrapperView: View {
    @Environment(\.modelContext) var modelContext
    @Binding var showAddExpenceView: Bool
    
    var body: some View {
        NavigationStack {
            let newExpense = Expense(date: Date(), total: 0, currency: "RON", photoData: nil, type: .invoice)
            ExpenseView(expense: newExpense)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {showAddExpenceView.toggle()}
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            addExpense(expense: newExpense)
                            showAddExpenceView.toggle()
                        }
                    }
                }
        }
    }
    private func addExpense(expense: Expense) {
        modelContext.insert(expense)
    }
}
#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}
