//
//  RegularDependencyWrapperArgs.swift
//  
//
//  Created by Andres Duque on 20/05/24.
//

import Foundation

struct DependencyWrapperArgs: Sendable {
    let injectionType: InjectionType
    let file: String
    let line: Int
    let context: InjectionContext
    let key: String?
    
    /// - Parameters:
    ///   - injectionType: To define the injection type used to instantiate the dependency.
    ///   - file: The name of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - context: To specific a special injection context to extract the implementation to inject from a isolated container.
    ///   - key: To constrain the injection to a specific key and ignore the key settled on the current context.
    init(
        injection injectionType: InjectionType = .regular,
        file: String = #file,
        line: Int = #line,
        context: InjectionContext = .global,
        constrainedTo key: String? = nil
    ) {
        self.injectionType = injectionType
        self.file = file
        self.line = line
        self.context = context
        self.key = key
    }
    
    /// To create a copy based on previous store values and new values (parameters).
    /// 
    /// - Parameters:
    ///   - injectionType: To define the injection type used to instantiate the dependency.
    ///   - instantiationType: To define at which point the implementation will be instantiated and injected.
    ///   - file: The name of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - context: To specific a special injection context to extract the implementation to inject from a isolated container.
    ///   - key: To constrain the injection to a specific key and ignore the key settled on the current context.
    func copy(
        injection injectionType: InjectionType? = nil,
        file: String? = nil,
        line: Int? = nil,
        context: InjectionContext? = nil,
        constrainedTo key: String? = nil
    ) -> DependencyWrapperArgs {
        DependencyWrapperArgs(
            injection: injectionType ?? self.injectionType,
            file: file ?? self.file,
            line: line ?? self.line,
            context: context ?? self.context,
            constrainedTo: key ?? self.key
        )
    }
}
