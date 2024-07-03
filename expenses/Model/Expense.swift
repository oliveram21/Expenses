//
//  Item.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.07.2024.
//

import Foundation
import SwiftData

enum ExpenseType: Int, CaseIterable, Codable, CustomStringConvertible {
    case receipt = 1, invoice = 2
    var description: String {
        switch self {
            case .receipt: return "receipt"
            case .invoice: return "invoice"
        }
    }
}

@Model
final class Expense {
    var date: Date
    var total: Double
    var currency: String
    var type: ExpenseType
    @Attribute(.externalStorage) var photo: Data?
    
    init(date: Date, total: Double, currency: String, photoData: Data?, type: ExpenseType) {
        self.date = date
        self.total = total
        self.currency = currency
        self.photo = photoData
        self.type = type
    }
}
