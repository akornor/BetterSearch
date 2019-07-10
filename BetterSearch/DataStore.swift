//
//  DataStore.swift
//  BetterSearch
//
//  Created by Raymond Akornor on 6/22/19.
//  Copyright © 2019 FiniteLoop. All rights reserved.
//

import Foundation
import SQLite

class DataStore{
    static let shared = DataStore()
    let db: Connection?
    
    init() {
        // Will change later
        guard let url = Bundle.main.url(forResource: "chat", withExtension: "db") else{
            fatalError("Unable to find database file.")
        }
        do {
            db = try Connection(url.absoluteString, readonly: true)
        } catch let error {
            print(error.localizedDescription)
            fatalError("Unabled to make connection to database")
        }
    }
}
