//
//  PickerViewController.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 11/8/20.
//

import UIKit

class PickerViewController: UIViewController {
    var didCloseAction: ((Int?) -> Void)?
    
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var pickerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var titleBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    var pickerTitle: String?
    var dataSource: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleBarButtonItem.title = pickerTitle
        doneBarButtonItem.isEnabled = dataSource.count > 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = .clear
            self.pickerTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { (didFinish) in
            if didFinish{
                self.dismiss(animated: false) {
                    guard self.dataSource.count > 0 else{
                        self.didCloseAction?(nil)
                        return
                    }
                    let row = self.pickerView.selectedRow(inComponent: 0)
                    self.didCloseAction?(row)
                }
            }
        }
    }
}

extension PickerViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
}

extension PickerViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
}
