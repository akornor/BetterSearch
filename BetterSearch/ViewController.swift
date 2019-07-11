//
//  ViewController.swift
//  BetterSearch
//
//  Created by Raymond Akornor on 6/22/19.
//  Copyright © 2019 FiniteLoop. All rights reserved.
//

import Cocoa
import Contacts

class ViewController: NSViewController, NSSearchFieldDelegate, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    
    var searchResults = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.rowHeight = 35.0
        tableView.usesAlternatingRowBackgroundColors = true
        reloadData()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func clearSearchResults(){
        searchResults = []
        reloadData()
    }
    
    @IBAction func search(_ sender: Any) {
        clearSearchResults()
        let query = searchField.stringValue
        if query.isEmpty {
            return
        }
        for row in try! (DataStore.shared.db?.run("select text, date, id from message join handle on handle.ROWID = message.handle_id where text like '%\(query)%' limit 60"))!{
            let text = (row[0] as? String)!
            let date = (row[1] as? Int64)!
            let id = (row[2] as? String)!
            let message = Message(text: text, date: date, id: id)
            searchResults.append(message)
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
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as? MessageCellView else{
            fatalError("Unable to find table view cell.")
        }
        let message = searchResults[row]
        let query = searchField.stringValue
        if let id = message.id {
            cell.numberTextField.stringValue = id
        }
        if let text = message.text {
            cell.detailedTextField?.attributedStringValue = boldedString(with: text, searchString: query, fontSize: 13)!
        }
        return cell
}
}

extension ViewController{
    static func getViewController() -> ViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else{
            fatalError("Unable to find ViewController in the storyboard.")
        }
        return vc
    }
}
