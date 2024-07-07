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
    init() {
        container = DataProvider.shared.previewContainer
        for amount in 1...10 {
            let exp =  Expense(date: Date(), total: Double(amount), currency: "RON", photoData: nil, type: .receipt)
            container.mainContext.insert(exp)
        }
        expense = Expense(date: Date(), total: 11, currency: "RON", photoData: nil, type: .invoice)
        container.mainContext.insert(expense)
    }
}
