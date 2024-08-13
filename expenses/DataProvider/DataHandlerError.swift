//
//  DataHandlerError.swift
//  expenses
//
//  Created by Olivera Miatovici on 03.08.2024.
//

import Foundation

enum DataHandlerError: Error {
    case create(_ data: SendableExpenseModel)
    case update(_ data: SendableExpenseModel)
    case delete(_ data: SendableExpenseModel)
    case missing(_ data: SendableExpenseModel)
}

extension DataHandlerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .create(_): return "Faild to create"
        case .update(_): return "Faild to update"
        case .delete(_): return "Faild to delete"
        case .missing(_): return "Faild to find the record"
        }
    }
}
