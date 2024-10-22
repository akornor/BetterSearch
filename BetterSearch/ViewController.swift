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

    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    
    var searchResults = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.rowHeight = 41.0
        tableView.usesAlternatingRowBackgroundColors = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func clearSearchResults(){
        if searchResults.isEmpty{
            return
        }
        searchResults = []
        reloadData()
    }
    
    @IBAction func search(_ sender: Any) {
        let query = searchField.stringValue
        if query.isEmpty {
            return
        }
        clearSearchResults()
        progressIndicator.startAnimation(sender)
        progressIndicator.display()
         // see: https://forums.developer.apple.com/message/74446
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.02))
        for row in try! DataStore.shared.search(for: query){
            if let text = row[0] as? String, let date = row[1] as? Int64, let id = row[2] as? String{
                let message = Message(text: text, date: date, id: id)
                searchResults.append(message)
            }
        }
        progressIndicator.stopAnimation(sender)
        if (!searchResults.isEmpty){
            reloadData()
        }

    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        let url = URL(fileURLWithPath: "messages://open?message-guid=9B078248-4068-48E5-A1E2-F31C98FDD1D2")
        NSWorkspace.shared.open(url)
        print("double clicked")
    }
    
    private func reloadData(){
        tableView.reloadData()
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        clearSearchResults()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return searchResults.count
    }
    
    private func boldenString(with baseString: String, searchString: String, fontSize: CGFloat) -> NSAttributedString? {
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
        if let id = message.id, let text = boldenString(with: message.text ?? "", searchString: query, fontSize: 13), let date = message.date {
            cell.messageTextField?.attributedStringValue = text
            cell.contactTextField?.stringValue = id
            cell.dateTextField?.stringValue = date.date()
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
