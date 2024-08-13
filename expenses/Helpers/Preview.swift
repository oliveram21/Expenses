//
//  Preview.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import Foundation
import SwiftData

enum PreviewError: LocalizedError {
    case missing
}
@MainActor
struct Previewer {
    let container: ModelContainer = DataProvider.shared.previewContainer
    let dataHandlerCreator = DataProvider.shared.dataHandlerCreator(preview: true)
    let expensesStore: ExpensesStore

    init() {
        for amount in 1...10 {
            let exp =  Expense(date: Date(), total: Double(amount), currency: "RON", photoData: nil, type: .receipt)
            container.mainContext.insert(exp)
        }
        expensesStore = ExpensesStore(createHandler: dataHandlerCreator, mainContext: container.mainContext)
    }
}
