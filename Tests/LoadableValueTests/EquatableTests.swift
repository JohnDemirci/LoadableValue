//
//  EquatableTests.swift
//  LoadableValue
//
//  Created by John Demirci on 6/3/26.
//

import Foundation
import Testing
@testable import LoadableValue

@Suite("EquatableTests")
struct EquatableTests {
    enum Failure: Error, Equatable, Sendable {
        case one
        case two
    }

    @Test
    func `two loading failures are equal`() {
        let date = Date.now
        let error = Failure.one
        let error2 = Failure.one

        let failure1: LoadingFailure<Failure> = .init(failure: error, timestamp: date)
        let failure2: LoadingFailure<Failure> = .init(failure: error2, timestamp: date)

        #expect(failure1 == failure2)
    }

    @Test
    func `two loading failures are different`() {
        let date = Date.now
        let error = Failure.one
        let error2 = Failure.two

        let failure1: LoadingFailure<Failure> = .init(failure: error, timestamp: date)
        let failure2: LoadingFailure<Failure> = .init(failure: error2, timestamp: date)

        #expect(failure1 != failure2)
    }

    @Test
    func `loaded values with matching payloads are equal`() {
        let timestamp = Date.now

        let lhs: LoadableValue<Int, Failure> = .loaded(.init(value: 42, timestamp: timestamp))
        let rhs: LoadableValue<Int, Failure> = .loaded(.init(value: 42, timestamp: timestamp))

        #expect(lhs == rhs)
    }

    @Test
    func `different cases are not equal`() {
        let timestamp = Date.now

        let loaded: LoadableValue<Int, Failure> = .loaded(.init(value: 42, timestamp: timestamp))
        let loading: LoadableValue<Int, Failure> = .loading

        #expect(loaded != loading)
    }
}
