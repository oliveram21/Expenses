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
    @State private var expences: [Expense] = []
    @State private var currentPage: Int = 0
    @Binding var shouldRefreshAfterAdd: Bool
    
    var body: some View {
        List {
            ForEach(expences) { expense in
                NavigationLink(value: expense) {
                    VStack(alignment: .leading) {
                        Text("\(expense.type.description) amount: \(getTotalInCurrentCurrency(expense))")
                            .font(.headline)
                        Text("\(expense.date.formatted(date: .numeric, time: .standard))")
                            .font(.caption)
                    }
                }.onAppear(perform: {
                    loadExpencesIfNeeded(expense)
                })
            }.onDelete(perform: deleteExpense)
        }.onAppear(perform: {
            if expences.count == 0 {
                expences = []
                loadMoreExpences()
            }
        }).onChange(of: shouldRefreshAfterAdd) {
            //inserting new expence should trigger list refresh. 
            if shouldRefreshAfterAdd == true {
                self.expences = []
                currentPage = 0
                loadMoreExpences(currentPage: currentPage)
            }
        }
    }
    
    private func loadExpencesIfNeeded(_ expense: Expense) {
        if let lastItem = expences.last, lastItem == expense {
            let totalExpenses = totalExpences()
            guard totalExpenses > expences.count else {return}
            currentPage += 1
            loadMoreExpences(currentPage: currentPage)
        }
    }
    
    private func totalExpences() -> Int {
        let fetchDescriptor = FetchDescriptor<Expense>()
        var count = 0
        do {
            count = try modelContext.fetchCount(fetchDescriptor)
        } catch {
            
        }
        return count
    }
    
    private func loadMoreExpences(currentPage: Int = 0) {
        var fetchDescriptor = FetchDescriptor<Expense>()
        fetchDescriptor.fetchLimit = 10
        fetchDescriptor.fetchOffset = currentPage * 10
        fetchDescriptor.sortBy = [.init(\.date, order: .reverse)]
        
        do {
            self.expences += try modelContext.fetch(fetchDescriptor)
        } catch {
            print(error)
        }
    }
    
    private func deleteExpense(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(expences[index])
                self.expences.remove(at: index)
            }
        }
    }
    
    func getTotalInCurrentCurrency(_ expense: Expense) -> String {
        return String(expense.total.formatted(.currency(code: expense.currency)))
    }
}

/*
#Preview {
    do {
        let previewer = try Previewer()
        return ExpensesView(shouldRefreshAfterAdd: $previewer.isPresented)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
*/

