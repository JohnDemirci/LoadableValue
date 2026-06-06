//
//  Loadable.swift
//  LoadableValue
//
//  Created by John Demirci on 6/5/26.
//

import Foundation
import SwiftUI

/// A SwiftUI dynamic property for storing and controlling a `LoadableValue`.
///
/// `Loadable` behaves like a focused `@State` wrapper: it owns the loadable state for the
/// lifetime of the view identity, exposes bindings through its projection, and provides explicit
/// task helpers for callers that want the wrapper to drive a loading operation.
@MainActor
@propertyWrapper
public struct Loadable<Value: Sendable, Failure: Error>: DynamicProperty {
    @State private var state: LoadableValue<Value, Failure>
    @State private var task: Task<Void, Never>?
    @State private var generation: UInt64

    /// Creates a loadable value in the idle state.
    public init() {
        self.init(wrappedValue: .idle)
    }

    /// Creates a loadable value with an explicit initial state.
    ///
    /// This initializer supports `@Loadable(.loading) var value` style declarations.
    ///
    /// - Parameter initialValue: The initial loadable state.
    public init(_ initialValue: LoadableValue<Value, Failure>) {
        self.init(wrappedValue: initialValue)
    }

    /// Creates a loadable value with an explicit initial state.
    ///
    /// This initializer supports `@Loadable var value = ...` style declarations.
    ///
    /// - Parameter initialValue: The initial loadable state.
    public init(wrappedValue initialValue: LoadableValue<Value, Failure>) {
        self._state = State(initialValue: initialValue)
        self._task = State(initialValue: nil)
        self._generation = State(initialValue: 0)
    }

    /// The current loadable state.
    public var wrappedValue: LoadableValue<Value, Failure> {
        get {
            state
        }
        nonmutating set {
            state = newValue
        }
    }

    /// A controller that exposes bindings and explicit loading operations.
    public var projectedValue: LoadableProjection<Value, Failure> {
        LoadableProjection(
            state: $state,
            task: $task,
            generation: $generation
        )
    }
}

/// Bindings and operations exposed by `@Loadable`.
@MainActor
public struct LoadableProjection<Value: Sendable, Failure: Error> {
    @Binding private var state: LoadableValue<Value, Failure>
    @Binding private var task: Task<Void, Never>?
    @Binding private var generation: UInt64

    init(
        state: Binding<LoadableValue<Value, Failure>>,
        task: Binding<Task<Void, Never>?>,
        generation: Binding<UInt64>
    ) {
        self._state = state
        self._task = task
        self._generation = generation
    }

    /// A binding to the full `LoadableValue`.
    public var binding: Binding<LoadableValue<Value, Failure>> {
        $state
    }

    func valueBinding(`default`: Value) -> Binding<Value> {
        guard case let .loaded(success) = state else {
            return .constant(`default`)
        }

        return Binding(
            get: {
                guard case let .loaded(currentSuccess) = state else {
                    return success.value
                }

                return currentSuccess.value
            },
            set: { newValue in
                guard case let .loaded(currentSuccess) = state else {
                    return
                }

                state = .loaded(
                    newValue,
                    timestamp: currentSuccess.timestamp
                )
            }
        )
    }

    /// Cancels the current loading task and marks the state as cancelled.
    public func cancel() {
        _ = advanceGeneration()
        task?.cancel()
        task = nil
        state = .cancelled(Date())
    }

    /// Cancels the current loading task and returns the state to idle.
    public func reset() {
        _ = advanceGeneration()
        task?.cancel()
        task = nil
        state = .idle
    }

    private func advanceGeneration() -> UInt64 {
        let nextGeneration = generation &+ 1
        generation = nextGeneration
        return nextGeneration
    }
}

public extension LoadableProjection where Failure == Error {
    /// Runs an async throwing operation and updates the loadable state as it completes.
    ///
    /// This convenience is intentionally available only for erased `Error` failures. Typed
    /// failure users should assign typed `.failed` states directly.
    ///
    /// - Parameters:
    ///   - priority: The priority for the task. Defaults to Swift's inherited task priority.
    ///   - operation: The async operation that produces the loaded value.
    func load(
        priority: TaskPriority? = nil,
        _ operation: @escaping @Sendable () async throws -> Value
    ) {
        task?.cancel()

        let operationGeneration = advanceGeneration()
        state = .loading

        let stateBinding = $state
        let taskBinding = $task
        let generationBinding = $generation

        let newTask = Task(priority: priority) { @MainActor in
            defer {
                if generationBinding.wrappedValue == operationGeneration {
                    taskBinding.wrappedValue = nil
                }
            }

            do {
                let value = try await operation()
                try Task.checkCancellation()

                guard generationBinding.wrappedValue == operationGeneration else {
                    return
                }

                stateBinding.wrappedValue = .loaded(value)
            } catch {
                guard generationBinding.wrappedValue == operationGeneration else {
                    return
                }

                if error is CancellationError || Task.isCancelled {
                    stateBinding.wrappedValue = .cancelled(Date())
                } else {
                    stateBinding.wrappedValue = .failed(error)
                }
            }
        }

        task = newTask
    }
}
