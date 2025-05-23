//
//  DependenciesManager.swift
//  
//
//  Created by Andres Duque on 15/07/23.
//

import Foundation

/// This class manage all the injection, registration and updating functionalities used in the processes related with abstractions and implementations.
final class DependenciesManager: DependenciesManagerProtocol {

    /// To wrapp the definition of a closure that provides the abstraction name as String and the real registration type.
    typealias GenerateContextCompletion = (_ abstractionName: String, _ registrationType: RegistrationType) -> Void

    /// To perform validation about the current target
    private let targetValidator: TargetValidatorProtocol

    private let context: InjectionContext

    init(
        targetValidator: TargetValidatorProtocol,
        context: InjectionContext
    ) {
        self.targetValidator = targetValidator
        self.context = context
    }

    /// To store al the abstractions and its corresponding implementations wrapped inside of a 'ImplementationsContainer' class.
    /// The key used to idenfies each one its the abstraction's data type parsed as string.
    let container = ConcurrencySafeStorage<ImplementationsContainer>()

    /// To register into the container a new abstraction and its corresponding implementations.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - defaultDependency: The key to identify the implementation that will be injected.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func register<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        defaultDependency: String,
        implementations: [String: @Sendable () -> Abstraction?]
    ) {
        set(abstraction, registrationType: .create, key: defaultDependency, implementations: implementations)
    }

    /// To register into the container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction).
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func register<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        key: String,
        implementation initializer: @Sendable @escaping () -> Abstraction?
    ) {
        set(abstraction, registrationType: .create, key: key, implementation: initializer)
    }

    /// To add into the container a new set of implementations of an already registered abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func add<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        implementations: [String: @Sendable () -> Abstraction?]
    ) {
        set(abstraction, registrationType: .update, implementations: implementations)
    }

    /// To add into the container a new implementation of an already registered abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - initializer: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func add<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        key: String,
        implementation initializer: @Sendable @escaping () -> Abstraction?
    ) {
        set(abstraction, registrationType: .update, key: key, implementation: initializer)
    }

    /// To register or update into the container a new abstraction and its corresponding implementations.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - registrationType: To know if the abstraction is trying to be register as new or is already registered and has to be updated.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    private func set<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        registrationType: RegistrationType,
        key: String = "",
        implementations: [String: @Sendable () -> Abstraction?]
    ) {
        let mappedImplementations = InitializersContainerMapper.map(implementations)
        store(abstraction, registrationType, key, mappedImplementations)
    }

    /// To register or update into the container a new abstraction and its corresponding implementation.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - registrationType: To know if the abstraction is trying to be register as new or is already registered and has to be updated.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - initializer: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    private func set<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        registrationType: RegistrationType,
        key: String = "",
        implementation initializer: @Sendable @escaping () -> Abstraction?
    ) {
        let mappedImplementations = InitializersContainerMapper.map(key, initializer)
        store(abstraction, registrationType, key, mappedImplementations)
    }

    /// To register or update into the container a new abstraction and its corresponding implementations. Only when implementations are already mapped to the generic initializer type.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - registrationType: To know if the abstraction is trying to be register as new or is already registered and has to be updated.
    ///   - defaultDependencyKey: The key to identify the implementation that will be injected.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation.
    private func store<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        _ registrationType: RegistrationType,
        _ defaultDependencyKey: String,
        _ implementations: InitializersContainer
    ) {
        createRegistrationContext(abstraction: abstraction, initialRegistrationType: registrationType) { abstractionName, registrationType in
            saveDependencies(abstractionName: abstractionName, key: defaultDependencyKey, implementations: implementations, registrationType)
        }
    }

    /// To obtain the abstraction name and the registration type that will be used to store it into the container.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - initialRegistrationType: The original registration type. Depends it the user is trying to update or register abstractions.
    ///   - completion: A closure that provides the abstraction name as String and the real registration type.
    private func createRegistrationContext<Abstraction: Sendable>(
        abstraction: Abstraction.Type,
        initialRegistrationType: RegistrationType,
        completion: GenerateContextCompletion
    ) {
        let abstractionName = Utils.createName(for: abstraction)

        guard !targetValidator.isRunningOnTestTarget else {
            completion(abstractionName, .updateOrCreate)
            return
        }

        if initialRegistrationType == .update {
            completion(abstractionName, .update)
            return
        }

        validateNewAbstraction(initialRegistrationType, abstractionName, completion: completion)
    }

    /// To validate if the given abstraction is trying to be registered as new and isn't already store into the container.
    /// - Parameters:
    ///   - abstractionName: The name (identifier) of the given abstraction.
    ///   - registrationType: To validate if abstraction is trying to be registered as new.
    ///   - completion: A closure that provides the abstraction name as String and the real registration type.
    private func validateNewAbstraction(
        _ registrationType: RegistrationType,
        _ abstractionName: String,
        completion: GenerateContextCompletion
    ) {
        guard registrationType == .create else {
            Logger.log(.undefinedRegistrationType(abstractionName))
            return
        }

        guard container.get(key: abstractionName) == nil else {
            Logger.log(.abstractionAlreadyRegistered(abstractionName, context))
            return
        }

        completion(abstractionName, .create)
    }

    /// To handle the registration of the new dependencies based on the provided registration type.
    /// - Parameters:
    ///   - abstractionName: The name (identifier) of the given abstraction.
    ///   - key: The key that identifies the implementation that will be injected by default.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    ///   - registrationType: An enum value to know the kind of registration to perform.
    private func saveDependencies(
        abstractionName: String,
        key: String = "",
        implementations: InitializersContainer,
        _ registrationType: RegistrationType
    ) {
        switch registrationType {
        case .create:
            create(abstractionName: abstractionName, key: key, implementations: implementations)
        case .update:
            update(abstractionName: abstractionName, implementations: implementations)
        case .updateOrCreate:
            updateOrCreate(abstractionName: abstractionName, key: key, implementations: implementations)
        }
    }

    /// To update an already stored abstraction and its new corresponding implementations into the container.
    /// - Parameters:
    ///   - abstractionName: The name (identifier) of the given abstraction.
    ///   - key: The key that identifies the implementation that will be injected by default.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    private func update(
        abstractionName: String,
        implementations: InitializersContainer
    ) {
        guard let implementationsContainer = container.get(key: abstractionName) else {
            Logger.log(.abstractionNotFoundForUpdate(abstractionName))
            return
        }

        let newImplementationsContainer = implementationsContainer.copyWith(implementations: implementations)
        container.set(key: abstractionName, newImplementationsContainer)

        let successUpdateMessage = "'\(abstractionName)' abstraction updated succesfully with \(implementations.count) injectable implementations."
        let totalCountMessage = "\(newImplementationsContainer.count) Implementations registered in total"
        Logger.log("\(successUpdateMessage) \(totalCountMessage)")
    }

    /// To store an abstraction and its corresponding implementations into the container.
    /// - Parameters:
    ///   - abstractionName: The name (identifier) of the given abstraction.
    ///   - key: The key that identifies the implementation that will be injected by default.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    private func create(
        abstractionName: String,
        key: String,
        implementations: InitializersContainer
    ) {
        let implementationsContainer = ImplementationsContainer(
            abstraction: abstractionName,
            currentKey: key,
            implementations: implementations
        )
        
        container.set(key: abstractionName, implementationsContainer)

        Logger.log("'\(abstractionName)' abstraction registered succesfully with \(implementations.count) injectable implementations")
    }

    /// To store or update an abstraction and its corresponding implementations into the container (Useful when application runs on Tests Target).
    /// - Parameters:
    ///   - abstractionName: The name (identifier) of the given abstraction.
    ///   - key: The key that identifies the implementation that will be injected by default.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    private func updateOrCreate(
        abstractionName: String,
        key: String,
        implementations: InitializersContainer
    ) {
        if container.get(key: abstractionName) == nil {
            create(abstractionName: abstractionName, key: key, implementations: implementations)
            return
        }

        update(abstractionName: abstractionName, implementations: implementations)
    }

    /// To reset a specific or all the instances of a singleton dependency stored in the container.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to reset the implementation or implementations used as singletons.
    ///   - key: A unique key that identifies the specific implementation that will be reseted. Nil if we want to reset all the implementations registered for the given abstraction.
    func resetSingleton<Abstraction: Sendable>(
        of abstraction: Abstraction.Type,
        key: String? = nil
    ) {
        let abstractionName = Utils.createName(for: abstraction)
        guard let item = container.get(key: abstractionName) else {
            Logger.log(.notAbstrationFound(abstractionName, context: context))
            return
        }

        item.removeSingleton(key: key)
    }

    /// To extract a specific implementation from the container and make an upcasting to the abstraction data type.
    /// - Parameters:
    ///   - injectionType: An enum that defines if the implementations that will be injected is going to be extracted as a singleton or as a regular dependency (a new instance).
    ///   - key: To extract a implementation based on a specific key and ignoring the current one.
    /// - Returns: An implementation wrapped as the especific abstraction define in the generic type of the function or nil in case something goes wrong in the process.
    func get<Abstraction: Sendable>(
        with injectionType: InjectionType,
        key: String? = nil
    ) -> Abstraction? {
        let abstractionName = Utils.createName(for: Abstraction.self)
        guard let implementations = container.get(key: abstractionName) else {
            Logger.log(.notAbstrationFound(abstractionName, context: context))
            return nil
        }

        let result = implementations.get(with: injectionType, constraintKey: key)
        
        guard let implementation: Abstraction = AbstractionMapper.map(result) else {
            Logger.log(.implementationsCouldNotBeCasted(abstractionName))
            return nil
        }

        return implementation
    }

    /// To remove all the registed implementations of a given abstraction and the abstraction itself.
    /// - Parameter abstraction: Generic type. The protocol that was registered as dependency.
    func remove<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type
    ) {
        let abstractionName = Utils.createName(for: abstraction)
        container.removeValue(forKey: abstractionName)
        Logger.log("All registered implementations of '\(abstractionName)' abstraction were removed successfully from container")
    }

    /// To remove all the registered abstractions and implementations.
    func clear() {
        container.removeAll()
        Logger.log("All registered abstractions and implementations were removed successfully from container")
    }
}
