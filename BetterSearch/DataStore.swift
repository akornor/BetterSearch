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
    var dbPath: URL
    
    init() {
        if (!development){
            func realHomeDirectory() -> URL? {
                guard let pw = getpwuid(getuid()) else { return nil }
                return URL(fileURLWithFileSystemRepresentation: pw.pointee.pw_dir, isDirectory: true, relativeTo: nil)
            }
            guard let url = realHomeDirectory() else{
                fatalError("Unable to get users home directory.")
            }
            dbPath = url.appendingPathComponent("/Library/Messages/chat.db")
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
            let alert = NSAlert()
            alert.messageText = "Unable to make connection to database."
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .informational
            alert.runModal()
            fatalError("Unable to make connection to database")
        }
    }
    
    public func search(for query: String) throws -> Statement {
        return try! (db?.run("SELECT text, date, id FROM MessageSearch JOIN handle ON handle.ROWID=MessageSearch.handle_id  WHERE text MATCH '\(query)' ORDER BY rank"))!
    }
}
