# swift-dependency-injector

[![Swift](https://img.shields.io/badge/Swift-5.4_5.5_5.6_5.7_5.8_5.9_5.10_6-blue?style=flat-square)](https://img.shields.io/badge/Swift-5.4_5.5_5.6_5.7_5.8_5.9_5.10_6-blue?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftDependencyInjector.svg?style=flat-square)](https://img.shields.io/cocoapods/v/SwiftDependencyInjector.svg?style=flat-square)

A native dependency container written in Swift that manages the initialization, storage, and injection of dependencies for a given abstraction with both speed and safety. This package includes powerful compile-time macros that eliminate boilerplate code and enable compile-safe dependency injection.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Macros Overview](#macros-overview)
  - [@DependenciesInjector](#dependenciesinjector-macro)
  - [@InjectableDependency](#injectabledependency-macro)
  - [@InjectedConstructor](#injectedconstructor-macro)
  - [@ObservableInjectedConstructor](#observableinjectedconstructor-macro)
  - [@InitParameter](#initparameter-macro)
- [Usage example](#usage-example)
- [Tests](#tests)
- [Demo](#demo)
- [Docs](#docs)
  - [Injector](#injector)
  - [@Inject](#inject)
  - [Injection Contexts](#injection-contexts)
  - [Injection Errors](#injection-errors)
  - [Injection Types](#injection-types)
- [License](#license)

---

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding swift-dependency-injector as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/andresduke024/swift-dependency-injector.git", .upToNextMinor(from: "2.0.0"))
]
```

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate SwiftDependencyInjector into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'SwiftDependencyInjector'
```

---

## Quick Start

Here's a minimal example to get you started with dependency injection using macros:

```swift
import SwiftDependencyInjectorMacros

// 1. Define your protocols
protocol Repository: Sendable {
    func fetch() -> [Int]
}

// 2. Create implementations and mark them as injectable dependencies
@InjectableDependency(of: Repository.self)
struct LocalRepository: Repository {
    func fetch() -> [Int] { [1, 2, 3, 4] }
}

// 3. Create a service with injected dependencies
protocol Service: Sendable {
    func getData() -> [Int]
}

@InjectableDependency(of: Service.self)
@InjectedConstructor(Repository.self)
struct MyService: Service {
    func getData() -> [Int] {
        repository.fetch()
    }
}

// 4. Setup your dependencies at app launch
@DependenciesInjector(
    LocalRepository.self,
    MyService.self
)
struct ApplicationSetup {
    static let shared = ApplicationSetup()
    private init() {}
}

// 5. Use the injected dependencies
class ViewController {
    @Inject private var service: Service
    
    func loadData() {
        let data = service.getData()
        print(data)
    }
}
```

---

## Macros Overview

This version introduces powerful Swift macros that eliminate boilerplate code and provide compile-time safety for dependency injection. The macros automatically generate the necessary code for dependency registration, initialization, and injection.

### @DependenciesInjector Macro

**Purpose**: Automatically registers multiple dependency implementations with the global dependency container.

The `@DependenciesInjector` macro generates an extension that registers all specified dependencies. This replaces manual registration calls and ensures all dependencies are registered before they're needed.

**Syntax**:
```swift
@DependenciesInjector(_ dependencies: Any...)
```

**Parameters**:
- `dependencies`: Variable number of type arguments representing the dependency implementations to register.

**Example**:
```swift
@DependenciesInjector(
    // Repositories
    LocalRepository.self,
    RemoteRepository.self,
    
    // Services
    AuthService.self,
    DataService.self,
    
    // Network
    APIClient.self
)
struct ApplicationSetup {
    static let shared = ApplicationSetup()
    
    private init() {}
}
```

**Generated Behavior**:
The macro creates registration code that registers all specified types. Each type must conform to `InjectableDependencyProtocol` (either through manual conformance or via the `@InjectableDependency` macro).

---

### @InjectableDependency Macro

**Purpose**: Marks a type as an injectable dependency and automatically generates the registration code needed by the DI container.

The `@InjectableDependency` macro transforms a concrete implementation into a registered dependency that can be injected throughout your application. It generates the necessary conformance to `InjectableDependencyProtocol` and handles both simple and complex registration scenarios.

**Syntax**:
```swift
@InjectableDependency(of: DependencyType.Type)
@InjectableDependency(of: InjectableDependencyArgs<T>)
```

**Parameters**:
- `of`: The abstraction (protocol or type) that this implementation conforms to or should be registered as.

**Example 1: Simple Registration (Single Implementation)**:
```swift
protocol UserRepository: Sendable {
    func getUser(id: Int) -> User?
}

@InjectableDependency(of: UserRepository.self)
struct DefaultUserRepository: UserRepository {
    func getUser(id: Int) -> User? {
        // Implementation
        nil
    }
}
```

**Example 2: Multiple Implementations with Keys**:
```swift
enum DataSourceType: String {
    case local
    case remote
}

@InjectableDependency(
    of: InjectableDependencyArgs(
        UserRepository.self,
        key: DataSourceType.local.rawValue
    )
)
struct LocalUserRepository: UserRepository {
    func getUser(id: Int) -> User? {
        // Local implementation
        nil
    }
}

@InjectableDependency(
    of: InjectableDependencyArgs(
        UserRepository.self,
        key: DataSourceType.remote.rawValue
    )
)
struct RemoteUserRepository: UserRepository {
    func getUser(id: Int) -> User? {
        // Remote implementation
        nil
    }
}
```

**Generated Protocol Conformance**:
The macro automatically implements the `InjectableDependencyProtocol`, allowing the type to be registered by the `@DependenciesInjector` macro.

---

### @InjectedConstructor Macro

**Purpose**: Automatically generates a convenience initializer that injects specified dependencies as properties.

This is one of the most powerful macros in the library. Instead of manually writing initializers and property declarations, `@InjectedConstructor` generates everything you need. It creates private properties for each specified dependency and synthesizes an initializer that automatically injects them using the DI container.

**Syntax**:
```swift
@InjectedConstructor(_ dependencies: Type.Type...)
```

**Parameters**:
- `dependencies`: Variable number of type arguments representing the dependencies to inject.

**Example 1: Basic Usage with Service Dependencies**:
```swift
protocol UserService: Sendable {
    func getUser(id: Int) -> User?
}

protocol AnalyticsService: Sendable {
    func trackEvent(_ event: String)
}

@InjectedConstructor(UserService.self, AnalyticsService.self)
class UserViewController: UIViewController {
    var data: User?
    
    func viewDidLoad() {
        super.viewDidLoad()
        data = userService.getUser(id: 1)
        analyticsService.trackEvent("view_loaded")
    }
}

// The macro generates (conceptually):
// private var userService: UserService { ... injected ... }
// private var analyticsService: AnalyticsService { ... injected ... }
// init() { /* automatic initialization */ }
```

**Example 2: Combining with Data Models**:
```swift
@InjectedConstructor(Repository.self, NetworkManager.self)
class DataViewModel {
    var items: [Item] = []
    
    func loadItems() async {
        items = await repository.fetchItems()
    }
}
```

**Example 3: In a Service Class**:
```swift
protocol NotificationService: Sendable {
    func sendNotification(_ message: String)
}

protocol LoggingService: Sendable {
    func log(_ message: String)
}

@InjectableDependency(of: NotificationService.self)
@InjectedConstructor(LoggingService.self)
struct PushNotificationService: NotificationService {
    func sendNotification(_ message: String) {
        loggingService.log("Sending notification: \(message)")
        // Implementation
    }
}
```

**How It Works**:

1. The macro scans all dependencies you specify
2. It creates private properties for each dependency
3. It generates an initializer that automatically injects these properties using the global injector.

The generated initializer ensures all dependencies are properly injected without requiring manual boilerplate code.

---

### @ObservableInjectedConstructor Macro

**Purpose**: Similar to `@InjectedConstructor` but specifically designed for observable patterns in SwiftUI.

This macro is functionally identical to `@InjectedConstructor` but is intended for classes that need to work with SwiftUI's `@Observable` macro. When applied, it automatically adds the `@ObservationIgnored` attribute to the injected dependency properties, ensuring they don't trigger view updates when modified.

**Syntax**:
```swift
@ObservableInjectedConstructor(_ dependencies: Type.Type...)
```

**Parameters**:
- `dependencies`: Variable number of type arguments representing the dependencies to inject.

**Example: SwiftUI Observable ViewModel**:
```swift
import SwiftUI
import SwiftDependencyInjector

@Observable
@ObservableInjectedConstructor(UserService.self, AnalyticsService.self)
class UserProfileViewModel {
    var user: User?
    var isLoading = false
    
    func loadUser(id: Int) async {
        isLoading = true
        user = await userService.getUser(id: id)
        analyticsService.trackEvent("user_loaded")
        isLoading = false
    }
}

// The macro generates:
// @ObservationIgnored private var userService: UserService
// @ObservationIgnored private var analyticsService: AnalyticsService
// init() { /* automatic initialization */ }
```

**Key Difference from @InjectedConstructor**:
- The `@ObservationIgnored` attribute is automatically added to all injected dependency properties
- This prevents changes to dependencies from triggering SwiftUI view re-renders
- Ideal for services that maintain state but shouldn't affect UI reactivity

---

### @InitParameter Macro

**Purpose**: Marks a property as an initialization parameter that must be provided during object construction.

The `@InitParameter` macro allows you to specify which properties should be exposed as parameters in the initializer generated by `@InjectedConstructor` or `@ObservableInjectedConstructor`. This gives you fine-grained control over what can be customized at initialization time. Note that `@InitParameter` is for properties that do NOT have default values and must be passed to the initializer.

**Syntax**:
```swift
@InitParameter
private var property: SomeType
```

**Example**:
```swift
@InjectedConstructor(Repository.self)
class DataViewModel {
    @InitParameter
    var pageSize: Int
    
    @InitParameter  
    var cacheEnabled: Bool
    
    var items: [Item] = []
    
    func loadItems() {
        items = repository.fetch(pageSize: pageSize)
    }
}

// The macro generates an initializer like:
// init(pageSize: Int, cacheEnabled: Bool, repository: Repository = Injector.global.get(Repository.self)) {
//     self.pageSize = pageSize
//     self.cacheEnabled = cacheEnabled
//     self.repository = repository
// }
```

**Important**: Use `@InitParameter` only for properties that need to be customized at initialization without default values. For properties with default values, add them directly to the property declaration outside of the macro's scope.

---

## Usage example (Without macros)

First, define a protocol. For this example we are going to use a **Repository** protocol that has the job to fetch some data.

```swift
protocol Repository: Sendable {
    func fetch() -> [Int]
}
```

Notice that protocol implements **Sendable** protocol. This is very important to ensure thread and concurrency safe rules for Swift 6.

Second, we have to create the classes that are going to implement this protocol.

```swift
struct LocalRepository: Repository {
    func fetch() -> [Int] { [1,2,3,4] }
}

struct RemoteRepository: Repository {
    func fetch() -> [Int] { [5,6,7,8] }
}
```

We can define an enum to identify the types of **Repository** that we will use in our app, but this is optional.


```swift
enum RepositoryType: String {
    case local
    case remote
}
```

Third, now we have to register this dependencies into the container in order to be able to use them later as injectable values.

To achieve this we are going to use the Injector class. This is a middleware that provides us with all the functions that we can use to access to the dependencies container.

```swift
Injector.global.register(Repository.self, defaultDependency: RepositoryType.remote.rawValue, implementations: [
    RepositoryType.remote.rawValue : { RemoteRepository() } ,
    RepositoryType.local.rawValue : { LocalRepository() }
])
```

The function Injector.register takes 3 parameters. The first one is the protocol that we are going to register, the second one is a key that allows to identify the dependency injected by default for the container and the third one is a dictionary. This dictionary has a key to identify each implementation and a function that allows to extract an instance of a specific implementation. 

---
**NOTE**

We recommend to register all the dependencies at the very beginning of the application run.

```swift
class ApplicationSetup {
    static func start() {
        Injector.global.register(Repository.self, defaultDependency: RepositoryType.remote.rawValue, implementations: [
            RepositoryType.remote.rawValue : { RemoteRepository() } ,
            RepositoryType.local.rawValue : { LocalRepository() }
        ])
    }
}
```

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ApplicationSetup.start()
    return true
}
```
---

Now that all dependencies are registered into the container we can start using them in other classes as injectable properties.

For that we are going to create a DummyService. This class is going to have one property of type **Repository** and this property is going to be wrapped by a custom property wrapper named **@Inject**.

```swift
class DummyService {
    @Inject 
    private var repository: Repository
    
    func getData() -> [Int] {
        repository.fetch()
    }
}
```

Notice that we don't have to define any kind of initializer for the property *repository*. The **@Inject** property wrapper will manage all the work of searching into the dependencies container and extracting an instance of a specific implementation of the **Repository** protocol.

For this to be possible we only have to take into account one thing. The data type of the property must be a protocol (previously registered in the container) and not a specific implementation.

And that's all, by this point we can replicate these steps for every dependency we want to make injectable and start using them all around in our project.

## Tests

We can easily mock our injected dependencies to make tests more efficient and reliable.

```swift
struct RepositoryMock: Repository {
    func fetch() -> [Int] { [1,2,3,4] }
}
```

The only thing we have to do now is register the mock dependency in our test file.
We can create a "test" injection context to isolate our injections.

```swift
final class ServiceTest: XCTestCase {
    private var injector: Injector!
    private var sut: Service!
    
    override func setUp() {
        injector = Injector.build(context: .tests(name: "Service"))
        injector.register(Repository.self) { RepositoryMock() }
        
        sut = DummyService()
    }
    
    override func tearDown() {
        injector.destroy()
        sut = nil
    }
    
    func testFetchData() throws {
        let expected = [1,2,3,4]
        
        let result = sut.getData()
        
        XCTAssertEqual(result, expected)
    }
}
```

## Demo

Demo project. See the demo folder inside the repository's files for a more complex example.

---

## Docs

## Injector 

This is a class which works as a middleware that provides us with all the functions that we can use to access to the dependencies container.

### Static members

#### Injector.build

To create a new instance of this class which runs on an isolated context.

**Parameters**:

- **context**: The new injection context that will be registered and used later to access to the dependencies container.

**Returns**:

- **Injector**: A new instance of itself

```swift
static func build(context: InjectionContext) -> Injector {}
```
---

#### Injector.global

A default instance of the class built to run in a global injection context

**Returns**:

- **Injector**: A singleton instance of itself

```swift
static var global: Injector
```
---

### Functions
---

#### register

To register into the dependencies container a new abstraction and its corresponding implementations.

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency.
- **defaultDependency**: The key to identify the implementation that will be injected.
- **implementations**: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation (classes that conform to InjectableDependency protocol).

```swift
func register<Abstraction: Sendable>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> Abstraction?]) {}
```
---

#### register

To register into the dependencies container a new abstraction and its corresponding implementation (Useful when only one implementation of the given abstraction exists).

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency.
- **key**: The key to identify the implementation that will be injected. Can be omitted if you're sure this is the only implementation for the given abstraction.
- **implementation**: A closure which has the job to create a new instance of the given implementation (classes that conform to InjectableDependency protocol).

```swift
func register<Abstraction: Sendable>(_ abstraction: Abstraction.Type, key: String = "", implementation: @escaping () -> Abstraction?) {}
```
---
#### add

To add into the container a new set of implementations of an already registered abstraction.

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency.
- **implementations**: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation (classes that conform to InjectableDependency protocol).

```swift
func add<Abstraction: Sendable>(_ abstraction: Abstraction.Type, implementations: [String: () -> Abstraction?]) {}
```
---

#### add

To add into the container a new implementation of an already registered abstraction.

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency.
- **key**: The key to identify the implementation that will be injected.
- **implementation**: A closure which has the job to create a new instance of the given implementation (classes that conform to InjectableDependency protocol).

```swift
func add<Abstraction: Sendable>(_ abstraction: Abstraction.Type, key: String, implementation: @escaping () -> Abstraction?) {}
```
---

#### resetSingleton

To reset a specific or all the instances of a singleton dependency stored in the container.

**Parameters**:

- **abstraction**: Generic type. The protocol (already registered) for which we want to reset the implementation or implementations used as singletons.
- **key**: A unique key that identifies the specific implementation that will be reset. Nil if we want to reset all the implementations registered for the given abstraction.

```swift
func resetSingleton<Abstraction: Sendable>(of abstraction: Abstraction.Type, key: String? = nil) {}
```
---

#### remove

To remove all the registered implementations of a given abstraction and the abstraction itself.

**Parameters**:

- **abstraction**: Generic type. The protocol that was registered as dependency.

```swift
func remove<Abstraction: Sendable>(_ abstraction: Abstraction.Type) {}
```
---

#### clear

To remove all the registered abstractions and implementations.

```swift
func clear() {}
```
---

#### turnOffLogger

To turn off the messages logged by the injector.

**Parameters**:

- **forced**: To know if error messages will be disabled too. False by default.

```swift
func turnOffLogger(forced: Bool = false) {}
```
---

#### turnOnLogger

To turn on all the information and error messages logged by the injector.

```swift
func turnOnLogger() {}
```
---

#### destroy

To remove the current context from the dependencies container.

```swift
func destroy() {}
```
---

## @Inject

The property wrapper used to mark a property as an injectable dependency.
It uses a generic value to define the abstraction that encapsulates the injected implementations.

With this property wrapper we are taking for granted that an implementation is already registered into the container. In case that no implementation were registered into the container we will face a "Fatal Error" thrown in our app.

All the dependencies injected by using this property wrapper have two different ways of being injected (**InjectionType**):

- **regular**: 
    - Every injection is going to create a new instance of the given implementation.
- **singleton**: 
    - Every injection is going to get an already stored instance of the given implementation.
    - When is the first injection, it's going to create, store and return a new instance of the given implementation.
    
**regular** is the default instantiation type, which means that it's not necessary to specify it when we use the wrapper.

For example, to use **regular** injection type we can do this:

```swift
@Inject 
private var repository: Repository
```
or

```swift
@Inject(injection: .regular)
private var repository: Repository
```

And to use **singleton** injection type we can do something like this:

```swift
@Inject(injection: .singleton) 
private var repository: Repository
```

Finally, we have a third argument to build an injectable property. The **'constrainedTo:'** parameter allows us to constrain the injection to a specific key. This means the injector will search into the container with the given key, ignoring the key set globally in the current context.

```swift
@Inject(constrainedTo: RepositoryType.remote.rawValue)
private var repository: Repository
```

---
**NOTE**

It's not necessary to specify both, we can only change one and let the other be selected by default, like this:

```swift
@Inject(injection: .singleton) 
private var repository: Repository
```

```swift
@Inject(constrainedTo: RepositoryType.remote.rawValue)
private var repository: Repository
```
---

## Injection Contexts 

The injection contexts are used to separate a set of injectable abstractions and implementations from the ones used globally all around the app.

This is useful to constrain a class to only extract implementations from a safe and isolated container and not from a global container that could be mutated from everywhere in the application. 

There are three types of injection contexts:

- **global**: Used by the whole application, all dependencies will be registered into this context by default and it's accessible from everywhere. 
- **custom**: 
    - All the dependencies registered into this context will be isolated and only will be accessed when required. 
    - This context can be created with a custom name (identifier), which means we can create every custom injection context as we want.
- **tests**: 
    - All the dependencies registered into this context will be isolated and only will be accessed when required. 
    - This context can be created with a custom name (identifier), which means we can create every test injection context as we want.
    - This context is very useful to isolate test cases and ensure that tests don't affect each other.
    - This context needs to know the name of the file where the subject (class) we will test is defined.

---

We can create a new injection context just by using the built-in function **build(context:)** of the **Injector** class.

```swift
func setUp() {
    let injector = Injector.build(context: .custom(name: "Service"))
    
    injector.register(Repository.self, key: "", implementation: { LocalRepository() })
}
```
---

**@Inject** also has the capability to specify a custom injection context to extract the implementation from an isolated container.

```swift
@Inject(context: .custom(name: "DummyContext"))
private var service: Service
```

This means when we will try to access to the wrapped value of the property, the dependencies container will search into the dependencies registered for the specified context and will extract from there a new implementation. 

When the container can't find a dependency in the context it will throw a fatal error. It never uses the global context to search for an implementation.

---
**NOTES**

- By default all dependencies are created and injected using the global context.
- When we use a class with injectable properties which were created in the global injection context inside a test case, the injector will always try to search for a tests injection context. If we haven't previously defined a related context for the test case to use it, it will get all the injections from the global context.
---

## Injection Errors

- **AbstractionAlreadyRegistered**: 
    - When an abstraction is already stored into the container. 
    - The container only allows to store one abstraction with one or many implementations.
    
- **ImplementationsCouldNotBeCasted**:
    - When an implementation is trying to be injected but it couldn't be cast as the specified abstraction data type.
    
- **NotAbstractionFound**:
    - When no registered abstraction was found in the container with the given type.
    
- **AbstractionNotFoundForUpdate**:
    - When an abstraction that is supposed to be stored into the container couldn't be found to update its values.
    
- **UndefinedRegistrationType**: 
    - When an abstraction is trying to be registered into the container with a registration type that is not handled yet.
    
- **NoImplementationFoundOnInjection**: 
    - When an implementation could not be injected into the wrapper, which means the current value of the wrapper is nil.
    
- **EqualDependencyKeyOnUpdate**:
    - When in the attempt to update the default dependency key of a specific abstraction, the key that's already stored is equal to the new key.
    
- **ForcedInjectionFail**:
    - When no registered abstraction was found in the container with the given type and it was requested from a forced injection. 
    - It produces a fatal error (Application crash).

## Injection types

Defines how all the implementations that will be injected are going to be created and returned.

- **regular**:
    - Every injection will create a new instance of the given implementation when this case is selected.
    
- **singleton**:
    - Every injection will get an already stored instance of the given implementation when this case is selected.
    - When is the first injection, it will create, store and return a new instance of the given implementation.

---
    
## License

MIT license. See the LICENSE file for details.
