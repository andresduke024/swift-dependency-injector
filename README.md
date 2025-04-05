# swift-dependency-injector

[![Swift](https://img.shields.io/badge/Swift-5.4_5.5_5.6_5.7_5.8_5.9_5.10_6-blue?style=flat-square)](https://img.shields.io/badge/Swift-5.4_5.5_5.6_5.7_5.8_5.9_5.10_6-blue?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftDependencyInjector.svg?style=flat-square)](https://img.shields.io/cocoapods/v/SwiftDependencyInjector.svg?style=flat-square)


A native dependency container written in swift that manages the initialization, store, and injection of the dependencies of a given abstraction fast and safety.

## Index

- Installation
- Usage example
- Tests
- Demo
- Docs
    - Injector
    - @Inject
    - Injection contexts
    - Injection errors
    - Injection types
    - Instantiation types
- License

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

## Usage example

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

Third, now we have to register this dependencies into the container in order to be able to use them later as injectables values.

To achive this we are going to use the Injector class. This is a middleware that provide us with all the functions that we can use to access to the dependencies container.

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

Now that all dependencies are registered into the container we can start using them in other classes as injectables properties.

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

Notice that we don't have to define any kind of initializer for the property *repository*. The **@Inject** property wrapper will manage all the work of search into the dependencies container and extract an instance of an especific implementation of the **Repository** protocol.

For this to be possible we only have to take into account one thing. The data type of the property must be a protocol (previously registered in the container) and not a specific implementation.

And that's all, by this point we can replicate this steps for every dependency we want to make injectable and start to using them all around in our project.

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

Demo project. See the [demo](/Sources/swift-dependency-injector/demo) folder inside the repository's files for a more complex example.

---

## Docs

## Injector 

This a class which works as a middleware that provide us with all the functions that we can use to access to the dependencies container.

### Static members

#### Injector.build

To create a new instance of this class which runs on a isolated context.

**Parameters**:

- **context**: The new injection context that will be registered and use later to access to the dependencies container.

**Returns**:

- **Injector**: A new instance of itself

```swift
static func build(context: InjectionContext) -> Injector {}
```
---

#### Injector.global

A default instance of the class builded to run in a global injection context

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
- **implementations**:A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).

```swift
func register<Abstraction: Sendable>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> Abstraction?]) {}
```
---

#### register

To register into the dependencies container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction).

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency.
- **key**: The key to identify the implementation that will be injected. Can be omitted if you're sure this is the only implementations for the given abstraction.
- **implementation**: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).

```swift
func register<Abstraction: Sendable>(_ abstraction: Abstraction.Type, key: String = "", implementation: @escaping () -> Abstraction?) {}
```
---


#### add

To add into the container a new set of implementations of an already registered abstraction.

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency.
- **implementations**: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).

```swift
func add<Abstraction: Sendable>(_ abstraction: Abstraction.Type, implementations: [String: () -> Abstraction?]) {}
```
---

#### add

To add into the container a new implementation of an already registered abstraction.

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency.
- **key**: The key to identify the implementation that will be injected.
- **implementation**: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).

```swift
func add<Abstraction: Sendable>(_ abstraction: Abstraction.Type, key: String, implementation: @escaping () -> Abstraction?) {}
```
---

#### resetSingleton

To reset a specific or all the instances of a singleton dependency stored in the container.

**Parameters**:

- **abstraction**: Generic type. The protocol (already registered) to the one we want to reset the implementation or implementations used as singletons.
- **key**: A unique key that identifies the specific implementation that will be reseted. Nil if we want to reset all the implementations registered for the given abstraction.

```swift
func resetSingleton<Abstraction: Sendable>(of abstraction: Abstraction.Type, key: String? = nil) {}
```
---

#### remove

To remove all the registed implementations of a given abstraction and the abstraction itself

**Parameters**:

- **abstraction**: Generic type. The protocol that was registered as dependency

```swift
func remove<Abstraction: Sendable>(_ abstraction: Abstraction.Type) {}
```
---

#### clear

To remove all the registered abstractions and implementations

```swift
func clear() {}
```
---

#### turnOffLogger

To turn off the messages logged by the injector.

**Parameters**:

- **forced**: To know if error messages will be disabled too. False by default.

