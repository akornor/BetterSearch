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
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        reloadData()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func clearSearchResults(){
        searchResults = []
    }
    
    @IBAction func search(_ sender: Any) {
        clearSearchResults()
        let query = searchField.stringValue
        if query.isEmpty {
            return
        }
        for row in try! (DataStore.shared.db?.run("select * from message where text like '%\(query)%' limit 20"))!{
            searchResults.append((row[2] as? String)!)
            reloadData()
        }
    }
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        print("double clicked")
    }

    
    func reloadData(){
        tableView.reloadData()
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        clearSearchResults()
        reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return searchResults.count
    }
    
    private func boldedString(with baseString: String, searchString: String, fontSize: CGFloat) -> NSAttributedString? {
        guard let regex = try? NSRegularExpression(pattern: searchString, options: .caseInsensitive) else {
            return nil
        }
        
        let attributedString = NSMutableAttributedString(string: baseString)
        let boldFont = NSFont.systemFont(ofSize: fontSize, weight: .bold)
        regex
            .matches(in: baseString, options: .withTransparentBounds,
                     range: NSRange(location: 0, length: baseString.utf16.count))
            .forEach {
                attributedString.addAttributes([.font: boldFont], range: $0.range)
        }
        return attributedString
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as? NSTableCellView else{
            fatalError("Unable to find table view cell.")
        }
        let text = searchResults[row]
        let query = searchField.stringValue
        cell.textField?.attributedStringValue = boldedString(with: text, searchString: query, fontSize: 13)!
        return cell
}
}
