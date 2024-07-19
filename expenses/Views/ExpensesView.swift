//
//  ExpensesView.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Environment(ExpensesStore.self) var expensesStore
    var body: some View {
        List {
            ForEach(expensesStore.expenses, id: \.persistentModelID) { expense in
                NavigationLink(value: expense.expenseID) {
                    ExpenseRow(expense: expense)
                }.onAppear(perform: {
                    expensesStore.loadMoreExpenses(expense: expense)
                })
            }.onDelete(perform: deleteExpense)
        }.onAppear(perform: {
            expensesStore.loadMoreExpenses()
        })
    }
    
    @MainActor private func deleteExpense(offsets: IndexSet) {
        for offset in offsets {
            let sendableExpense = SendableExpenseModel(expensesStore.expenses[offset])
            expensesStore.deleteExpense(sendableExpense)
        }
    }
}

struct ExpenseRow: View{
    let expense: Expense
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ExpenseTypeView(text: expense.type.description.first!.uppercased())
                Text("\(expense.getTotalInCurrentCurrency())")
                    .font(.headline)
                    .foregroundStyle(.expenseLabel)
            }
            Text("\(expense.date.formatted(date: .abbreviated , time: .standard))")
                .font(.caption)
        }
    }
}

#Preview {
    let previewer = Previewer()
    return ExpensesView()
        .environment(previewer.expensesStore)
}

