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
    @State private var path = NavigationPath()
    @State var showAddExpenceView = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ExpensesView()
                .navigationTitle("Expenses")
                .navigationDestination(for: Expense.self) { expense in
                    ExpenseView(expense: expense, navigationPath: $path)
                }
                .toolbar {
                    ToolbarItem {
                        Button("Add", action: { showAddExpenceView.toggle()})
                        .fullScreenCover(isPresented: $showAddExpenceView,
                                     content: { AddExpenseView(isPresented: $showAddExpenceView)})
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}
