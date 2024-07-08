//
//  DataProvider.swift
//  expenses
//
//  Created by Olivera Miatovici on 06.07.2024.
//

import Foundation
import SwiftData
import SwiftUI

public final class DataProvider: Sendable {
    public typealias DataHandlerCreator =  @Sendable () async -> DataHandler
    public typealias DataHandlerCreatorWithMainContext =  @Sendable @MainActor () async -> DataHandler
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
    
    public func dataHandlerCreator(preview: Bool = false) -> DataHandlerCreator  {
        let container = preview ? previewContainer : sharedModelContainer
        return { DataHandler(modelContainer: container) }
    }
    
    public func dataHandlerWithMainContextCreator(preview: Bool = false) -> DataHandlerCreatorWithMainContext {
        let container = preview ? previewContainer : sharedModelContainer
        return { DataHandler(modelContainer: container, mainActor: true) }
    }
}

public struct DataHandlerKey: EnvironmentKey {
    public static let defaultValue: DataProvider.DataHandlerCreator = DataProvider.shared.dataHandlerCreator()
}

extension EnvironmentValues {
    public var createDataHandler: DataProvider.DataHandlerCreator {
        get { self[DataHandlerKey.self] }
        set { self[DataHandlerKey.self] = newValue }
    }
}

public struct MainActorDataHandlerKey: EnvironmentKey {
    public static let defaultValue: DataProvider.DataHandlerCreatorWithMainContext = DataProvider.shared.dataHandlerWithMainContextCreator()
}

extension EnvironmentValues {
    public var createDataHandlerWithMainContext: DataProvider.DataHandlerCreatorWithMainContext {
        get { self[MainActorDataHandlerKey.self] }
        set { self[MainActorDataHandlerKey.self] = newValue }
    }
}

