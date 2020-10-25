//
//  ViewController.swift
//  PatSwiftLib
//
//  Created by John Patrick on 10/24/2020.
//  Copyright (c) 2020 John Patrick. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

}

extension ViewController{
    func refreshProducts(){
        ProductRequest().request(completion:{ (products, error) in
            if let error = error{
                print(error)
                return
            }
            
            products.forEach { (product) in
                print(product)
            }
        })
    }
}

