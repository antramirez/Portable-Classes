//
//  AddFlashCardViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class AddFlashCardViewController: UIViewController {

    @IBOutlet weak var termTextField: UITextField!
    @IBOutlet weak var defintionTextView: UITextView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var callback1: ((String) -> Void)?
    var callback2: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        callback1?(termTextField.text!)
        callback2?(defintionTextView.text!)
        self.dismiss(animated: true, completion: nil)
    }
    
}