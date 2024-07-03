//
//  EditExpenseView.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import SwiftUI

struct ExpenseView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var expense: Expense
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    do {
        let previewer = try Previewer()

        return ExpenseView(expense: previewer.expense, navigationPath: .constant(NavigationPath()))
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
