//
//  NotificationFrequencyViewController.swift
//  AmeliaBoli
//
//  Created by Amelia Boli on 4/22/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class NotificationFrequencyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var frequencyPicker: UIPickerView!
    
    let pickerTitles = ["Hectic", "Steady", "Relaxed"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frequencyPicker.dataSource = self
        frequencyPicker.delegate = self
        frequencyPicker.selectRow(1, inComponent: 0, animated: false)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerTitles.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerTitles[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        scheduleNotifications(pickerTitles[row])
        dismissViewControllerAnimated(true, completion: nil)
    }
  }
