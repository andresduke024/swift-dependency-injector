//
//  De.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 29/01/26.
//

import SwiftSyntax

struct DependencyRegistration {
    let protocolType: TypeSyntax
    let key: ExprSyntax?
}
