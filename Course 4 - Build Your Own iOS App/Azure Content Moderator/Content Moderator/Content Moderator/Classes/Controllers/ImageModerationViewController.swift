//
//  ImageModerationViewController.swift
//  Content Moderator
//
//  Created by Ivan Pedrero on 12/10/20.
//  Copyright © 2020 Ivan Pedrero. All rights reserved.
//

import UIKit


class ImageModerationViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var resultModerationTextView: UITextView!
    
    @IBOutlet weak var inputRequestView: UIView!
    @IBOutlet weak var resultRequestView: UIView!
    @IBOutlet weak var loaderView: UIView!
    

    private var imageChanged:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        stylizeView()
        setRecognizers()
        setUpView()
    }
    
    func setUpView() {
        imageView.image = UIImage(named: "placeholder")
        imageChanged = false
        enableResultView(hide: true)
        enableLoader(hide: true)
    }
    
    func resetView(){
        enableResultView(hide: true)
        enableLoader(hide: true)
    }
    
    private func setRecognizers(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onImageTap(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func onImageTap(tapGestureRecognizer: UITapGestureRecognizer) {
        
        resetView()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            showImageOptions(isIpad: true)
        }else{
            showImageOptions(isIpad: false)
        }
        
        
    }
    
    private func showImageOptions(isIpad: Bool){
        // Shown in iPad.
        if isIpad {
            let pictureAlert = UIAlertController(title: "Select picture from...", message: nil, preferredStyle: UIAlertController.Style.alert)

            pictureAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
                self.showCamera()
            }))

            pictureAlert.addAction(UIAlertAction(title: "Album", style: .default, handler: { (action: UIAlertAction!) in
                self.showAlbum()
            }))

            present(pictureAlert, animated: true, completion: nil)
        }
        // Shown in iPhone.
        else{
            let actionSheet = UIAlertController(title: "Select picture from...", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
                action in
                self.showCamera()
            }))
            actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: {
                action in
                self.showAlbum()
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    private func stylizeView(){
        // Text view styling.
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
        
        // Image view styling.
        imageView.layer.cornerRadius = 8.0
        
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
        //print(imageView.image as Any)
        // Check the text view for good input.
        if imageView.image == nil || imageChanged == false {
            print("Not a valid image...")
            return
        }
        
        // Perform the request.
        moderate(image: imageView.image!)
    }
    
    func moderate(image:UIImage){
        enableLoader(hide: false)
        
        RequestController.moderateImage(data: (image.pngData())!, completion: { dic in
            if let dic = dic{
                // Update GUI from request information.
                DispatchQueue.main.async {
                    
                    print(dic)
                    // Enable the result view.
                    self.enableResultView(hide: false)
                    self.enableLoader(hide: true)
                    
                    var classificationText:String! = ""
                    if let res =  dic["Status"] as? [String: Any] {
                        
                        if res["Description"] as! String != "OK" { return }
                        
                        if let isRacy:Int = dic["IsImageRacyClassified"] as? Int {
                            var racyText:String = ""
                            if isRacy == 0 {
                                racyText = "No"
                            }else{
                                racyText = "Yes"
                            }
                            classificationText += "Is the image racy? :  \(racyText) \n"
                        }
                        
                        if let racyScore:Double = dic["RacyClassificationScore"] as? Double {
                            classificationText += "Racy content percentage :  \((racyScore*100).rounded(toPlaces: 2))% \n\n"
                        }
                        
                        if let isAdult:Int = dic["IsImageAdultClassified"] as? Int {
                            var adultText:String = ""
                            if isAdult == 0 {
                                adultText = "No"
                            }else{
                                adultText = "Yes"
                            }
                            classificationText += "Is the image for adults? :  \(adultText) \n"
                        }
                        
                        if let racyScore:Double = dic["AdultClassificationScore"] as? Double {
                            classificationText += "Adult content percentage :  \((racyScore*100).rounded(toPlaces: 2))% \n"
                        }
                    }else{
                        classificationText = "There was an error in the request, try it later..."
                    }
                    
                    self.resultModerationTextView.text = classificationText
                }
            }else{
                DispatchQueue.main.async {
                    self.resultModerationTextView.text = "There was an error in the request, try it later..."
                    self.enableLoader(hide: false)
                }
            }
        })
    }
    
    // MARK: - Photo delgate methods
    
    func showCamera(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .savedPhotosAlbum
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            imageChanged = true
            self.enableResultView(hide: true)
        }
        
        dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

