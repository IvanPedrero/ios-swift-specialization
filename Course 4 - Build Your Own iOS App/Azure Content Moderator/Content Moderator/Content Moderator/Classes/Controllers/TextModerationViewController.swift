//
//  TextModerationViewController.swift
//  Content Moderator
//
//  Created by Ivan Pedrero on 11/10/20.
//  Copyright © 2020 Ivan Pedrero. All rights reserved.
//

import UIKit

class TextModerationViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textModerationTextView: UITextView!
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var resultModerationTextView: UITextView!
    
    @IBOutlet weak var inputRequestView: UIView!
    @IBOutlet weak var resultRequestView: UIView!
    
    @IBOutlet weak var loaderView: UIView!
    
    
    let inputPlaceholder:String! = "Enter a comment to analyze..."
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setDelegates()
        stylizeView()
        enableResultView(hide: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        enableResultView(hide: true)
        enableLoader(hide: true)
        dismissKeyboard()
    }
    
    
    private func setDelegates(){
        textModerationTextView.delegate = self
        textModerationTextView.returnKeyType = UIReturnKeyType.done
        
        textModerationTextView.text = inputPlaceholder
        textModerationTextView.textColor = UIColor.lightGray
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    private func stylizeView(){
        // Text view styling.
        textModerationTextView.layer.borderWidth = 0.5
        textModerationTextView.layer.borderColor = UIColor.lightGray.cgColor
        textModerationTextView.layer.cornerRadius = 15
        textModerationTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        
        resultModerationTextView.layer.borderWidth = 0.5
        resultModerationTextView.layer.borderColor = UIColor.lightGray.cgColor
        resultModerationTextView.layer.cornerRadius = 15
        resultModerationTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Container view styling.
        inputRequestView.layer.cornerRadius = 10
        inputRequestView.layer.shadowColor = UIColor.black.cgColor
        inputRequestView.layer.shadowOpacity = 0.2
        inputRequestView.layer.shadowOffset = .zero
        inputRequestView.layer.shadowRadius = 3
        
        resultRequestView.layer.cornerRadius = 10
        resultRequestView.layer.shadowColor = UIColor.black.cgColor
        resultRequestView.layer.shadowOpacity = 0.2
        resultRequestView.layer.shadowOffset = .zero
        resultRequestView.layer.shadowRadius = 3
        
        // Button styling.
        sendRequestButton.layer.cornerRadius = 10
        
    }
    
    private func enableResultView(hide:Bool) {
        resultRequestView.isHidden = hide
    }
    
    private func enableLoader(hide:Bool) {
        loaderView.isHidden = hide
    }
    
    
    @IBAction func sendRequest(_ sender: Any) {
        // Check the text view for good input.
        if textModerationTextView.text.isEmpty || textModerationTextView.text == inputPlaceholder {
            print("Not a valid comment...")
            return
        }
        
        // Perform the request.
        if let textData = textModerationTextView.text {
            moderate(text: textData)
        }
        else{
            print("No text in the view...")
        }
    }
    
    /// This function will perform the request to moderate a given text and will display it on the screen.
    private func moderate(text: String){
        enableLoader(hide: false)
        RequestController.moderateText(data: text, completion: { dic in
            if let dic = dic{
                // Update GUI from request information.
                DispatchQueue.main.async {
                    print(dic)
                    // Enable the result view.
                    self.enableResultView(hide: false)

                    // Get the classifications and dispaly them.
                    var classificationText:String! = ""
                    if let classification =  dic["Classification"] as? [String: Any] {
                        
                        if let class1 = classification["Category1"] as? [String: Any] {
                            let score:Double = class1["Score"] as! Double
                            classificationText += "Sexually explicit or adult :  \((score*100).rounded(toPlaces: 2))% \n"
                        }
                        
                        if let class2 = classification["Category2"] as? [String: Any] {
                            let score:Double = class2["Score"] as! Double
                            classificationText += "Sexually suggestive or mature :  \((score*100).rounded(toPlaces: 2))% \n"
                        }
                        
                        if let class3 = classification["Category3"] as? [String: Any] {
                            let score:Double = class3["Score"] as! Double
                            classificationText += "Offensive in certain situations :  \((score*100).rounded(toPlaces: 2))% \n"
                        }
                        if let recommendation = classification["ReviewRecommended"] as? Int {
                            classificationText += "\nRequires revision: "
                            if recommendation == 0 {
                                classificationText += "No"
                            }else{
                                classificationText += "Yes"
                            }
                        }
                    }else{
                        classificationText = "There was an error in the request, try it later..."
                    }
                    
                    self.enableLoader(hide: true)
                    self.resultModerationTextView.text = classificationText
                }
            }else{
                DispatchQueue.main.async {
                    self.enableLoader(hide: true)
                    self.resultModerationTextView.text = "There was an error in the request, try it later..."
                }
            }
        })
    }
    
    
    
    // MARK:- Text View Delegation
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    /// This function will remove the placeholder on the input text view.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textModerationTextView.textColor == UIColor.lightGray {
            textModerationTextView.text = ""
            textModerationTextView.textColor = UIColor.black
        }
    }
    
    
    /// This function will set the placeholder on the input text view.
    func textViewDidEndEditing(_ textView: UITextView) {
        if textModerationTextView.text == "" {
            textModerationTextView.text = inputPlaceholder
            textModerationTextView.textColor = UIColor.lightGray
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
