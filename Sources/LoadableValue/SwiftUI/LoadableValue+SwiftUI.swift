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

    @ViewBuilder
    func onIdle<Value: Equatable, Failure: Error>(
        of loadableValue: LoadableValue<Value, Failure>,
        work: @escaping () -> Void
    ) -> some View {
        if case .idle = loadableValue {
            task(id: loadableValue) {
                work()
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func onIdle<Value: Equatable, Failure: Error>(
        of loadableValue: LoadableValue<Value, Failure>,
        work: @escaping () async -> Void
    ) -> some View {
        if case .idle = loadableValue {
            task(id: loadableValue) {
                await work()
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func onCancellation<Value: Equatable, Failure: Error>(
        of loadableValue: LoadableValue<Value, Failure>,
        work: @escaping (Date) -> Void
    ) -> some View {
        if case let .cancelled(date) = loadableValue {
            task(id: loadableValue) {
                work(date)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func onCancellation<Value: Equatable, Failure: Error>(
        of loadableValue: LoadableValue<Value, Failure>,
        work: @escaping (Date) async -> Void
    ) -> some View {
        if case let .cancelled(date) = loadableValue {
            task(id: loadableValue) {
                await work(date)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func onLoading<Value: Equatable, Failure: Error>(
        of loadableValue: LoadableValue<Value, Failure>,
        work: @escaping () -> Void
    ) -> some View {
        if case .loading = loadableValue {
            task(id: loadableValue) {
                work()
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func onLoading<Value: Equatable, Failure: Error>(
        of loadableValue: LoadableValue<Value, Failure>,
        work: @escaping () async -> Void
    ) -> some View {
        if case .loading = loadableValue {
            task(id: loadableValue) {
                await work()
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func onLoadingComplete<Value: Equatable, Failure: Error>(
        of loadableValue: LoadableValue<Value, Failure>,
        work: @escaping (LoadingSuccess<Value>) -> Void
    ) -> some View {
        if case let .loaded(loadingSuccess) = loadableValue {
            task(id: loadableValue) {
                work(loadingSuccess)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func onLoadingComplete<Value: Equatable, Failure: Error>(
        of loadableValue: LoadableValue<Value, Failure>,
        work: @escaping (LoadingSuccess<Value>) async -> Void
    ) -> some View {
        if case let .loaded(loadingSuccess) = loadableValue {
            task(id: loadableValue) {
                await work(loadingSuccess)
            }
        } else {
            self
        }
    }
}
