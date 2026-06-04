import Foundation
import Testing
@testable import LoadableValue

@Suite("LoadableValueCoreTests")
struct LoadableValueCoreTests {
    enum Failure: Error, Equatable, Sendable {
        case offline
        case unauthorized
    }

    @Test
    func `loaded state exposes value and preserves timestamp when modified`() {
        let timestamp = Date(timeIntervalSinceReferenceDate: 100)
        var subject: LoadableValue<[Int], Failure> = .loaded(
            .init(value: [1, 2], timestamp: timestamp)
        )

        #expect(subject.value == [1, 2])
        #expect(subject.failure == nil)
        #expect(subject.isFailure == false)

        subject.modify { values in
            values.append(3)
        }

        guard case let .loaded(success) = subject else {
            Issue.record("Expected a loaded value after modification")
            return
        }

        #expect(success.value == [1, 2, 3])
        #expect(success.timestamp == timestamp)
    }

    @Test
    func `failed state exposes failure details`() {
        let timestamp = Date(timeIntervalSinceReferenceDate: 200)
        let subject: LoadableValue<Int, Failure> = .failed(
            .init(failure: .offline, timestamp: timestamp)
        )

        #expect(subject.value == nil)
        #expect(subject.isFailure)
        #expect((subject.failure as? Failure) == .offline)
    }

    @Test
    func `isLoading only reports true for loading state`() {
        let loading: LoadableValue<Int, Failure> = .loading
        let idle: LoadableValue<Int, Failure> = .idle
        let loaded: LoadableValue<Int, Failure> = .loaded(
            .init(value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 300))
        )

        #expect(loading.isLoading())
        #expect(idle.isLoading() == false)
        #expect(loaded.isLoading() == false)
    }

    @Test
    func `map transforms loaded values and preserves timestamp`() {
        let timestamp = Date(timeIntervalSinceReferenceDate: 400)
        let subject: LoadableValue<Int, Failure> = .loaded(
            .init(value: 21, timestamp: timestamp)
        )

        let mapped = subject.map { "\($0 * 2)" }

        guard case let .loaded(success) = mapped else {
            Issue.record("Expected mapped value to remain loaded")
            return
        }

        #expect(success.value == "42")
        #expect(success.timestamp == timestamp)
    }

    @Test
    func `map leaves non loaded states unchanged`() {
        let failureTimestamp = Date(timeIntervalSinceReferenceDate: 500)
        let cancelledTimestamp = Date(timeIntervalSinceReferenceDate: 600)
        let failed: LoadableValue<Int, Failure> = .failed(
            .init(failure: .unauthorized, timestamp: failureTimestamp)
        )
        let cancelled: LoadableValue<Int, Failure> = .cancelled(cancelledTimestamp)
        let loading: LoadableValue<Int, Failure> = .loading
        let idle: LoadableValue<Int, Failure> = .idle

        let mappedFailed = failed.map(String.init)
        let mappedCancelled = cancelled.map(String.init)
        let mappedLoading = loading.map(String.init)
        let mappedIdle = idle.map(String.init)

        #expect(
            mappedFailed ==
                .failed(.init(failure: .unauthorized, timestamp: failureTimestamp))
        )
        #expect(mappedCancelled == .cancelled(cancelledTimestamp))
        #expect(mappedLoading == .loading)
        #expect(mappedIdle == .idle)
    }
}
