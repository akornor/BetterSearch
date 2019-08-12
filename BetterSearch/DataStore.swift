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
        var dbPath: URL
        if (!development){
            let fileManager = FileManager.default
            dbPath = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("/Library/Messages/chat.db")
        }else{
            guard let url = Bundle.main.url(forResource: "chat", withExtension: "db") else{
                fatalError("Unable to find database file.")
            }
            dbPath = url
        }
        do {
            db = try Connection(dbPath.absoluteString)
        } catch let error {
            print(error.localizedDescription)
            fatalError("Unable to make connection to database")
        }
    }
    
    public func search(for query: String) throws -> Statement {
        return try! (db?.run("SELECT text, date, id FROM MessageSearch JOIN handle ON handle.ROWID=MessageSearch.handle_id  WHERE text MATCH '\(query)' ORDER BY rank"))!
    }
}
