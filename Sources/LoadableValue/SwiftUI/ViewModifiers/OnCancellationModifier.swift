//
//  OnCancellationModifier.swift
//  LoadableValue
//
//  Created by John Demirci on 6/3/26.
//

import SwiftUI

struct OnCancelModifier<Value, Faulure>: ViewModifier
where Value: Sendable & Equatable, Faulure: Error {
    @Binding var loadableValue: LoadableValue<Value, Faulure>
    
    var onCancel: (Date) -> Void
    
    func body(content: Content) -> some View {
        content
            .task(id: loadableValue) {
                if case .cancelled(let date) = loadableValue {
                    onCancel(date)
                }
            }
    }
}

struct OnCancelModifierAsync<Value, Faulure>: ViewModifier
where Value: Sendable & Equatable, Faulure: Error {
    @Binding var loadableValue: LoadableValue<Value, Faulure>
    
    var onCancel: (Date) async -> Void
    
    func body(content: Content) -> some View {
        content
            .task(id: loadableValue) {
                if case .cancelled(let date) = loadableValue {
                    await onCancel(date)
                }
            }
    }
}
