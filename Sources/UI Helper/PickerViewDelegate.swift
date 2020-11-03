//
//  PickerViewDelegate.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 11/2/20.
//

import UIKit

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
}
