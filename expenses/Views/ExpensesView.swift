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
    @Query(sort: \Expense.date, order: .reverse) 
    private var expences: [Expense]
    
    var body: some View {
        List {
            ForEach(expences) { expense in
                NavigationLink(value: expense) {
                    VStack(alignment: .leading) {
                        Text("\(expense.type.description.capitalized) amount: \(getTotalInCurrentCurrency( expense))")
                            .font(.headline)
                        Text("\(expense.date.formatted(date: .numeric, time: .standard))")
                            .font(.caption)
                    }
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
    
    func getTotalInCurrentCurrency(_ expense: Expense) -> String {
        return String(expense.total.formatted(.currency(code: expense.currency)))
    }
}

#Preview {
    ExpensesView()
}

