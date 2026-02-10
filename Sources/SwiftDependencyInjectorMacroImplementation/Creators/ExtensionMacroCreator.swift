//
//  ExtensionMacroCreator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 30/01/26.
//

import SwiftSyntax

/// A specialized macro creator protocol for generating Swift extension declarations.
/// 
/// Conforming types produce one or more `ExtensionDeclSyntax` nodes based on
/// parsed macro arguments that specifically describe an extension context.
/// 
/// Requirements:
/// - Inherits from `MacroCreator` with its generic `T` fixed to `ExtensionMacroArguments`,
///   ensuring the macro operates on extension-related inputs.
/// - Provides a `create()` method that returns the list of synthesized
///   `ExtensionDeclSyntax` declarations or throws if generation fails.
/// 
/// Default behavior:
/// - Supplies a convenience `type` property (via protocol extension) that exposes the
///   target `TypeSyntaxProtocol?` derived from the underlying `arguments`.
/// 
/// Usage:
/// - Implementors typically read `arguments` (from `MacroCreator`) to determine the
///   target type and any attributes/modifiers, then return the corresponding extensions
///   from `create()`.
/// 
/// Error handling:
/// - `create()` can throw to indicate invalid arguments or failed syntax construction,
///   allowing callers to surface macro diagnostics appropriately.
///
/// See also:
/// - `MacroCreator`
/// - `ExtensionMacroArguments`
/// - `ExtensionDeclSyntax`
protocol ExtensionMacroCreator: MacroCreator where T == ExtensionMacroArguments {
    func create() throws -> [ExtensionDeclSyntax]
}

extension ExtensionMacroCreator {
    var type: TypeSyntaxProtocol? { arguments.type }
}
