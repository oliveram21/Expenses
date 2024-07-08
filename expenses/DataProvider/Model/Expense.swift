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
    
    func updateFrom(sendableModel: SendableExpenseModel) {
        self.date = sendableModel.date
        self.total = sendableModel.total
        self.currency = sendableModel.currency
        self.photo = sendableModel.photo
        self.type = ExpenseType(rawValue: sendableModel.type) ?? .invoice
    }
}

public struct SendableExpenseModel: Sendable {
    let date: Date
    let total: Double
    let currency: String
    let type: String
    let photo: Data?
    let persistentID: PersistentIdentifier?
    
    init(expense: Expense) {
        self.date = expense.date
        self.total = expense.total
        self.currency = expense.currency
        self.photo = expense.photo
        self.type = expense.type.rawValue
        persistentID = expense.persistentModelID
    }
}
