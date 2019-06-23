//
//  ViewController.swift
//  BetterSearch
//
//  Created by Raymond Akornor on 6/22/19.
//  Copyright © 2019 FiniteLoop. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSSearchFieldDelegate, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    
    var searchResults = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        for row in try! (DataStore.shared.db?.run("select * from message where text like '%\(query)%' limit 10"))!{
            print(row[2] as Any)
            searchResults.append((row[2] as? String)!)
        }
        print("clicked")
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        print("end searching")
        print(searchField.stringValue)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = searchResults[row]
            print(cell)
            return cell
        }
        return nil
    }
}
