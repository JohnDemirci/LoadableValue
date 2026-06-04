//
//  OnCompleteModifier.swift
//  LoadableValue
//
//  Created by John on 6/4/26.
//

import SwiftUI

struct OnLoadingCompleteModifier<Value: Equatable & Sendable, Failure: Error>: ViewModifier {
    @Binding var loadableValue: LoadableValue<Value, Failure>
    let action: (LoadingSuccess<Value>) -> Void
    
    func body(content: Content) -> some View {
        content
            .task(id: loadableValue) {
                if case .loaded(let loadingSuccess) = loadableValue {
                    action(loadingSuccess)
                }
            }
    }
}

struct OnLoadingCompleteModifierAsync<Value: Equatable & Sendable, Failure: Error>: ViewModifier {
    @Binding var loadableValue: LoadableValue<Value, Failure>
    let action: (LoadingSuccess<Value>) async -> Void
    
    func body(content: Content) -> some View {
        content
            .task(id: loadableValue) {
                if case .loaded(let loadingSuccess) = loadableValue {
                    await action(loadingSuccess)
                }
            }
    }
}
