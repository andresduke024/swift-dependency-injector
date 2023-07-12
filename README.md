# swift-dependency-injector

[![Swift](https://img.shields.io/badge/Swift-5.4_5.5_5.6_5.7_5.8-blue?style=flat-square)](https://img.shields.io/badge/Swift-5.4_5.5_5.6_5.7_5.8-blue?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)


A native dependency container written in swift that manages the initialization, store, and injection of the dependencies of a given abstraction fast and safety

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding swift-dependency-injector as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/andresduke024/swift-dependency-injector.git", .upToNextMajor(from: "1.0.1"))
]
```

## Usage example

First, define a protocol. For this example we are going to use a Repository protocol that has the job to fetch some data.

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

Notice that both classes implements the Injectable Dependency protocol too. This protocol defines a default property that give us a contract to access to an instance of the class. We are going to use this property later.

We can define an enum to identify the types of **Repository** that we are going to use in our app, but this is optional.


```swift
enum RepositoryType: String {
    case local
    case remote
}
```

Third, now we have to register this dependencies into to the container in order to be able to use them later as injectables values.

To achive this we are going to use the Injector class. This is a middleware that provide us with all the functions that we can use to access to the dependencies container.

```swift
Injector.register(Repository.self, defaultDependency: RepositoryType.remote.rawValue, implementations: [
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
        Injector.register(Repository.self, defaultDependency: RepositoryType.remote.rawValue, implementations: [
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

Now that we have all the dependencies registered into the container we can start using them in other classes as injectables and abstract properties.

For that we are going to create a DummyService. This class is going to have one property of type **Repository**. This property is going to be wrapped by a custom property wrapper named **@Injectable**.

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
The second thing to note is that the property must be marked as an optional data type. The latter because in case the container is not able to find an implementation to inject it will return a nil.

And that's all, by this point we can replicate this steps for every dependency we want to make injectable and start to using them all around in our project.

### Tests

We can easily mock our injected dependencies to make tests more efficient and reliable.


```swift
class RepositoryMock: Repository, InjectableDependency {
    required init() {}

    func fetch() -> [Int] { [1,2,3,4] }
}
```

The only thing we have to do now is register the mock dependency in our test file.

```swift
final class ServiceTest: XCTestCase {
    private var sut: Service!
    
    override func setUp() {
        Injector.register(Repository.self, implementation: RepositoryMock.instance)
        sut = DummyService()
    }
    
    override func tearDown() {
        Injector.clear()
        sut = nil
    }
    
    func testFetchDataSuccess() throws {
        let expected = [1,2,3,4]
        
        RepositoryMock.shouldSucced = true
        let result = sut.getData()
        
        XCTAssertEqual(result, expected)
    }
}
```

---
**NOTE**

Demo project. See the [demo](/Sources/swift-dependency-injector/demo) folder inside the repository's files for a more complex example.

---

## Docs
## Injector 

This a class which works as a middleware that provide us with all the functions that we can use to access to the dependencies container.

### Functions
---

#### Injector.register

To register into the dependencies container a new abstraction and its corresponding implementations

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency
- **defaultDependency**: The key to identify the implementation that is going to be injected
- **implementations**: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )

```swift
func register<Abstraction>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> Abstraction?]) {}
```
---

#### Injector.register

To register into the dependencies container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction)

**Parameters**:

- **abstraction**: Generic type. The protocol to register as dependency
- **implementation**: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )

```swift
func register<Abstraction>(_ abstraction: Abstraction.Type, implementation: @escaping () -> Abstraction?) {}
```
---

#### Injector.updateDependencyKey

To change the default implementation injected for a given abstraction by changing the key used in the container

**Parameters**:

- **abstraction**: Generic type. The protocol (already registered) to the one we want to change the injected implementation
- **newKey**: A unique key that identifies the new implementation that is going to be injected by default

```swift
func updateDependencyKey<Abstraction>(of abstraction: Abstraction.Type, newKey: String) {}
```
---

#### Injector.resetSingleton

To reset a specific or all the instances of a singleton dependency stored in the container

**Parameters**:

- **abstraction**: Generic type. The protocol (already registered) to the one we want to reset the implementation or implementations used as singletons
- **key**: A unique key that identifies the specific implementation that is going to be reseted. Nil if we want to reset all the implementations registered for the given abstraction

```swift
func resetSingleton<Abstraction>(of abstraction: Abstraction.Type, key: String? = nil) {}
```
---

#### Injector.remove

To remove all the registed implementations of a given abstraction and the abstraction itself

**Parameters**:

- **abstraction**: Generic type. The protocol that was registered as dependency

```swift
func remove<Abstraction>(_ abstraction: Abstraction.Type) {}
```
---

#### Injector.clear

To remove all the registered abstractions and implementations

```swift
func clear() {}
```
---

#### Injector.turnOffLogger

To turn off all the information messages logged by the injector ( It don't affect the error messages )

```swift
func turnOffLogger() {}
```
---

#### Injector.turnOnLogger

To turn on all the information messages logged by the injector ( It don't affect the error messages )

```swift
func turnOnLogger() {}
```
---

## @Injectable

The property wrapper used to mark a property as an injectable dependency.
It use a generic value to define the abstraction that encapsulates the injected implemententations.

All the dependencies injected by using this property wrapper has two different ways of be instantiate.

- **regular**: 
    - Every injection is going to create a new instance of the given implementation.
- **singleton**: 
    - Every injection is going to get an already stored instance of the given implementation.
    - When is the first injection, its going to create, store and return a new instance of the given implementation.
    
**regular** is the default injection type, what it means that it doesn't need to be specified when we use the wrapper.

To use **regular** injection type:

```swift
@Injectable private var repository: Repository?
```
or

```swift
@Injectable(.regular) private var repository: Repository?
```

And to use **singleton** injection type:

```swift
@Injectable(.singleton) private var repository: Repository?
```

#### Wrapped value

When we use the wrapped value of the property wrapper we are going to obtain the implementation injected in the base class when it was initialized.

This means that this value it's going to be instantiate once per class, unless it was injected as a singleton, and we always going to obtain the same object.

This is the regular implementation and its the mostly used.

```swift
func getData() -> [Int] {
    repository?.fetch() ?? []
}
```

#### Projected value

When we use the projected value of the property wrapper we are going to obtain a new implementation every time we try to obtain the value of the dependency.

This means that this value it's going to be instantiate once per call and we always going to obtain a new object.

To achieve this we only have to use the '**$**' sign in every call.


```swift
func getData() -> [Int] {
    $repository?.fetch() ?? []
}
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

When the default dependencies key changes all the injectable properties that are using the projected value are going to start using the new implementation.

And we can do this all the times we want and the implementations are going to change immediately.

---
**NOTES**

- It is important to note that when we update the default value of a key for a specific dependency, it has to match one of the keys we registered when saving the dependencies in the container.
- This works for singleton dependencies too. We change the injected value but in this case is not going to be a new instance but a previous stored singleton instance of the new defined implementation.
---

## License

MIT license. See the [LICENSE file](LICENSE) for details.
