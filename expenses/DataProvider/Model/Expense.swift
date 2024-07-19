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
    /*
    enum CodingKeys: CodingKey {
        case date,total,currency,type,id
    }
    
    required public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            date = try container.decode(Date.self, forKey: .date)
            total = try container.decode(Double.self, forKey: .date)
            currency = try container.decode(String.self, forKey: .date)
            type = try container.decode(ExpenseType.self, forKey: .date)
         id = try container.decode(UUID.self, forKey: .id)
       
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(total, forKey: .total)
        try container.encode(currency, forKey: .currency)
        try container.encode(type, forKey: .type)
        try container.encode(id, forKey: .id)
    }*/
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

//convience struct to send model data between actors
public struct SendableExpenseModel: Sendable {
    let date: Date
    let total: Double
    let currency: String
    let type: String
    let photo: Data?
    let persistentID: PersistentIdentifier?
    let id: UUID?
    
    init(date: Date = Date(), total: Double = 0, currency: String = "RON", photoData: Data? = nil, type: ExpenseType = .invoice, persistentId: PersistentIdentifier? = nil, id: UUID? = nil) {
        self.date = date
        self.total = total
        self.currency = currency
        self.photo = photoData
        self.type = type.rawValue
        self.persistentID = persistentId
        self.id = id
    }
    
    public init(_ persistentModel: Expense) {
        self.init(date: persistentModel.date,
                  total: persistentModel.total,
                  currency: persistentModel.currency,
                  photoData: persistentModel.photo,
                  type: persistentModel.type,
                  persistentId: persistentModel.persistentModelID,
                  id: persistentModel.expenseID)
        
    }
}
