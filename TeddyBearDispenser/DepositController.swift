//
//  DepositController.swift
//  TeddyBearDispenser
//
//  Created by Kathleen Hang on 2/22/18.
//  Copyright © 2018 Team Cowdog. All rights reserved.
//

import UIKit

// this is cocoa touch class file
class DepositController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // responsibility of vc that presented the view to dismiss it
    // but if you call dismiss on the presented view , ui kit auto asks parent to dismiss it
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
