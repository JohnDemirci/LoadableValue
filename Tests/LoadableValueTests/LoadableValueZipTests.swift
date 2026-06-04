import Foundation
import Testing
@testable import LoadableValue

@Suite("LoadableValueZipTests")
struct LoadableValueZipTests {
    enum Failure: Error, Equatable, Sendable {
        case offline
        case timeout
    }

    @Test
    func `zip returns a loaded tuple and latest success timestamp`() {
        let early = Date(timeIntervalSinceReferenceDate: 100)
        let late = Date(timeIntervalSinceReferenceDate: 200)

        let first: LoadableValue<String, Failure> = .loaded(.init(value: "abc", timestamp: early))
        let second: LoadableValue<Int, Failure> = .loaded(.init(value: 7, timestamp: late))

        let result = zip(first, second)

        guard case let .loaded(success) = result else {
            Issue.record("Expected zip to produce a loaded result")
            return
        }

        #expect(success.value.0 == "abc")
        #expect(success.value.1 == 7)
        #expect(success.timestamp == late)
    }

    @Test
    func `zip aggregates failures and uses earliest failure timestamp`() {
        let early = Date(timeIntervalSinceReferenceDate: 100)
        let late = Date(timeIntervalSinceReferenceDate: 200)

        let first: LoadableValue<String, Failure> = .failed(.init(failure: .offline, timestamp: late))
        let second: LoadableValue<Int, Failure> = .failed(.init(failure: .timeout, timestamp: early))

        let result = zip(first, second)

        guard case let .failed(loadingFailure) = result else {
            Issue.record("Expected zip to fail when any input has failed")
            return
        }

        let zippedError = loadingFailure.failure

        #expect(loadingFailure.timestamp == early)
        #expect(zippedError.timestamps == [late, early])
        #expect(zippedError.errors.count == 2)
        #expect((zippedError.errors[0] as? Failure) == .offline)
        #expect((zippedError.errors[1] as? Failure) == .timeout)
    }

    @Test
    func `zip returns idle before cancelled or loading`() {
        let cancellationDate = Date(timeIntervalSinceReferenceDate: 300)

        let idle: LoadableValue<String, Failure> = .idle
        let cancelled: LoadableValue<Int, Failure> = .cancelled(cancellationDate)

        let result = zip(idle, cancelled)

        guard case .idle = result else {
            Issue.record("Expected zip to return idle when any input is idle and no failures are present")
            return
        }
    }

    @Test
    func `zip returns cancelled before loading`() {
        let cancellationDate = Date(timeIntervalSinceReferenceDate: 400)

        let cancelled: LoadableValue<String, Failure> = .cancelled(cancellationDate)
        let loading: LoadableValue<Int, Failure> = .loading

        let result = zip(cancelled, loading)

        guard case let .cancelled(date) = result else {
            Issue.record("Expected zip to return cancelled before loading")
            return
        }

        #expect(date == cancellationDate)
    }

    @Test
    func `zip returns loading when no higher priority state is present`() {
        let loaded: LoadableValue<String, Failure> = .loaded(
            .init(value: "ready", timestamp: Date(timeIntervalSinceReferenceDate: 500))
        )
        let loading: LoadableValue<Int, Failure> = .loading

        let result = zip(loaded, loading)

        guard case .loading = result else {
            Issue.record("Expected zip to remain loading when no higher priority state is present")
            return
        }
    }
}
