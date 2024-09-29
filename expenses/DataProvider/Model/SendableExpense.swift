//
//  SendableExpense.swift
//  expenses
//
//  Created by Olivera Miatovici on 21.08.2024.
//

import Foundation
//convience struct to send model data between actors
public struct SendableExpenseModel: Sendable, Equatable {
    let date: Date
    let total: Double
    let currency: String
    let type: String
    let photo: Data?
    let id: UUID?
    
    init(date: Date = Date(), total: Double = 0, currency: String = "RON", photoData: Data? = nil, type: ExpenseType = .invoice, id: UUID? = nil) {
        self.date = date
        self.total = total
        self.currency = currency
        self.photo = photoData
        self.type = type.rawValue
        self.id = id
    }
    
    public init(_ persistentModel: Expense) {
        self.init(date: persistentModel.date,
                  total: persistentModel.total,
                  currency: persistentModel.currency,
                  photoData: persistentModel.photo,
                  type: persistentModel.type,
                  id: persistentModel.expenseID)
        
    }
    func getTotalInCurrentCurrency() -> String {
        return String(total.formatted(.currency(code: currency)))
    }
}
