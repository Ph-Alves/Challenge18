//
//  HomeStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 21/10/26.
//

import Foundation
import SwiftUI

protocol HomeStoreProtocol: AnyObject {
    func displayCategory(groups: [Category])
}

@MainActor
@Observable
final class HomeStore: HomeStoreProtocol {
    private(set) var categories: [Category]?
    
    init() {}
    
    func displayCategory(groups: [Category]) {
        self.categories = groups
    }
}
