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
    
    public func indexMessages(){
        try! db?.execute("""
                CREATE VIRTUAL TABLE IF NOT EXISTS MessageSearch USING fts5(guid UNINDEXED, text, date UNINDEXED, handle_id UNINDEXED);
                INSERT INTO MessageSearch SELECT guid, text, date, handle_id FROM message;
                -- Triggers to keep the message index up to date.
                CREATE TRIGGER IF NOT EXISTS update_message_index AFTER INSERT ON message BEGIN
                  INSERT INTO MessageSearch(guid, text, date, handle_id) VALUES (new.guid, new.text, new.date, new.handle_id);
                END;
            """)
    }
}
