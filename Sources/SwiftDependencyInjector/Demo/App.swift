//
//  App.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

class App {
    init() {
        ApplicationSetup.shared.startInjection()
    }

    func main() async -> [Int] {
        let viewModel = ViewModel()
        await viewModel.loadData()
        print("The data was loaded \(viewModel.data)")
        return viewModel.data
    }
}
