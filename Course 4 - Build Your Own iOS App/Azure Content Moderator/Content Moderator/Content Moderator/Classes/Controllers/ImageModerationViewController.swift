//
//  ImageModerationViewController.swift
//  Content Moderator
//
//  Created by Ivan Pedrero on 12/10/20.
//  Copyright © 2020 Ivan Pedrero. All rights reserved.
//

import UIKit


class ImageModerationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        moderate(image: UIImage(named: "puppy")!)
    }
    
    
    func moderate(image:UIImage){
        
        RequestController.moderateImage(data: (image.pngData())!, completion: { dic in
            if let dic = dic{
                // Update GUI from request information.
                DispatchQueue.main.async {
                    print(dic)
                    // Enable the result view.
                    //self.enableResultView(hide: false)
                    
                    //self.newConfirmedLabel.text = String(format: "%@", dic["NewConfirmed"] as! CVarArg)
                    /*var classificationText:String! = ""
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
                    
                    self.resultModerationTextView.text = classificationText*/
                }
            }else{
                    print("Error")
            }
        })
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
