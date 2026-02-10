//
//  ObjectTypeValidator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 30/01/26.
//

import SwiftSyntax

/// Validates that a macro is applied to a supported object type.
///
/// `ObjectTypeValidator` conforms to `MacroValidator` and checks whether the
/// provided declaration is one of the supported Swift object types:
/// - `struct` (`StructDeclSyntax`)
/// - `class` (`ClassDeclSyntax`)
/// - `actor` (`ActorDeclSyntax`)
///
/// Use this validator when your macro should only be attachable to concrete
/// type declarations (and not, for example, to enums, protocols, functions,
/// or variables).
///
/// Behavior:
/// - Returns `true` when the `arguments.declaration` is a `StructDeclSyntax`,
///   `ClassDeclSyntax`, or `ActorDeclSyntax`.
/// - Returns `false` for all other declaration kinds.
///
/// Dependencies:
/// - Relies on SwiftSyntax to perform syntactic checks against the declaration.
/// - Requires a `MacroArguments` instance that exposes the `declaration` being validated.
///
/// Example:
/// If a macro should only be used on types like:
/// ```swift
/// struct MyService { }
/// class Repository { }
/// actor Cache { }
/// ```
/// `ObjectTypeValidator` will allow these, while rejecting enums, protocols,
/// extensions, and other non-object declarations.
///
/// Notes:
/// - This validator performs a syntactic check only; it does not analyze semantic
///   information such as inheritance, generics, or access control.
/// - Ensure `MacroArguments.declaration` is correctly populated by the macro
///   expansion context before invoking validation.
struct ObjectTypeValidator: MacroValidator {
    func validate(
        for arguments: MacroArguments
    ) -> Bool {
        let declaration = arguments.declaration
        
        return declaration.is(StructDeclSyntax.self)
            || declaration.is(ClassDeclSyntax.self)
            || declaration.is(ActorDeclSyntax.self)
    }
}
