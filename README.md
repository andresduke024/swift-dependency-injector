# swift-dependency-injector

[![Swift](https://img.shields.io/badge/Swift-5.4_5.5_5.6_5.7_5.8-blue?style=flat-square)](https://img.shields.io/badge/Swift-5.4_5.5_5.6_5.7_5.8-blue?style=flat-square)
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
    - @Injectable
    - @ObservedInjectable
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
    .package(url: "https://github.com/andresduke024/swift-dependency-injector.git", .upToNextMinor(from: "1.3.0"))
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
protocol Repository {
    func fetch() -> [Int]
}
```

Second, we have to create the classes that are going to implement this protocol.

```swift
class LocalRepository: Repository, InjectableDependency {
    required init() {}
    
    func fetch() -> [Int] { [1,2,3,4] }
}

class RemoteRepository: Repository, InjectableDependency {
    required init() {}
    
    func fetch() -> [Int] { [5,6,7,8] }
}
```

Notice that both classes implements the Injectable Dependency protocol too. This protocol defines a default property that give us a contract to access to an instance of the class. We will use this property later.

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
    RepositoryType.remote.rawValue : RemoteRepository.instance,
    RepositoryType.local.rawValue : LocalRepository.instance
])
```

The function Injector.register takes 3 parameters. The first one is the protocol that we are going to register, the second one is a key that allows to identify the dependency injected by default for the container and the third one is a dictionary. This dictionary has a key to identify each implementation and a function that allows to extract an instance of a specific implementation. 

At this point it becomes useful the **InjectableDependecy** protocol, as all our classes implements this protocol we now have access to the property 'instance' that makes the work for us of define an initializer for the class.

---
**NOTE**

We recommend to register all the dependencies at the very beginning of the application run.

```swift
class ApplicationSetup {
    static func start() {
        Injector.global.register(Repository.self, defaultDependency: RepositoryType.remote.rawValue, implementations: [
            RepositoryType.remote.rawValue : RemoteRepository.instance,
            RepositoryType.local.rawValue : LocalRepository.instance
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

For that we are going to create a DummyService. This class is going to have one property of type **Repository** and this property is going to be wrapped by a custom property wrapper named **@Injectable**.

```swift
class DummyService {
    @Injectable private var repository: Repository?
    
    func getData() -> [Int] {
        repository?.fetch() ?? []
    }
}
```

Notice that we don't have to define any kind of initializer for the property *repository*. The **@Injectable** property wrapper will manage all the work of search into the dependencies container and extract an instance of an especific implementation of the **Repository** protocol.

For this to be possible we only have to take into account two things. The first thing is that the data type of the property must be a protocol (previously registered in the container) and not a specific implementation.
The second thing to note is that the property must be marked as an optional data type, because in case the container is not able to find an implementation to inject it will return a nil value.

And that's all, by this point we can replicate this steps for every dependency we want to make injectable and start to using them all around in our project.

## Tests

We can easily mock our injected dependencies to make tests more efficient and reliable.


```swift
class RepositoryMock: Repository, InjectableDependency {
    required init() {}

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
        injector.register(Repository.self, implementation: RepositoryMock.instance)
        
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
func register<Abstraction>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> Abstraction?]) {}
```
---

#### register

To register into the dependencies container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction).

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency.
- **key**: The key to identify the implementation that will be injected. Can be omitted if you're sure this is the only implementations for the given abstraction.
- **implementation**: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).

```swift
func register<Abstraction>(_ abstraction: Abstraction.Type, key: String = "", implementation: @escaping () -> Abstraction?) {}
```
---


#### add

To add into the container a new set of implementations of an already registered abstraction.

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency.
- **implementations**: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).

```swift
func add<Abstraction>(_ abstraction: Abstraction.Type, implementations: [String: () -> Abstraction?]) {}
```
---

#### add

To add into the container a new implementation of an already registered abstraction.

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency.
- **key**: The key to identify the implementation that will be injected.
- **implementation**: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).

```swift
func add<Abstraction>(_ abstraction: Abstraction.Type, key: String, implementation: @escaping () -> Abstraction?) {}
```
---

#### updateDependencyKey

To change the default implementation injected for a given abstraction by changing the key used in the container.

**Parameters**:

- **abstraction**: Generic type. The protocol (already registered) to the one we want to change the injected implementation.
- **newKey**: A unique key that identifies the new implementation that will be injected by default.

```swift
func updateDependencyKey<Abstraction>(of abstraction: Abstraction.Type, newKey: String) {}
```
---

#### resetSingleton

To reset a specific or all the instances of a singleton dependency stored in the container.

**Parameters**:

- **abstraction**: Generic type. The protocol (already registered) to the one we want to reset the implementation or implementations used as singletons.
- **key**: A unique key that identifies the specific implementation that will be reseted. Nil if we want to reset all the implementations registered for the given abstraction.

```swift
func resetSingleton<Abstraction>(of abstraction: Abstraction.Type, key: String? = nil) {}
```
---

#### remove

To remove all the registed implementations of a given abstraction and the abstraction itself

**Parameters**:

- **abstraction**: Generic type. The protocol that was registered as dependency

```swift
func remove<Abstraction>(_ abstraction: Abstraction.Type) {}
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

## @Injectable

The property wrapper used to mark a property as an injectable dependency.
It use a generic value to define the abstraction that encapsulates the injected implemententations.

All the dependencies injected by using this property wrapper has two different ways of be injected (**InjectionType**).

- **regular**: 
    - Every injection is going to create a new instance of the given implementation.
- **singleton**: 
    - Every injection is going to get an already stored instance of the given implementation.
    - When is the first injection, its going to create, store and return a new instance of the given implementation.
    
And also will have two different ways of be instantiate (**InstantiationType**).    

- **regular**:
    - The implementation will be instantiate at the creation of the property wrapper.
- **lazy**:
    - The implementation will not be instantiate until it's required for the first time.
    
**regular** and **lazy** are the default injection and instantiation types, which means that it's not necessary to specified them when we use the wrapper.

For example, to use **regular** injection type and **lazy** instantiation type we can do this:

```swift
@Injectable private var repository: Repository?
```
or

```swift
@Injectable(injection: .regular, instantiation: .lazy)
private var repository: Repository?
```

And to use **singleton** injection type and **regular** instantiation type we can do something like this:

```swift
@Injectable(injection: .singleton, instantiation: .regular) 
private var repository: Repository?
```

Finally, we have a third argument to build an injectable property. The **'constrainedTo:'** property allow us to constraint the injection to a specific key. This means the injector will search into the container with the given key ignoring the key settled globally in the current context.

```swift
@Injectable(constrainedTo: RepositoryType.remote.rawValue)
private var repository: Repository?
```

---
**NOTE**

It's not necessary to specify both, we can only change one and let the other be selected by default, like this:

```swift
@Injectable(injection: .singleton) 
private var repository: Repository?
```

```swift
@Injectable(instantiation: .regular) 
private var repository: Repository?
```
---

## @ObservedInjectable

The property wrapper used to mark a property as an injectable dependency which can be replaced at runtime several times.
It use a generic value to define the abstraction that encapsulates the injected implemententations.

```swift
@ObservedInjectable private var repository: Repository?
```

This feature can be useful when we want to change the implementation of a dependency in real time.

Imagine that we have a NetworkManager which listen to changes on internet connection. We want to use a local repository if the connection is failing and a remote repository if the connection is working successfully.

To achieve that we can use the Injector class to change the default implementation of **Repository** dependency every time the connection changes.

```swift
class DummyNetworkManager {
    func validateConnection() {
        let isNetworkAvailable = Bool.random()
        
        let repositoryImplementation: RepositoryType = isNetworkAvailable ? .remote : .local
        Injector.updateDependencyKey(of: Repository.self, newKey: repositoryImplementation.rawValue)
    }
}
```

When the default dependencies key changes a new implementation will be published to all the injectable properties that are using this property wrapper and this will automatically replace the previous stored implementation with the new one.

And we can do this all the times we want and the implementations are going to change immediately.

Unlike **@Injectable** this property wrapper doesn't expose the options to select the instantiation type or injection type.

This means that all properties wrapped with **@ObservedInjectable** will be create with and injection type and an instantion type **regular**

---

---
**NOTES**

- When we use the wrapped value of each property wrapper we will obtain the implementation injected and instantiate based on the selected parameters. This value could be nil if at some point occurs an error on the injection process.
- It is important to note that when we update the default value of a key for a specific dependency, it has to match one of the keys we registered when saving the dependencies in the container.
- This works for singleton dependencies too. We change the injected value but in this case is not going to be a new instance but a previous stored singleton instance of the new defined implementation.
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

Both wrappers (@Injectable and @ObservedInjectable) also has the capability to specific a custom injection context to extract the implementation from a isolated container.

```swift
@Injectable(context: .custom(name: "DummyContext"))
private var service: Service?
```

This means when we will try to access to the wrapped value of the property, the dependencies contaier will search into the dependencies registered for the specified context and will extract from there a new implementation. 

When the container can't find a dependency in the context it will return nil. It never use the global context to search for a implementation.

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
    
- **NoPublisherFounded**: 
    - When no publisher of a given abstraction could be found into the container.
    
- **NoImplementationFoundForPublish**: 
    - When in the attempt to publish a new implementation of a given abstraction based on the current dependency key no implementation could be found into the implementations container.

- **EqualDependecyKeyOnUpdate**:
    - When in the attempt to update the default dependency key of a specific abstraction the key thats already stored is equal to the new key.

## Injection types

Defines how all the implementations that will be injected are going to be created and returned.

- **regular**:
    - Every injection will create a new instance of the given implementation when this case is selected.
    
- **singleton**:
    - Every injection will get an already stored instance of the given implementation when this case is selected.
    - When is the first injection, will create, store and return a new instance of the given implementation.
    
## Instantiation types

Defines the moment of instantiation of an injected implementation.

- **regular**:
    - The implementation will be instantiate at the creation of the property wrapper.
    
- **lazy**:
    - The implementation will not be instantiate until it's required for the first time.

## License

MIT license. See the [LICENSE file](LICENSE) for details.
