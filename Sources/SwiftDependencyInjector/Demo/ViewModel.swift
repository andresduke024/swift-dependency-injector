//
//  ViewModel.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

class ViewModel {
    @Inject
    private var service: Service

    @Inject(injection: .singleton)
    private var networkManager: NetworkManager

    var data: [Int] = []

    func loadData() {
        networkManager.validateConnection()
        data = service.getData()
    }
}
