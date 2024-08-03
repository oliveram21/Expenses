//
//  ErrorWrapper.swift
//  expenses
//
//  Created by Olivera Miatovici on 22.07.2024.
//

import Foundation

struct ErrorWrapper: Identifiable {
    
    var id: UUID
    var message: String
    var error: LocalizedError
    
    init(id: UUID = UUID(), message: String = "", error: LocalizedError) {
        self.id = id
        self.message = message
        self.error = error
    }
}

