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
    public func newData<T: PersistentModel>(dataModel: T) throws -> PersistentIdentifier {
        modelContext.insert(dataModel)
        try modelContext.save()
        return dataModel.persistentModelID
    }
    
    public func update<T: PersistentModel>(dataModel: T) throws {
        modelContext.insert(dataModel)
        try modelContext.save()
        
    }
    
    public func delete<T: PersistentModel>(dataModel: T) throws {
        guard let item = self[dataModel.persistentModelID, as: T.self] else { return }
        modelContext.delete(item)
        try modelContext.save()
    }
    
    public func loadMoreRecords<T: PersistentModel>(shoudLoadMore: Bool, loadOffset: Int, sortBy: [SortDescriptor<T>]) -> [T] {
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
