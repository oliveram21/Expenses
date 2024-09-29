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
    public var expenseID: UUID
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
        self.expenseID = UUID()
    }
}

extension Expense {
    func getTotalInCurrentCurrency() -> String {
        return String(total.formatted(.currency(code: currency)))
    }
}

extension Expense {
    func updateFrom(_ sendableModel: SendableExpenseModel) {
        self.date = sendableModel.date
        self.total = sendableModel.total
        self.currency = sendableModel.currency
        self.photo = sendableModel.photo
        self.type = ExpenseType(rawValue: sendableModel.type) ?? .invoice
    }
}

