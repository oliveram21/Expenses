//
//  DataProvider.swift
//  expenses
//
//  Created by Olivera Miatovici on 06.07.2024.
//

import Foundation
import SwiftData
import SwiftUI

enum DataHandlerError: Error {
    case create(_ data: SendableExpenseModel)
    case update(_ data: SendableExpenseModel)
    case delete(_ data: SendableExpenseModel)
    case missing(_ data: SendableExpenseModel)
}

public protocol DataHandlerProtocol: Actor {
    @discardableResult
    func newData(_ dataModel: SendableExpenseModel) throws -> SendableExpenseModel
    func update(_ dataModel: SendableExpenseModel) throws
    func delete(_ dataModel: SendableExpenseModel) throws
}

//Helper class for creating model container for different enviroments and support for DataHandler
//creation injection
public final class DataProvider: Sendable {
    public typealias DataHandlerCreator =  @Sendable () async -> any DataHandlerProtocol
    public static let shared = DataProvider()
    
    public let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    public let previewContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
        ])
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
        let schema = Schema([
            Expense.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
}

public struct DataHandlerKey: EnvironmentKey {
    public static let defaultValue: DataProvider.DataHandlerCreator = DataProvider.shared.dataHandlerCreator()
}

//used to inject datahandler creation in view's enviroment
extension EnvironmentValues {
    public var createDataHandler: DataProvider.DataHandlerCreator {
        get { self[DataHandlerKey.self] }
        set { self[DataHandlerKey.self] = newValue }
    }
}

