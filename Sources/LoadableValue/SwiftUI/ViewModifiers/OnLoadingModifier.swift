//
//  OnLoadingModifier.swift
//  LoadableValue
//
//  Created by John on 6/4/26.
//

import SwiftUI

struct OnLoadingModifier<Value: Equatable & Sendable, Failure: Error>: ViewModifier {
    @Binding var loadableValue: LoadableValue<Value, Failure>
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .task(id: loadableValue) {
                if case .loading = loadableValue {
                    action()
                }
            }
    }
}

struct OnLoadingModifierAsync<Value: Sendable & Equatable, Failure: Error>: ViewModifier {
    @Binding var loadableValue: LoadableValue<Value, Failure>
    let action: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .task(id: loadableValue) {
                await action()
            }
    }
}
