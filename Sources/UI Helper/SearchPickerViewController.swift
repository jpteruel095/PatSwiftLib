//
//  SearchPickerViewController.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 11/8/20.
//

import UIKit

public struct SelectionData{
    var data: Any
    var text: String
}

public class SearchPickerViewController: UIViewController {
    var configureSearchVC: ((SearchPickerViewController) -> Void)?
    var dataSource: [SelectionData] = []
    var didSelectAction: ((Any) -> Void)?
    
    var pickerTitle: String?
    var customizedTableCell: ((UITableView, Any) -> UITableViewCell)?
    var customizedSearchFilter: (([SelectionData], String?) -> [SelectionData])?
    
    var navBarWasHidden: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var filteredDataSource: [SelectionData] {
        if let filter = customizedSearchFilter{
            return filter(dataSource, searchBar.text?.nullableTrimmed)
        }
        
        return dataSource.filter{
            guard let searchText = searchBar.text?.nullableTrimmed else{
                return true
            }
            return $0.text.lowercased().contains(searchText.lowercased())
        }.sorted{
            return $0.text
                .lowercased()
                .compare($1.text.lowercased()) == .orderedAscending
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchVC?(self)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = pickerTitle
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}

extension SearchPickerViewController: UITableViewDataSource, UITableViewDelegate{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableCellClosure = customizedTableCell else{
            let cell = UITableViewCell()
            cell.textLabel?.font = UIFont(name: "Lato-Bold", size: 18.0)
            cell.textLabel?.text = filteredDataSource[indexPath.row].text
            return cell
        }
        return tableCellClosure(tableView, filteredDataSource[indexPath.row].data)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let action = didSelectAction else{
            fatalError("You haven't configured select action")
        }
        tableView.deselectRow(at: indexPath, animated: true)
        action(filteredDataSource[indexPath.row].data)
        self.navigationController?.popViewController(animated: true)
    }
}

extension SearchPickerViewController: UISearchBarDelegate{
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.reloadData()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
