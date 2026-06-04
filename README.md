# LoadableValue

`LoadableValue` is a small Swift package for modeling asynchronous state in a way that stays explicit in both business logic and SwiftUI. It tracks five states, preserves timestamps for success and failure, and includes helpers for transforming and combining values.

## Features

- Explicit async state with `idle`, `loading`, `loaded`, `failed`, and `cancelled`
- Timestamped wrappers for success and failure via `LoadingSuccess` and `LoadingFailure`
- Functional helpers like `map` and in-place mutation for loaded values
- Variadic `zip` for combining multiple `LoadableValue`s into one tuple
- SwiftUI view modifiers for reacting to state changes

## Requirements

- Swift tools version `6.2`
- Platforms:
  - iOS 15+
  - macOS 15+
  - tvOS 15+
  - watchOS 9+
  - visionOS 1+
  - Mac Catalyst 15+
  - DriverKit 19+

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/JohnDemirci/LoadableValue.git", branch: "master")
]
```

Then add the product to your target:

```swift
dependencies: [
    .product(name: "LoadableValue", package: "LoadableValue")
]
```

If you start publishing tagged releases later, switch the dependency to a semantic version requirement.

## Core Type

```swift
public enum LoadableValue<Value: Sendable, Failure: Error> {
    case cancelled(Date)
    case failed(LoadingFailure<Failure>)
    case loaded(LoadingSuccess<Value>)
    case loading
    case idle
}
```

`LoadingSuccess` and `LoadingFailure` both include a `timestamp`, which makes it easy to reason about freshness, ordering, and cancellation timing.

## Basic Usage

```swift
import LoadableValue

enum UserError: Error, Sendable {
    case offline
}

struct User: Sendable {
    let name: String
}

var profile: LoadableValue<User, UserError> = .idle

profile = .loading
profile = .loaded(.init(value: User(name: "Taylor"), timestamp: .now))

if let user = profile.value {
    print(user.name)
}
```

Pattern matching remains the most direct way to work with the full state:

```swift
switch profile {
case .idle:
    break
case .loading:
    break
case .loaded(let success):
    print(success.value, success.timestamp)
case .failed(let failure):
    print(failure.failure, failure.timestamp)
case .cancelled(let date):
    print(date)
}
```

## Transforming Values

Use `map` to transform only the loaded payload while preserving its timestamp:

```swift
let count: LoadableValue<Int, UserError> = .loaded(.init(value: 21, timestamp: .now))
let text = count.map { "\($0 * 2)" }
```

Use `modify` when you want to mutate the loaded value in place:

```swift
var items: LoadableValue<[String], UserError> = .loaded(
    .init(value: ["A"], timestamp: .now)
)

items.modify { values in
    values.append("B")
}
```

`modify` preserves the original success timestamp.

## Combining Multiple Loads

`zip` combines multiple `LoadableValue`s into a single tuple result:

```swift
let user: LoadableValue<String, UserError> = .loaded(.init(value: "Taylor", timestamp: .now))
let score: LoadableValue<Int, UserError> = .loaded(.init(value: 42, timestamp: .now))

let combined = zip(user, score)
```

When every input is loaded, the result is `.loaded((value1, value2, ...))` and uses the latest success timestamp across the inputs.

When states differ, `zip` resolves them with this priority:

1. `failed`
2. `idle`
3. `cancelled`
4. `loading`
5. `loaded`

That means a single failure wins immediately, `idle` blocks progress ahead of cancellation and loading, and `loading` is only returned when no higher-priority state is present.

## SwiftUI Helpers

The package includes view modifiers that react to `Binding<LoadableValue<...>>` changes:

- `onIdle`
- `onLoading`
- `onLoadingComplete`
- `onFailure`
- `onCancellation`

Each modifier has sync and async overloads. Example:

```swift
import SwiftUI
import LoadableValue

struct ProfileView: View {
    @State private var profile: LoadableValue<String, UserError> = .idle

    var body: some View {
        content
            .onIdle(of: $profile) {
                await load()
            }
            .onFailure(of: $profile) { failure in
                print(failure.failure)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch profile {
        case .idle, .loading:
            ProgressView()
        case .loaded(let success):
            Text(success.value)
        case .failed:
            Text("Failed to load")
        case .cancelled:
            Text("Cancelled")
        }
    }

    private func load() async {
        profile = .loading
        profile = .loaded(.init(value: "Taylor", timestamp: .now))
    }
}
```

## Testing

The package uses Swift Testing. Run the test suite with:

```bash
swift test
```
