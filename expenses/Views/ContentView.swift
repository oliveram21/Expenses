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
    @State var didAdd = false
    
    var body: some View {
        NavigationStack {
            ExpensesView(shouldRefreshAfterAdd: $didAdd)
                .navigationTitle("Expenses:\(didAdd)")
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
    
    fileprivate func doneAddExpense(expense: Expense) {
        modelContext.insert(expense)
        //this will trigger view refresh. It
        didAdd = true
        showAddExpenceView.toggle()
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        return ContentView()
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
