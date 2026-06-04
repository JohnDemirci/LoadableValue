//
//  EquatableTests.swift
//  LoadableValue
//
//  Created by John Demirci on 6/3/26.
//

import Foundation
import Testing
@testable import LoadableValue


struct EquatableTests {
    enum Failure: Error {
        case one
        case two
    }

    @Test
    func `two loadingFailures are equal`(){
        let date = Date.now
        let error = Failure.one
        let error2 = Failure.one

        let failure1: LoadingFailure<Failure> = .init(date: date, error: error)
        let failure2: LoadingFailure<Failure> = .init(date: date, error: error2)

        #expect(failure1 == failure2)
    }

    @Test
    func `two loading failures are different`() {
        let date = Date.now
        let error = Failure.one
        let error2 = Failure.two

        let failure1: LoadingFailure<Failure> = .init(date: date, error: error)
        let failure2: LoadingFailure<Failure> = .init(date: date, error: error2)

        #expect(failure1 != failure2)
    }
}
