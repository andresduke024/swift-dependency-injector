//
//  DependencyWrapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation

/// Class used to encapsulate the common behavior of a dependency wrapper.
final class DependencyWrapper<Abstraction: Sendable>: Sendable {

    /// The name of the file where the wrapped implementation is being used.
    let filePath: String

    /// The specific line of the file where the wrapped implementation is being used.
    let line: Int

    /// To store the current injected implementation.
    let value: Abstraction?

    /// To store the dependency specific key in case if needs it
    let constraintKey: String?

    /// To store the dependency specific context in case if needs it
    let context: InjectionContext
    
    /// To define the type of injection that we will use when try to get an implementation from the container.
    let injectionType: InjectionType

    private init(
        _ filePath: String,
        _ line: Int,
        _ context: InjectionContext,
        _ injectionType: InjectionType,
        constrainedTo key: String? = nil
    ) {
        self.filePath = filePath
        self.line = line
        self.context = context
        self.injectionType = injectionType
        self.constraintKey = key
        self.value = DependenciesContainer.global.get(context).get(with: injectionType, key: key)
    }
    
    convenience init(args: DependencyWrapperArgs) {
        self.init(
            args.file,
            args.line,
            args.context,
            args.injectionType,
            constrainedTo: args.key
        )
        
        checkInjectionError()
    }

    /// A facade function  used to perform all the validations and processes required before obtain an injected implementation.
    /// - Returns: An optional implementation of the given abstraction.
    func unwrapValue() -> Abstraction? { value }

    /// To validate if an injection was completed successfully
    private func checkInjectionError() {
        guard value == nil else { return }

        let abstractionName = Utils.createName(for: Abstraction.self)
        let fileLocation = "\(filePath) \(line)"
        let error: InjectionErrors = .noImplementationFoundOnInjection(abstractionName, file: fileLocation)
        Logger.log(error)
    }
}
