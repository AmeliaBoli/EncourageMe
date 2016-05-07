//
//  OnboardingViewController.swift
//  AmeliaBoli
//
//  Created by Matthew Frederick on 5/1/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissView(sender: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
