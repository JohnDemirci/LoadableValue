import SwiftUI
import Testing
@testable import LoadableValue

@Suite("LoadableSwiftUITests")
struct LoadableSwiftUITests {
    enum SampleFailure: Error, Equatable, Sendable {
        case failed
    }

    @MainActor
    @Test
    func `projection value binding modifies loaded value and preserves timestamp`() {
        let timestamp = Date(timeIntervalSinceReferenceDate: 700)
        let state = Box<LoadableValue<[Int], SampleFailure>>(
            .loaded([1], timestamp: timestamp)
        )
        let task = Box<Task<Void, Never>?>(nil)
        let generation = Box<UInt64>(0)
        let projection = makeProjection(
            state: state,
            task: task,
            generation: generation
        )

        guard let value = projection.value else {
            Issue.record("Expected loaded state to expose a value binding")
            return
        }

        value.wrappedValue = [1, 2, 3]

        guard case let .loaded(success) = state.value else {
            Issue.record("Expected state to remain loaded")
            return
        }

        #expect(success.value == [1, 2, 3])
        #expect(success.timestamp == timestamp)
    }

    @MainActor
    @Test
    func `projection value binding is nil when state is not loaded`() {
        let state = Box<LoadableValue<Int, SampleFailure>>(.idle)
        let projection = makeProjection(
            state: state,
            task: Box<Task<Void, Never>?>(nil),
            generation: Box<UInt64>(0)
        )

        #expect(projection.value == nil)
    }

    @MainActor
    @Test
    func `load succeeds and clears stored task`() async {
        let state = Box<LoadableValue<Int, Error>>(.idle)
        let task = Box<Task<Void, Never>?>(nil)
        let generation = Box<UInt64>(0)
        let projection = makeProjection(
            state: state,
            task: task,
            generation: generation
        )

        projection.load {
            42
        }

        #expect(state.value == .loading)
        #expect(task.value != nil)

        await yieldUntil {
            if case .loaded = state.value {
                return true
            }

            return false
        }

        guard case let .loaded(success) = state.value else {
            Issue.record("Expected load to finish with a loaded value")
            return
        }

        #expect(success.value == 42)
        #expect(task.value == nil)
    }

    @MainActor
    @Test
    func `cancel marks state cancelled and prevents stale completion`() async {
        let state = Box<LoadableValue<Int, Error>>(.idle)
        let task = Box<Task<Void, Never>?>(nil)
        let generation = Box<UInt64>(0)
        let projection = makeProjection(
            state: state,
            task: task,
            generation: generation
        )

        projection.load {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return 42
        }

        projection.cancel()
        await Task.yield()

        guard case .cancelled = state.value else {
            Issue.record("Expected cancellation state")
            return
        }

        #expect(task.value == nil)
    }

    @MainActor
    @Test
    func `reset cancels task and returns to idle`() {
        let state = Box<LoadableValue<Int, Error>>(.loading)
        let task = Box<Task<Void, Never>?>(Task {})
        let generation = Box<UInt64>(0)
        let projection = makeProjection(
            state: state,
            task: task,
            generation: generation
        )

        projection.reset()

        #expect(state.value == .idle)
        #expect(task.value == nil)
    }

    @MainActor
    private func makeProjection<Value: Sendable, Failure: Error>(
        state: Box<LoadableValue<Value, Failure>>,
        task: Box<Task<Void, Never>?>,
        generation: Box<UInt64>
    ) -> LoadableProjection<Value, Failure> {
        LoadableProjection(
            state: Binding(
                get: { state.value },
                set: { state.value = $0 }
            ),
            task: Binding(
                get: { task.value },
                set: { task.value = $0 }
            ),
            generation: Binding(
                get: { generation.value },
                set: { generation.value = $0 }
            )
        )
    }

    @MainActor
    private func yieldUntil(_ condition: @MainActor () -> Bool) async {
        for _ in 0..<10 {
            if condition() {
                return
            }

            await Task.yield()
        }
    }
}

private final class Box<Value>: @unchecked Sendable {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}

private struct LoadableCompileProbe: View {
    @Loadable private var number: LoadableValue<Int, Error>

    var body: some View {
        EmptyView()
            .task {
                _ = $number.binding
                _ = $number.value
                $number.load { 1 }
                $number.cancel()
                $number.reset()
                number = .loaded(2)
            }
    }
}
