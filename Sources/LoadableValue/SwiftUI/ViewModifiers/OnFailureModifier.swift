//
//  FailureLoadableValueAction.swift
//  LoadableValue
//
//  Created by John Demirci on 6/3/26.
//

import SwiftUI

struct OnFailureModifier<Value, Failure>: ViewModifier
where Value: Equatable & Sendable, Failure: Error {
    @Binding var loadableValue: LoadableValue<Value, Failure>

    let failureAction: (LoadingFailure<Failure>) -> Void

    func body(content: Content) -> some View {
        content
            .task(id: loadableValue) {
                if case .failed(let loadingFailure) = loadableValue {
                    failureAction(loadingFailure)
                }
            }
    }
}

struct OnFailureModifierAsync<Value, Failure>: ViewModifier
where Value: Equatable & Sendable, Failure: Error {
    @Binding var loadableValue: LoadableValue<Value, Failure>

    let failureAction: (LoadingFailure<Failure>) async -> Void

    func body(content: Content) -> some View {
        content
            .task(id: loadableValue) {
                if case .failed(let loadingFailure) = loadableValue {
                    await failureAction(loadingFailure)
                }
            }
    }
}
