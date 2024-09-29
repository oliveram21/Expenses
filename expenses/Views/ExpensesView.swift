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
            ForEach(expensesStore.expenses, id: \.id) { expense in
                NavigationLink(value: expense.id) {
                    ExpenseRow(expense: expense)
                }.onAppear(perform: {
                    Task{
                        await expensesStore.loadMoreExpenses(expense: expense)
                    }
                })
            }.onDelete(perform: deleteExpense)
        }//search expense by id because on state restoration the list may not contain it
        //the expense.persistentModelID fails to be initialized from a decoder
        .navigationDestination(for: UUID.self) { ExpenseView(expenseId: $0) }
        .onAppear(perform: {
                Task { await expensesStore.loadMoreExpenses() }
        })
    }
  /*  @MainActor @ViewBuilder
    func navigateToExpenseView(id: UUID) -> some View {
        Task {
            if let expense = await expensesStore.searchExpenseById(id: id) {
               return ExpenseView(expense: expense)
            }
        }
         ExpenseView()
       
    }*/
    @MainActor private func deleteExpense(offsets: IndexSet) {
        for offset in offsets {
            let sendableExpense = expensesStore.expenses[offset]
            expensesStore.deleteExpense(sendableExpense)
        }
    }
}

struct ExpenseRow: View{
    let expense: SendableExpenseModel
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

