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
   public static let fetchPageSize = 20
   @discardableResult
    public func newData(_ dataModel: SendableExpenseModel) throws -> SendableExpenseModel {
        let expense = Expense()
        expense.updateFrom(dataModel)
        modelContext.insert(expense)
        do {
            //call save to synchronize with maincontext
            try modelContext.save()
        } catch {
            throw DataHandlerError.create(dataModel)
        }
        return SendableExpenseModel(expense)
    }
    
     public func update(_ dataModel: SendableExpenseModel) throws  {
         guard  let id = dataModel.id, let expense = searchExpenseById(id: id) else {
             throw DataHandlerError.missing(dataModel)
         }
        expense.updateFrom(dataModel)
        modelContext.insert(expense)
         do {
             try modelContext.save()
         } catch {
             throw DataHandlerError.update(dataModel)
         }
    }
    
    public func delete(_ dataModel: SendableExpenseModel) throws {
        guard let id = dataModel.id, let expense = searchExpenseById(id: id) else {
            throw DataHandlerError.missing(dataModel)
        }
        modelContext.delete(expense)
        do {
            try modelContext.save()
        } catch {
            throw DataHandlerError.delete(dataModel)
        }
    }
    func searchExpenseById(id: UUID) -> Expense? {
       
        let predicate =  #Predicate<Expense>{ expense in
            expense.expenseID == id
        }
      
        var fetcDescriptor = FetchDescriptor<Expense>()
        fetcDescriptor.predicate = predicate
      
        return try? modelContext.fetch(fetcDescriptor).first
     
    }
    public func searchById(id: UUID) -> SendableExpenseModel? {
        guard let expense = searchExpenseById(id: id) else {
            return nil
        }
       return SendableExpenseModel(date: expense.date,
                                                    total: expense.total,
                                                    currency: expense.currency,
                                                    photoData: expense.photo,
                                                    type: expense.type,
                                                    id: expense.expenseID
        )
    }
    public func loadMore(shoudLoadMore: Bool, loadOffset: Int, fetchLimit: Int = DataHandler.fetchPageSize)  -> [SendableExpenseModel] {
       
        if shoudLoadMore {
            var fetchDescriptor = FetchDescriptor<Expense>()
            guard let totalRecords = try? modelContext.fetchCount(fetchDescriptor) else { return [] }
            guard totalRecords > loadOffset else { return [] }
            
            fetchDescriptor.fetchLimit = fetchLimit
            fetchDescriptor.fetchOffset = loadOffset
            fetchDescriptor.sortBy = [.init(\Expense.date, order: .reverse)]
            print("fetch offset:\(loadOffset) currentIndex:\(shoudLoadMore) total:\(totalRecords) limit:\(fetchLimit)")
            let expenses = try? modelContext.fetch(fetchDescriptor)
          
            return expenses == nil ? [] : expenses!.map({ expense in
                return SendableExpenseModel(date: expense.date,
                                                            total: expense.total,
                                                            currency: expense.currency,
                                                            photoData: expense.photo,
                                                            type: expense.type,
                                                            id: expense.expenseID
                )
            })
        }
        return []
    }
}


