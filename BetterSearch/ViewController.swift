//
//  ViewController.swift
//  BetterSearch
//
//  Created by Raymond Akornor on 6/22/19.
//  Copyright © 2019 FiniteLoop. All rights reserved.
//

import Cocoa
import SQLite

class ViewController: NSViewController, NSSearchFieldDelegate {

    @IBOutlet weak var searchField: NSSearchField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
    }
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        print("start searching")
        print(searchField.stringValue)
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let query = searchField.stringValue
        do {
            for row in try! (DataStore.shared.db?.prepare("select * from message where text like '%\(query)%' limit 10"))!{
                print(row[2])
            }
        } catch{
            print("error")
        }
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        print("end searching")
        print(searchField.stringValue)
    }
    
    

}
