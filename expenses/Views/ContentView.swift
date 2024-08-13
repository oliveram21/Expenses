//
//  ContentView.swift
//  receipts
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(ExpensesStore.self) var expensesStore
    @SceneStorage("ContentView.showAddExpenceView") var showAddExpenceView =  false
    //use AppStorage instead of scenestorage because it triggers multiple refreshes
    @AppStorage("ContentView.path") var path: [UUID] = []
    
    var body: some View {
        NavigationStack(path: $path) {
               ExpensesView()
                .navigationTitle("Expenses")
            //search expense by id because on state restoration the list may not contain it
            //the expense.persistentModelID fails to be initialized from a decoder
                .navigationDestination(for: UUID.self) { id in
                    if let expense = expensesStore.searchExpenseById(id: id) {
                        ExpenseView(expense: expense)
                    }
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
        }
        .tint(.expenseTint)
        .onError(Bindable(expensesStore).storeError)
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
    
    private func addExpense() {
        showAddExpenceView.toggle()
    }
}
    
#Preview {
    let previewer = Previewer()
    return ContentView()
        .environment(previewer.expensesStore)
}
