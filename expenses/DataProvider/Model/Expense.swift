//
//  Item.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import Foundation
import SwiftData

public enum ExpenseType: String, CaseIterable, Codable, CustomStringConvertible, Hashable {
    case receipt = "receipt", invoice = "invoice"
    public var description: String {
        switch self {
            case .receipt: return "Receipt"
            case .invoice: return "Invoice"
        }
    }
}

@Model
public final class Expense {
    var date: Date
    var total: Double
    var currency: String
    var type: ExpenseType
    @Attribute(.externalStorage) var photo: Data?
    
    init(date: Date = Date(), total: Double = 0, currency: String = "RON", photoData: Data? = nil, type: ExpenseType = .invoice) {
        self.date = date
        self.total = total
        self.currency = currency
        self.photo = photoData
        self.type = type
    }
}

extension Expense {
    func getTotalInCurrentCurrency() -> String {
        return String(total.formatted(.currency(code: currency)))
    }
}

extension Expense {
    func updateFrom(sendableModel: SendableExpenseModel) {
        self.date = sendableModel.date
        self.total = sendableModel.total
        self.currency = sendableModel.currency
        self.photo = sendableModel.photo
        self.type = ExpenseType(rawValue: sendableModel.type) ?? .invoice
    }
}

//convience struct to send model data between actors
public struct SendableExpenseModel: Sendable {
    let date: Date
    let total: Double
    let currency: String
    let type: String
    let photo: Data?
    let persistentID: PersistentIdentifier?
    
    init(date: Date = Date(), total: Double = 0, currency: String = "RON", photoData: Data? = nil, type: ExpenseType = .invoice, persistentId: PersistentIdentifier? = nil) {
        self.date = date
        self.total = total
        self.currency = currency
        self.photo = photoData
        self.type = type.rawValue
        persistentID = persistentId
    }
    
    init(expense: Expense) {
        self.init(date: expense.date,
                  total: expense.total,
                  currency: expense.currency,
                  photoData: expense.photo,
                  type: expense.type,
                  persistentId: expense.persistentModelID)
        
    }
}
