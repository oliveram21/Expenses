//
//  ExpensesView.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Binding var expensesStore: ExpensesStore
    var body: some View {
        List {
            ForEach(expensesStore.expenses) { expense in
                NavigationLink(value: expense) {
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
    struct ExpensesPreviewContainer : View {
       @State var expensesStore: ExpensesStore
       @MainActor init() {
            let previewer = Previewer()
           _expensesStore = State(initialValue: previewer.expensesStore)
       }
       var body: some View {
           ExpensesView(expensesStore: $expensesStore)
       }
    }

    return ExpensesPreviewContainer()
}

