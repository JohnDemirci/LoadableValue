//
//  LoadableValue+SwiftUI.swift
//  LoadableValue
//
//  Created by John Demirci on 6/3/26.
//

import SwiftUI

public extension View {
    func onFailure<Value: Equatable, Failure: Error>(
        of loadableValue: Binding<LoadableValue<Value, Failure>>,
        work: @escaping (LoadingFailure<Failure>) -> Void
    ) -> some View {
        modifier(
            OnFailureModifier(
                loadableValue: loadableValue,
                failureAction: work
            )
        )
    }

    func onFailure<Value: Equatable, Failure: Error>(
        of loadableValue: Binding<LoadableValue<Value, Failure>>,
        work: @escaping (LoadingFailure<Failure>) async -> Void
    ) -> some View {
        modifier(
            OnFailureModifierAsync(
                loadableValue: loadableValue,
                failureAction: work
            )
        )
    }

    func onIdle<Value: Equatable & Sendable, Failure: Error>(
        of laodableValue: Binding<LoadableValue<Value, Failure>>,
        work: @escaping () -> Void
    ) -> some View {
        modifier(
            OnIdleModifier(
                loadableValue: laodableValue,
                action: work
            )
        )
    }

    func onIdle<Value: Equatable & Sendable, Failure: Error>(
        of loadableValue: Binding<LoadableValue<Value, Failure>>,
        work: @escaping () async -> Void
    ) -> some View {
        modifier(
            OnIdleModifierAsync(
                loadableValue: loadableValue,
                action: work
            )
        )
    }

    func onCancellation<Value: Equatable & Sendable, Failure: Error>(
        of loadableValue: Binding<LoadableValue<Value, Failure>>,
        work: @escaping (Date) -> Void
    ) -> some View {
        modifier(
            OnCancelModifier(
                loadableValue: loadableValue,
                onCancel: work
            )
        )
    }

    func onCancellation<Value: Equatable & Sendable, Failure: Error>(
        of loadableValue: Binding<LoadableValue<Value, Failure>>,
        work: @escaping (Date) async -> Void
    ) -> some View {
        modifier(
            OnCancelModifierAsync(
                loadableValue: loadableValue,
                onCancel: work
            )
        )
    }

    func onLoading<Value: Equatable, Failure: Error>(
        of loadableValue: Binding<LoadableValue<Value, Failure>>,
        work: @escaping () -> Void
    ) -> some View {
        modifier(
            OnLoadingModifier(
                loadableValue: loadableValue,
                action: work
            )
        )
    }

    func onLoading<Value: Equatable, Failure: Error>(
        of loadableValue: Binding<LoadableValue<Value, Failure>>,
        work: @escaping () async -> Void
    ) -> some View {
        modifier(
            OnLoadingModifierAsync(
                loadableValue: loadableValue,
                action: work
            )
        )
    }

    func onLoadingComplete<Value: Equatable & Sendable, Failure: Error>(
        of loadableValue: Binding<LoadableValue<Value, Failure>>,
        work: @escaping (LoadingSuccess<Value>) -> Void
    ) -> some View {
        modifier(
            OnLoadingCompleteModifier(
                loadableValue: loadableValue,
                action: work
            )
        )
    }

    func onLoadingComplete<Value: Equatable & Sendable, Failure: Error>(
        of loadableValue: Binding<LoadableValue<Value, Failure>>,
        work: @escaping (LoadingSuccess<Value>) async -> Void
    ) -> some View {
        modifier(
            OnLoadingCompleteModifierAsync(
                loadableValue: loadableValue,
                action: work
            )
        )
    }
}
