//
//  SignInView.swift
//  DiveApp
//
//  Created by James O'Connor on 8/25/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit


protocol SignInViewDelegate : class {
    
    func signInViewDidSignIn(userName :String!, password :String!)
    
}

class SignInView: UIView {

    weak var delegate :SignInViewDelegate!
    
    @IBOutlet weak var usernameTextField :UITextField!
    @IBOutlet weak var passwordTextField :UITextField!

    
    @IBAction func signIn() {
        
        if (self.usernameTextField.text!.isEmpty || self.passwordTextField.text!.isEmpty) {
            
            self.usernameTextField.text = ""
            self.passwordTextField.text = ""
            
            self.delegate!.signInViewDidSignIn(self.usernameTextField.text!, password: self.passwordTextField.text!)
            
        }
        
        else {
        
        self.delegate!.signInViewDidSignIn(self.usernameTextField.text!, password: self.passwordTextField.text!)
            
        }
    
    }
    
    
    

}
