//
//  RegisterView.swift
//  DiveApp
//
//  Created by James O'Connor on 8/25/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit

protocol RegisterViewDelegate : class {
    
    func registerViewDidRegister(username :String, password :String, confirmPassword :String)
    
}

class RegisterView: UIView {
    
    weak var delegate :RegisterViewDelegate!

    @IBOutlet weak var usernameTextField :UITextField!
    @IBOutlet weak var passwordTextField :UITextField!
    @IBOutlet weak var confirmPasswordTextField :UITextField!
    
    @IBAction func register() {
        
        self.delegate.registerViewDidRegister(usernameTextField.text!, password: passwordTextField.text!, confirmPassword: confirmPasswordTextField.text!)
        
    }
    
    
}
