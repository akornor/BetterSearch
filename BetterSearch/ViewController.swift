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
    
    func reloadData(){
        tableView.reloadData()
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let query = searchField.stringValue
        for row in try! (DataStore.shared.db?.run("select * from message where text like '%\(query)%' limit 10"))!{
            searchResults.append((row[2] as? String)!)
            reloadData()
        }
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        searchResults = []
        reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = searchResults[row]
            return cell
        }
        return nil
    }
}
