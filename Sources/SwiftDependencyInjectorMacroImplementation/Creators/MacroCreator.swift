//
//  MacroCreator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A protocol that defines the common interface for building and validating Swift macros.
///
/// `MacroCreator` abstracts the lifecycle required to implement a macro, including argument
/// handling, validation, and diagnostics. Conforming types specify the type of their arguments
/// via the associated type `T`, which must conform to `MacroArguments`.
///
/// Conformers are expected to:
/// - Store and work with parsed macro arguments.
/// - Perform validation of macro usage and report diagnostics as needed.
/// - Optionally apply reusable validators through `applyValidators(_:)`.
///
/// Requirements:
/// - `associatedtype T: MacroArguments`: The concrete type that encapsulates the macro’s
///   parsed arguments, syntax node, declaration context, protocol conformances, and expansion context.
/// - `var arguments: T { get set }`: The instance of parsed arguments used by the macro.
/// - `init(arguments: T)`: Initializer to create the macro creator with parsed arguments.
/// - `func validate() throws -> Bool`: Performs macro-specific validation. Returns `true` if
///   valid; throws or returns `false` if invalid.
/// - `func diagnose(message: BaseDiagnosticMessage)`: Emits a diagnostic message tied to the
///   macro’s attribute node.
/// - `func applyValidators(_ validators: [MacroValidatorData]) -> Bool`: Applies a collection
///   of validators and returns `true` only if all validators pass.
///
/// Default behavior provided by the extension:
/// - `node`: Convenience access to the macro attribute `AttributeSyntax`.
/// - `declaration`: Access to the enclosing declaration (`DeclGroupSyntax`) where the macro is applied.
/// - `protocols`: Any protocols parsed from the macro arguments (if applicable).
/// - `context`: The `MacroExpansionContext` used for emitting diagnostics and managing expansion state.
/// - `diagnose(message:)`: Constructs and emits a `Diagnostic` using the provided message.
/// - `applyValidators(_:)`: Iterates through provided validators, short-circuiting on first failure,
///   and automatically emits diagnostics for failed validations.
///
/// Usage Notes:
/// - Implement `validate()` to perform macro-specific checks. Consider leveraging `applyValidators(_:)`
///   for reusable validation logic.
/// - Use `diagnose(message:)` to surface user-facing errors or warnings tied to the macro attribute.
/// - The `arguments` should be pre-parsed and validated enough to allow `validate()` to run meaningfully.
///
/// Thread-safety:
/// - Conformers should assume they may be used during compile-time macro expansion and should avoid
///   shared mutable state unless properly synchronized.
///
/// Error handling:
/// - `validate()` can throw when encountering unrecoverable issues; otherwise, return `false` to indicate
///   validation failure after emitting diagnostics.
protocol MacroCreator {
    associatedtype T: MacroArguments
    
    var arguments: T { get set }
    
    init(arguments: T)
    
    func validate() throws -> Bool
    
    func diagnose(message: BaseDiagnosticMessage)
    
    func applyValidators(_ validators: [MacroValidatorData]) -> Bool
}

extension MacroCreator {
    
    var node: AttributeSyntax { arguments.node }
    
    var declaration: DeclGroupSyntax { arguments.declaration }
    
    var protocols: [TypeSyntax] { arguments.protocols }
    
    var context: MacroExpansionContext { arguments.context }
        
    func diagnose(message: BaseDiagnosticMessage) {
        let diagnostic = Diagnostic(
            node: arguments.node,
            message: message
        )
        
        arguments.context.diagnose(diagnostic)
    }
    
    func applyValidators(_ validators: [MacroValidatorData]) -> Bool {
        for item in validators {
            if applyValidator(item) { continue }
            
            return false
        }
        
        return true
    }
    
    private func applyValidator(_ data: MacroValidatorData) -> Bool {
        let result = MacroValidatorFactory
            .get(data.type)
            .validate(for: arguments)
        
        if result { return true }
        
        diagnose(message: data.message)
        return false
    }
}
