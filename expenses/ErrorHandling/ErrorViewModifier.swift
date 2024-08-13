//
//  ErrorViewModifier.swift
//  expenses
//
//  Created by Olivera Miatovici on 02.08.2024.
//

import SwiftUI

struct ErrorViewModifier: ViewModifier {
    @Binding var error: ErrorWrapper?
    var isShowingError: Binding<Bool> {
        Binding { error != nil }
        set: { _ in
            error = nil
        }
    }
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: isShowingError) {
                Button("Ok"){}
            } message: {
                Text(error?.message ?? "")
            }
    }
}

extension View {
    func onError(_ error: Binding<ErrorWrapper?>) -> some View {
        modifier(ErrorViewModifier(error: error))
    }
}

