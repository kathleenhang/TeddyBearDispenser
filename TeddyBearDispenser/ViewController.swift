//
//  ViewController.swift
//  TeddyBearDispenser
//
//  Created by Kathleen Hang on 2/18/18.
//  Copyright © 2018 Team Cowdog. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // what happens once purchase button is clicked
    
    func purchase() {
        let unitCost = selection
        let quantity = selection
        let grandTotal = selection * quantity
        
        calculateTotal() {
            let grandTotal = selection * quantity
        }
        updateAttributes()
            {
                unitCost = 0
                quantity = 1
                grandTotal = 0
                totalBalance = grandTotal - totalBalance
        }


}

