//
//  RegularDependencyWrapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation

/// Manage the lifecycle of an Abstraction that will be injected using the @Injectable/@Inject property wrapper.
final class RegularDependencyWrapper<Abstraction>: DependencyWrapper<Abstraction> {

    /// To define the type of injection that we will use when try to get an implementation from the container.
    let injectionType: InjectionType

    /// To define at which point the implementation will be instantiated.
    private let instantiationType: InstantiationType

    init(args: DependencyWrapperArgs) {
        self.injectionType = args.injectionType
        self.instantiationType = args.instantiationType
        super.init(args.file, args.line, args.context, constrainedTo: args.key)
        manageOnInitInstantiation()
    }

    /// To manage and define the way and the moment at the implementation has to be instantiated.
    /// Defines if a new implementation has to be stored in the 'value' property at the initialization of the this class or later.
    private func manageOnInitInstantiation() {
        if instantiationType == .lazy {
            let file = Utils.extractFileName(of: filePath, withExtension: true)
            let abstractionName = Utils.createName(for: Abstraction.self)
            Logger.log("\(abstractionName) injected as 'lazy' in \(file) at line \(line) is waiting to first call to be instantiate")
            return
        }

        value = DependenciesContainer.global.get(context).get(with: injectionType, key: constraintKey)
        checkInjectionError()
    }

    /// **Override** A facade function used to perform all the validations and processes required before obtain an injected implementation.
    /// Validate if the implementation is not injected yet and will request an injection if is necessary.
    /// - Returns: An optional implementation of the given abstraction.
    override func unwrapValue() -> Abstraction? {
        if value == nil, instantiationType == .lazy {
            value = DependenciesContainer.global.get(context).get(with: injectionType, key: constraintKey)
        }

        checkInjectionError()
        return value
    }
}
