//
//  DatePickerViewController.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 11/2/20.
//

import UIKit

public class DatePickerViewController: UIViewController {
    public var configuration: ((UIDatePicker) -> Void)?
    public var didCloseAction: ((Date?) -> Void)?
    
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var pickerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let config = configuration{
            config(datePicker)
        }
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            self.pickerTopConstraint.constant = self.pickerContainer.frame.height
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        UIView.animate(withDuration: 0.15, animations: {
            self.view.backgroundColor = .clear
            self.pickerTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { (didFinish) in
            if didFinish{
                self.dismiss(animated: false) {
                    self.didCloseAction?(nil)
                }
            }
        }
    }
    
    @IBAction func didTopDoneButton(_ sender: Any) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = .clear
            self.pickerTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { (didFinish) in
            if didFinish{
                self.dismiss(animated: false) {
                    self.didCloseAction?(self.datePicker.date)
                }
            }
        }
    }
}
