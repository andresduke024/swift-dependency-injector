//
//  ImplementationsContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// This class is used to store the a set of implementation of a given type and exposed the methods to access to them.
final class ImplementationsContainer: Sendable {

    /// The name of the abstraction for which implementations will be stored in this container.
    private let abstractionName: String

    /// The key that identifies the implementation that will be injected in every injection attempt.
    private let currentKey: String

    /// To store the builder of each implementation.
    private let implementations: InitializersContainer

    /// To store the implementations that were requested to inject as singletons.
    private let singletons: ConcurrencySafeStorage<Sendable>

    /// To get the current amount of stored implementations.
    var count: Int { implementations.count }

    convenience init(
        abstraction: String,
        currentKey: String,
        implementations: InitializersContainer
    ) {
        self.init(
            abstraction: abstraction,
            currentKey: currentKey,
            implementations: implementations,
            singletonsContainer: ConcurrencySafeStorage()
        )
    }

    private init(
        abstraction: String,
        currentKey: String,
        implementations: InitializersContainer,
        singletonsContainer: ConcurrencySafeStorage<Sendable>
    ) {
        self.abstractionName = abstraction
        self.currentKey = currentKey
        self.implementations = implementations
        self.singletons = singletonsContainer
    }

    /// To get an instance of specific implementation base on the stored current key.
    /// - Parameter injectionType: An enum that defines if the instance of the implementation will be a new instance or an already created and stored instance.
    /// - Returns: An instance of the specific implementation.
    func get(
        with injectionType: InjectionType,
        constraintKey: String? = nil
    ) -> Sendable? {
        let key = constraintKey ?? currentKey

        if injectionType == .regular {
            return implementations.get(key: key)?()
        }

        if let singletonImpl = singletons.get(key: key) {
            return singletonImpl
        }

        let implementation = implementations.get(key: key)?()
        
        if let implementation {
            singletons.set(key: key, implementation)
        }
        
        return implementation
    }

    /// To remove an already created an stored instance from the singletons dictionary.
    /// - Parameter key: A key to identify the the instance that will be removed.
    func removeSingleton(key: String?) {
        if let key {
            singletons.removeValue(forKey: key)
            Logger.log("All singletons instances with key '\(key)' removed successfully for implementations of '\(abstractionName)'")
            return
        }

        singletons.removeAll()
        Logger.log("All singletons instances removed successfully for implementations of '\(abstractionName)'")
    }

    /// To build a copy of the current instance by adding new values to its attributes.
    /// - Parameters:
    ///   - currentKey: The key to identify the default implementation to be injected. If is nil will use the already saved key.
    ///   - implementations: The implementations to add/replace into the already stored container.
    /// - Returns: A new instances of itself.
    func copyWith(
        currentKey: String? = nil,
        implementations: InitializersContainer
    ) -> ImplementationsContainer {
        let newContainer = self.implementations
        implementations.forEach { newContainer.set(key: $0, $1) }
        
        return ImplementationsContainer(
            abstraction: self.abstractionName,
            currentKey: currentKey ?? self.currentKey,
            implementations: newContainer,
            singletonsContainer: self.singletons
        )
    }
}
