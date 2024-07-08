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
    @Environment(\.createDataHandler) private var createDataHandler
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
   
    var body: some View {
        List {
            ForEach(expenses) { expense in
                NavigationLink(value: expense) {
                    VStack(alignment: .leading) {
                        HStack {
                            ExpenseTypeView(text: expense.type.description.first!.uppercased())
                            Text("amount: \(expense.getTotalInCurrentCurrency())")
                                .font(.headline)
                        }
                        Text("\(expense.date.formatted(date: .numeric, time: .standard))")
                            .font(.caption)
                    }
                }
            }.onDelete(perform: deleteExpense)
        }
    }
    
    private func deleteExpense(offsets: IndexSet) {
        let modelIdentifier = expenses[offsets.first!].persistentModelID
        let createDataHandler = createDataHandler
        Task.detached {
            let dataHandler = await createDataHandler()
            do {
                try await dataHandler.delete(persistentID: modelIdentifier)
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    let previewer = Previewer()
    return ExpensesView()
    .environment(\.createDataHandler, DataProvider.shared.dataHandlerCreator(preview: true))
    .modelContainer(previewer.container)
}


