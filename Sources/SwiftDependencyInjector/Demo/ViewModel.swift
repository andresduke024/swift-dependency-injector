//
//  ViewModel.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
import SwiftDependencyInjectorMacros

@InjectedConstructor(
    Service.self,
    NetworkManager.self
)
class ViewModel {

    var data: [Int] = []

    func loadData() async {
        await networkManager.validateConnection()
        data = service.getData()
    }
}
