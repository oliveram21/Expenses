//
//  DataHandler.swift
//  expenses
//
//  Created by Olivera Miatovici on 06.07.2024.
//

import Foundation
import SwiftData

@ModelActor
public actor DataHandler {
    @MainActor
    public init(modelContainer: ModelContainer, mainActor: Bool) {
        let modelContext = modelContainer.mainContext
        modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.modelContainer = modelContainer
    }
    
    public init(modelContainer: ModelContainer, customModelContext _:Bool) {
        let modelContext = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.modelContainer = modelContainer
    }
}

extension DataHandler {
    
    @discardableResult
    public func newData(dataModel: SendableExpenseModel) throws -> PersistentIdentifier {
        let expense = Expense()
        expense.updateFrom(sendableModel: dataModel)
        modelContext.insert(expense)
        try modelContext.save()
        return expense.persistentModelID
    }
   
    public func update(dataModel: SendableExpenseModel) throws {
        guard let id = dataModel.persistentID, let expense = self[id, as: Expense.self] else { return }
        expense.updateFrom(sendableModel: dataModel)
        modelContext.insert(expense)
        try modelContext.save()
        
    }
    
    public func delete(persistentID: PersistentIdentifier) throws {
        guard let item = self[persistentID, as: Expense.self] else { return }
        modelContext.delete(item)
        try modelContext.save()
    }
}

extension DataHandler {
    //TODO: should be isoleted only with MainActor
    public func loadMoreRecords<T: PersistentModel>(shoudLoadMore: Bool, loadOffset: Int, sortBy: [SortDescriptor<T>]) throws -> [T] {
       
        var fetchDescriptor = FetchDescriptor<T>()
        if shoudLoadMore {
            guard let totalRecords = try? modelContext.fetchCount(fetchDescriptor) else { return [] }
            guard totalRecords > loadOffset else {return []}
            
            fetchDescriptor.fetchLimit = 20
            fetchDescriptor.fetchOffset = loadOffset
            fetchDescriptor.sortBy = sortBy
            print("fetch offset:\(loadOffset) currentIndex:\(shoudLoadMore) total:\(totalRecords)")
            do {
                return try modelContext.fetch(fetchDescriptor)
            } catch {
                print(error)
            }}
        return []
    }
}

