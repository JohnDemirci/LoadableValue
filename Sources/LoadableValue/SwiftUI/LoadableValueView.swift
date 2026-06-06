//
//  LoadableValueView.swift
//  LoadableValue
//
//  Created by John Demirci on 6/6/26.
//

import SwiftUI

public struct LoadableValueView<
    Value: Sendable,
    Failure: Error,
    LoadedValueView: View,
    FailedValueView: View,
    LoadingView: View,
    IdleView: View,
    CancelledView: View
>: View {
    private let state: LoadableValue<Value, Failure>

    private let loadedView: (LoadingSuccess<Value>) -> LoadedValueView
    private let failedView: (LoadingFailure<Failure>) -> FailedValueView
    private let loadingView: () -> LoadingView
    private let idleView: () -> IdleView
    private let cancelledView: (Date) -> CancelledView

    /// Creates a view that renders different content based on a `LoadableValue` state.
    ///
    /// - Parameters:
    ///   - state: The current `LoadableValue` state to render.
    ///   - loaded: A view builder that receives `LoadingSuccess<Value>` and returns the view for the loaded state.
    ///   - failed: A view builder that receives `LoadingFailure<Failure>` and returns the view for the failed state.
    ///   - loading: A view builder for the loading state.
    ///   - idle: A view builder for the idle state.
    ///   - cancelled: A view builder that receives the cancellation `Date` for the cancelled state.
    public init(
        _ state: LoadableValue<Value, Failure>,
        @ViewBuilder loaded: @escaping (LoadingSuccess<Value>) -> LoadedValueView,
        @ViewBuilder failed: @escaping (LoadingFailure<Failure>) -> FailedValueView,
        @ViewBuilder loading: @escaping () -> LoadingView,
        @ViewBuilder idle: @escaping () -> IdleView,
        @ViewBuilder cancelled: @escaping (Date) -> CancelledView
    ) {
        self.state = state
        self.loadedView = loaded
        self.failedView = failed
        self.loadingView = loading
        self.idleView = idle
        self.cancelledView = cancelled
    }

    /// Convenience initializer that accepts the bare `Value` and `Failure` instead of the timestamped wrappers.
    public init(
        _ state: LoadableValue<Value, Failure>,
        @ViewBuilder loaded: @escaping (Value) -> LoadedValueView,
        @ViewBuilder failed: @escaping (Failure) -> FailedValueView,
        @ViewBuilder loading: @escaping () -> LoadingView,
        @ViewBuilder idle: @escaping () -> IdleView,
        @ViewBuilder cancelled: @escaping (Date) -> CancelledView
    ) {
        self.state = state
        self.loadedView = { success in loaded(success.value) }
        self.failedView = { failure in failed(failure.failure) }
        self.loadingView = loading
        self.idleView = idle
        self.cancelledView = cancelled
    }

    public var body: some View {
        switch state {
        case .idle:
            idleView()
        case .loading:
            loadingView()
        case .loaded(let success):
            loadedView(success)
        case .failed(let failure):
            failedView(failure)
        case .cancelled(let date):
            cancelledView(date)
        }
    }
}

public extension LoadableValueView where
    LoadingView == ProgressView<EmptyView, EmptyView>,
    IdleView == ProgressView<EmptyView, EmptyView>,
    CancelledView == EmptyView
{
    /// Convenience initializer where both the idle and loading states render a default `ProgressView`,
    /// and the cancelled state renders an `EmptyView`.
    ///
    /// - Parameters:
    ///   - state: The current `LoadableValue` state to render.
    ///   - loaded: A view builder that receives `LoadingSuccess<Value>`.
    ///   - failed: A view builder that receives `LoadingFailure<Failure>`.
    init(
        _ state: LoadableValue<Value, Failure>,
        @ViewBuilder loaded: @escaping (LoadingSuccess<Value>) -> LoadedValueView,
        @ViewBuilder failed: @escaping (LoadingFailure<Failure>) -> FailedValueView
    ) {
        self.init(
            state,
            loaded: loaded,
            failed: failed,
            loading: { ProgressView() },
            idle: { ProgressView() },
            cancelled: { _ in EmptyView() }
        )
    }

    /// Convenience initializer that accepts bare `Value` and `Failure` and uses `ProgressView` for idle/loading
    /// and `EmptyView` for cancelled.
    init(
        _ state: LoadableValue<Value, Failure>,
        @ViewBuilder loaded: @escaping (Value) -> LoadedValueView,
        @ViewBuilder failed: @escaping (Failure) -> FailedValueView
    ) {
        self.init(
            state,
            loaded: { success in loaded(success.value) },
            failed: { failure in failed(failure.failure) },
            loading: { ProgressView() },
            idle: { ProgressView() },
            cancelled: { _ in EmptyView() }
        )
    }
}


public extension LoadableValueView where
    LoadingView == ProgressView<EmptyView, EmptyView>,
    IdleView == ProgressView<EmptyView, EmptyView>
{
    /// Convenience initializer where both the idle and loading states render a default `ProgressView`,
    /// and the cancelled state renders an `EmptyView`.
    ///
    /// - Parameters:
    ///   - state: The current `LoadableValue` state to render.
    ///   - loaded: A view builder that receives `LoadingSuccess<Value>`.
    ///   - failed: A view builder that receives `LoadingFailure<Failure>`.
    init(
        _ state: LoadableValue<Value, Failure>,
        @ViewBuilder loaded: @escaping (LoadingSuccess<Value>) -> LoadedValueView,
        @ViewBuilder failed: @escaping (LoadingFailure<Failure>) -> FailedValueView,
        @ViewBuilder cancelled: @escaping (Date) -> CancelledView
    ) {
        self.init(
            state,
            loaded: loaded,
            failed: failed,
            loading: { ProgressView() },
            idle: { ProgressView() },
            cancelled: { cancelled($0) }
        )
    }

    /// Convenience initializer that accepts bare `Value` and `Failure` and uses `ProgressView` for idle/loading
    /// and `EmptyView` for cancelled.
    init(
        _ state: LoadableValue<Value, Failure>,
        @ViewBuilder loaded: @escaping (Value) -> LoadedValueView,
        @ViewBuilder failed: @escaping (Failure) -> FailedValueView,
        @ViewBuilder cancelled: @escaping (Date) -> CancelledView
    ) {
        self.init(
            state,
            loaded: { success in loaded(success.value) },
            failed: { failure in failed(failure.failure) },
            loading: { ProgressView() },
            idle: { ProgressView() },
            cancelled: { cancelled($0) }
        )
    }
}
