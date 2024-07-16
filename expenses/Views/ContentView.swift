//
//  ContentView.swift
//  receipts
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showAddExpenceView = false
    @Environment(ExpensesStore.self) var expensesStore
   
    var body: some View {
        NavigationStack {
                ExpensesView()
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
                                addExpenseSheetView()
                            })
                    }
                }
        }.tint(.expenseTint)
            
    }
    
    @MainActor @ViewBuilder
    func addExpenseSheetView() -> some View {
        NavigationStack {
            ExpenseView(expense: nil)
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
    return ContentView()
        .environment(previewer.expensesStore)
}
