//
//  DataProvider.swift
//  expenses
//
//  Created by Olivera Miatovici on 06.07.2024.
//

import Foundation
import SwiftData

public protocol DataHandlerProtocol: Actor {
    @discardableResult
    func newData(_ dataModel: SendableExpenseModel) throws -> SendableExpenseModel
    func update(_ dataModel: SendableExpenseModel) throws
    func delete(_ dataModel: SendableExpenseModel) throws
    func loadMore(shoudLoadMore: Bool, loadOffset: Int, fetchLimit: Int)  -> [SendableExpenseModel]
    func searchById(id: UUID) -> SendableExpenseModel? 
}

//Helper class for creating model container for different enviroments and support for DataHandler
//creation injection
public final class DataProvider: Sendable {
    public typealias DataHandlerCreator =  @Sendable () async -> any DataHandlerProtocol
    public static let shared = DataProvider()
    
    public let sharedModelContainer: ModelContainer = {
        let schema = Schema([Expense.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    public let previewContainer: ModelContainer = {
        let schema = Schema([Expense.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private init() {}
    
    //use different instance for each data operation logic instead of one instance
    //is prefarable for a cleaner and simpler code: errors of one operation doesn't interfere
    //with other operations
    public func dataHandlerCreator(preview: Bool = false) -> DataHandlerCreator {
        let container = preview ? previewContainer : sharedModelContainer
        return { DataHandler(modelContainer: container) }
    }
    
    public func testContainer() -> ModelContainer {
        let schema = Schema([Expense.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

