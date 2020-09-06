//
//  Constants.swift
//  PersonsList
//
//  Created by Alex Yatsenko on 31.07.2020.
//  Copyright © 2020 Alexislog's Production. All rights reserved.
//

import Foundation

enum Cell {
    static let id = "Cell"
}

enum AlertTitle: String {
    case fetch
    case save
    case delete
    case edit
    
    var title: String {
        return "Failed to \(self.rawValue)"
    }
    
    static let add = "Add Person"
    static let change = "Change name"
    static let enterName = "Please enter person's name"
}

