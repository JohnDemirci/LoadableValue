//
//  OnIdleModifier.swift
//  LoadableValue
//
//  Created by John Demirci on 6/3/26.
//

import SwiftUI

struct OnIdleModifier<Value, Failure>: ViewModifier
where Value: Equatable & Sendable, Failure: Error {
    @Binding var loadableValue: LoadableValue<Value, Failure>

    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .task(id: loadableValue) {
                action()
            }
    }
}

struct OnIdleModifierAsync<Value, Failure>: ViewModifier
where Value: Equatable & Sendable, Failure: Error {
    @Binding var loadableValue: LoadableValue<Value, Failure>

    let action: () async -> Void

    func body(content: Content) -> some View {
        content
            .task(id: loadableValue) {
                if case .idle = loadableValue {
                    await action()
                }
            }
    }
}
