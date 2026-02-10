//
//  ExtensionMacroCreatorFactory.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

/// A factory responsible for creating concrete macro creator instances for extension-based macros.
///
/// ExtensionMacroCreatorFactory centralizes the instantiation of types conforming to `ExtensionMacroCreator`
/// based on a requested `ExtensionMacros` case and its associated `ExtensionMacroArguments`.
/// This keeps construction logic in a single place, making it easier to add new extension macros
/// and ensuring consistent initialization across the codebase.
///
/// Usage:
/// - Call `get(for:with:)` with the desired macro kind and its arguments.
/// - The factory returns a type-erased (`any`) `ExtensionMacroCreator` ready to generate the macro expansion.
///
/// Responsibilities:
/// - Map high-level macro identifiers (from `ExtensionMacros`) to their corresponding creator types
///   (e.g., `InjectableDependencyMacroCreator`, `DependenciesInjectorMacroCreator`).
/// - Provide the correct initialization parameters (`ExtensionMacroArguments`) to each creator.
///
/// Extensibility:
/// - To support a new extension macro, add a new case to `ExtensionMacros`,
///   implement a corresponding `ExtensionMacroCreator`, and extend the switch in `get(for:with:)`.
///
/// Thread-safety:
/// - The factory is stateless; calls to `get(for:with:)` are safe to make from any thread,
///   assuming the provided arguments are themselves thread-safe.
///
/// - Parameters:
///   - macro: The kind of extension macro to create, defined by `ExtensionMacros`.
///   - arguments: The arguments required to configure the macro creator.
/// - Returns: An instance conforming to `ExtensionMacroCreator` capable of generating the requested macro expansion.
/// - SeeAlso: `ExtensionMacros`, `ExtensionMacroCreator`, `ExtensionMacroArguments`, `InjectableDependencyMacroCreator`, `DependenciesInjectorMacroCreator`
struct ExtensionMacroCreatorFactory {
    static func get(
        for macro: ExtensionMacros,
        with arguments: ExtensionMacroArguments
    ) -> any ExtensionMacroCreator {
        switch macro {
        case .injectableDependency:
            InjectableDependencyMacroCreator(arguments: arguments)
        case .dependenciesInjector:
            DependenciesInjectorMacroCreator(arguments: arguments)
        }
    }
}

