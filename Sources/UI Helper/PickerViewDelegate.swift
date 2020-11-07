//
//  PickerViewDelegate.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 11/2/20.
//

import UIKit

public protocol PickerSelectionItem{
    var pickerItemTitle: String { get }
}

public protocol PickerDelegate {
    
}

public extension PickerDelegate where Self: UIViewController{
    func openDatePicker(with configuration:((UIDatePicker) -> Void)? = nil, closeAction:@escaping((Date?) -> Void)){
        let podBundle = Bundle(for: DatePickerViewController.self)
        
        if let datePickerVC = UIStoryboard(name: "Pickers", bundle: podBundle).instantiateViewController(withIdentifier: "datePickerVC") as? DatePickerViewController{
            datePickerVC.modalPresentationStyle = .overFullScreen
            datePickerVC.configuration = configuration
            datePickerVC.didCloseAction = closeAction
            self.present(datePickerVC, animated: true, completion: nil)
        }
    }
    
    func openPicker<T: PickerSelectionItem>(withTitle title: String?, dataSource: [T], closeAction:@escaping((T?) -> Void)){
        let podBundle = Bundle(for: PickerViewController.self)
        
        if let pickerVC = UIStoryboard(name: "Pickers", bundle: podBundle).instantiateViewController(withIdentifier: "pickerVC") as? PickerViewController{
            pickerVC.modalPresentationStyle = .overFullScreen
            pickerVC.didCloseAction = { idx in
                guard let idx = idx,
                      idx < dataSource.count else{
                    closeAction(nil)
                    return
                }
                closeAction(dataSource[idx])
            }
            pickerVC.pickerTitle = title
            pickerVC.dataSource = dataSource.compactMap({$0.pickerItemTitle})
            self.present(pickerVC, animated: true, completion: nil)
        }
    }
    
    func openSearchPicker<T: PickerSelectionItem>(withTitle title: String?,
                          dataSource: [T],
                          selectionAction:@escaping((T?) -> Void),
                          searchVCConfiguration: ((SearchPickerViewController) -> Void)? = nil,
                          customSearchFilter: (([SelectionData], String?) -> [SelectionData])? = nil){
        let podBundle = Bundle(for: PickerViewController.self)
        
        guard let navVC = self.navigationController else{
            print("View Controller must have a navigation controller.")
            return
        }
        
        if let searchPickerVC = UIStoryboard(name: "Pickers", bundle: podBundle).instantiateViewController(withIdentifier: "searchPickerVC") as? SearchPickerViewController{
            searchPickerVC.modalPresentationStyle = .overFullScreen
            searchPickerVC.pickerTitle = title
            searchPickerVC.dataSource = dataSource.map{SelectionData(data: $0,
                                                                     text: $0.pickerItemTitle)}
            searchPickerVC.didSelectAction = { data in
                selectionAction(data as? T)
            }
            searchPickerVC.configureSearchVC = searchVCConfiguration
            searchPickerVC.customizedSearchFilter = customSearchFilter
            searchPickerVC.navBarWasHidden = navVC.isNavigationBarHidden
            navVC.setNavigationBarHidden(false, animated: false)
            navVC.pushViewController(searchPickerVC, animated: true)
        }
    }
}
