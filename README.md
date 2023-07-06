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
    .package(url: "https://github.com/andresduke024/swift-dependency-injector.git", .upToNextMajor(from: "1.0.0"))
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
class DummyService: Service, InjectableDependency {
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
