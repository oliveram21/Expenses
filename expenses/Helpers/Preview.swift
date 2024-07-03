//
//  Preview.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import Foundation
import SwiftData

@MainActor
struct Previewer {
    let container: ModelContainer
    let expense: Expense

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Expense.self, configurations: config)
        expense = Expense(date: Date(), total: 22.2, currency: "RON", photoData: nil, type: .receipt)

        container.mainContext.insert(expense)
    }
}
