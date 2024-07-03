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
    @Query(sort: \Expense.date, order: .reverse) private var expences: [Expense]
    
    var body: some View {
        List {
            ForEach(expences) { expense in
                NavigationLink(value: expense) {
                    Text("Expense at \(expense.date, format: Date.FormatStyle(date: .numeric, time: .standard))")
                } 
            }.onDelete(perform: deleteExpense)
        }
    }
    
    private func deleteExpense(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(expences[index])
            }
        }
    }
}

#Preview {
    ExpensesView()
}

