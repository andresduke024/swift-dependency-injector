//
//  MacroCreatorFactory.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

struct MacroCreatorFactory {
    static func get(
        for macro: Macros,
        with arguments: MacroArguments
    ) -> MacroCreator {
        switch macro {
        case .injectedConstructor:
            InjectedConstructorMacroCreator(arguments: arguments)
        }
    }
}
