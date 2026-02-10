//
//  MemberMacroCreatorFactory.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 30/01/26.
//

/// A simple factory responsible for creating concrete `MemberMacroCreator` instances
/// based on the requested `MemberMacros` case and its associated arguments.
///
/// This factory centralizes the construction logic for member macro creators,
/// allowing callers to request a macro by type and receive an appropriate
/// creator configured with the provided arguments. It helps keep macro
/// initialization decoupled from call sites and encapsulates any branching
/// logic needed to select the correct creator.
///
/// Usage:
/// - Provide the desired `MemberMacros` case and corresponding `MemberMacroArguments`.
/// - Receive an instance conforming to `MemberMacroCreator` ready to generate
///   member-level macro expansions.
///
/// Notes:
/// - The factory currently supports:
///   - `.injectedConstructor`: Produces a creator that synthesizes an injected initializer.
///   - `.observableInjectedConstructor`: Produces a creator that synthesizes an injected
///     initializer suitable for observable types.
/// - Extend the `switch` in `get(for:with:)` to support new macro types as they are added.
///
/// Thread-safety:
/// - `get(for:with:)` performs no shared mutable state operations and is safe to call from
///   concurrent contexts if the provided arguments are themselves thread-safe.
///
/// - Parameters:
///   - macro: The member macro type indicating which creator to produce.
///   - arguments: The arguments required to configure the macro creator.
/// - Returns: An instance conforming to `MemberMacroCreator` appropriate for the given macro.
struct MemberMacroCreatorFactory {
    static func get(
        for macro: MemberMacros,
        with arguments: MemberMacroArguments
    ) -> any MemberMacroCreator {
        switch macro {
        case .injectedConstructor:
            InjectedConstructorMacroCreator(arguments: arguments)
        case .observableInjectedConstructor:
            ObservableInjectedConstructorMacroCreator(arguments: arguments)
        }
    }
}