```swift
func func turnOffLogger(forced: Bool = false) {}
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
It use a generic value to define the abstraction that encapsulates the injected implemententations.

With this property wrapper we are taking for granted that an implementation is already registered into the container. In case that no implementation were registered into the container we will face a "Fatal Error" throwed in our app.

All the dependencies injected by using this property wrapper has two different ways of be injected (**InjectionType**).

- **regular**: 
    - Every injection is going to create a new instance of the given implementation.
- **singleton**: 
    - Every injection is going to get an already stored instance of the given implementation.
    - When is the first injection, its going to create, store and return a new instance of the given implementation.
    
**regular** is the default instantiation type, which means that it's not necessary to specified it when we use the wrapper.

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

Finally, we have a third argument to build an injectable property. The **'constrainedTo:'** property allow us to constraint the injection to a specific key. This means the injector will search into the container with the given key ignoring the key settled globally in the current context.

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

The injection contexts are used to separe a set of injectable abstractions and implementations from the ones used globaly all around the app.

This is useful to constraint a class to only extract implementations from a safe and isolated container and not from a global container that could be mutated from every where in the application. 

Exists three types of injection contexts:

- **global**: Used by the whole application, all dependencies will be registered into this context by default and it's accesible from every where. 
- **custom**: 
    - All the dependencies registered into this context will be isolated and only will be accessed when is requeried. 
    - This context can be created with a custom name (identifier) what it means that we can created every custom injection contexts as we want.
- **tests**: 
    - All the dependencies registered into this context will be isolated and only will be accessed when is requeried. 
    - This context can be created with a custom name (identifier) what it means that we can created every tests injection contexts as we want.
    - This context is very useful to isolate test cases and be sure that tests don't affect each other.
    - This context needs to know the name of the file where the subject (class) we will test is defined.

---

We can create a new injection context just by using the built in function **build(context:)** of the **Injector** class.

```swift
func setUp() {
    let injector = Injector.build(context: .custom(name: "Service"))
    
    injector.register(Repository.self, implementation: LocalRepository.instance)
}
```
---

**@Inject** also has the capability to specific a custom injection context to extract the implementation from a isolated container.

```swift
@Inject(context: .custom(name: "DummyContext"))
private var service: Service
```

This means when we will try to access to the wrapped value of the property, the dependencies contaier will search into the dependencies registered for the specified context and will extract from there a new implementation. 

When the container can't find a dependency in the context it will throw a fatal error. It never use the global context to search for a implementation.

---
**NOTES**

- By default all dependencies are created and injected using the global context.
- When we use a class with injectable properties which were created in the global injection context inside a Test case, the injector always gonna try search for a tests injection context. if we not previous define a related context for the test case to use it, it will get all the injections from global context.
---

## Injection Errors

- **AbstractionAlreadyRegistered**: 
    - When an abstraction is already store into the container. 
    - The container only allows to store one abstractions with one or many implementations.
    
- **ImplementationsCouldNotBeCasted**:
    - When an implementation is trying to be injected but it couldn't be casted as the specified abstraction data type.
    
- **NotAbstrationFound**:
    - When no registered abstraction was founded in the container with the given type.
    
- **AbstractionNotFoundForUpdate**:
    - When an abstraction that is supposed to was stored into the container couldn't be found to update its values.
    
- **UndefinedRegistrationType**: 
    -  When an abstraction is trying to be registered into the container with a registration type that is not handle yet.
    
- **NoImplementationFoundOnInjection**: 
    - When an implementation could not be injected into the wrapper, which means the current value of the wrapper is nil.
    
- **EqualDependecyKeyOnUpdate**:
    - When in the attempt to update the default dependency key of a specific abstraction the key thats already stored is equal to the new key.
    
- **ForcedInjectionFail**:
    - When no registered abstraction was founded in the container with the given type and it was requested from a forced injection. 
    - It produces a fatal error (Application crash).

## Injection types

Defines how all the implementations that will be injected are going to be created and returned.

- **regular**:
    - Every injection will create a new instance of the given implementation when this case is selected.
    
- **singleton**:
    - Every injection will get an already stored instance of the given implementation when this case is selected.
    - When is the first injection, will create, store and return a new instance of the given implementation.
    
## License

MIT license. See the [LICENSE file](LICENSE) for details.
