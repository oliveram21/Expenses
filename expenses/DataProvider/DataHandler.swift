//
//  DataHandler.swift
//  expenses
//
//  Created by Olivera Miatovici on 06.07.2024.
//

import Foundation
import SwiftData

@ModelActor
public actor DataHandler: DataHandlerProtocol {
   @discardableResult
    public func newData(_ dataModel: SendableExpenseModel) throws -> SendableExpenseModel {
        let expense = Expense()
        expense.updateFrom(dataModel)
        modelContext.insert(expense)
        do {
            try modelContext.save()
        } catch {
            throw DataHandlerError.create(dataModel)
        }
        return SendableExpenseModel(expense)
    }
    
     public func update(_ dataModel: SendableExpenseModel) throws  {
        guard  let id = dataModel.persistentID, let expense = self[id, as: Expense.self] else { throw DataHandlerError.missing(dataModel) }
        expense.updateFrom(dataModel)
        modelContext.insert(expense)
         do {
             try modelContext.save()
         } catch {
             throw DataHandlerError.update(dataModel)
         }
    }
    
    public func delete(_ dataModel: SendableExpenseModel) throws {
        guard let id = dataModel.persistentID, let item = self[id, as: Expense.self] else { throw DataHandlerError.missing(dataModel) }
        modelContext.delete(item)
        do {
            try modelContext.save()
        } catch {
            throw DataHandlerError.delete(dataModel)
        }
    }
}


