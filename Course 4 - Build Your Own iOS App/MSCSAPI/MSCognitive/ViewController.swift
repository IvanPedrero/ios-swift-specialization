
import UIKit

// This view controller allows the user to pick an image from their camera roll and have it analyzed.
// The resulting description is shown.

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    static let SubscriptionKey = "4feca6a33a894e2d8d738afe7e94115e"
    
    @IBOutlet weak var pickButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!


    @IBAction func pickButtonAction(_ sender: AnyObject) {
        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
            
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }

        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let client = MSCSAPIClient(subscriptionKey: ViewController.SubscriptionKey)
            
            pickButton.isEnabled = false
            pickButton.setBackgroundImage(image, for: UIControl.State())
            
            self.resultLabel.text = ""
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            client.analyzeImage(image, detectFeatures: [.Adult, .Categories, .Color, .Description, .Faces, .ImageType, .Tags]) { (json, error) in
                self.pickButton.isEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    print (error!.localizedDescription)
                    self.resultLabel.text = error!.localizedDescription
                    return
                }
                guard let data = json else {
                    print ("no json data")
                     self.resultLabel.text = "no json data"
                    return
                }
                print(data)
                guard let description = data["description"] as? [String: AnyObject] else {
                    guard let message = data["message"] as? String else {
                        return
                    }
                    print(message)
                    self.resultLabel.text = message
                    return
                }
                
                guard let captions = description["captions"] as? [AnyObject] else {
                    guard let message = data["message"] as? String else {
                        return
                    }
                    self.resultLabel.text = message
                    return
                }
                
                // 'captions' is an array of JSON objects. Each object has a 'text' property with the description text.
                // This function uses the map function to cast the unknown objects as the correct type,
                // then filters out empty strings, then joins the resulting strings  into one string
                // with a newline separator ("\n").
                self.resultLabel.text = captions.map(
                    { (($0 as? [String: AnyObject])?["text"] as? String) ?? ""}).filter(
                        { $0 != "" }).joined(separator: "\n")

            }
        }
    }
    

}

