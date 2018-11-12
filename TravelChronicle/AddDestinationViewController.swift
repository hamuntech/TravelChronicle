//
//  AddDestinationViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-09-30.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import CoreData

class AddDestinationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var topSaveConfirmationLabel: UILabel!
    @IBOutlet weak var destinationNameTextField: UITextField!
    @IBOutlet weak var destinationLatitudeTextField: UITextField!
    @IBOutlet weak var destinationLongitudeTextField: UITextField!
    @IBOutlet weak var destinationNotesTextView: UITextView!
    
    @IBOutlet weak var photosButtonLabel: UIButton!
    @IBOutlet weak var cameraButtonLabel: UIButton!
    @IBOutlet weak var soundsButtonLabel: UIButton!
    @IBOutlet weak var videosButtonLabel: UIButton!
    
    
    var destinationName:String = ""
    var destinationLatitude:Double = 0.0
    var destinationLongitude:Double = 0.0
    var destinationNotes: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveRightButton = UIBarButtonSystemItem.save
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: saveRightButton,
            target: self, action: #selector(addSaveButtonAction))
        
        topSaveConfirmationLabel.alpha = 0
        
        destinationNotesTextView.text = ".."
        
        self.destinationNameTextField.delegate = self
        
        photosButtonLabel.alpha = 0
        cameraButtonLabel.alpha = 0
        soundsButtonLabel.alpha = 0
        videosButtonLabel.alpha = 0
        
    }
    
    @IBAction func addSaveButtonAction(sender: AnyObject) {
        
        destinationName = destinationNameTextField.text!
        destinationLatitude = Double(destinationLatitudeTextField.text!) ?? 0.0
        destinationLongitude = Double(destinationLongitudeTextField.text!) ?? 0.0
        destinationNotes = destinationNotesTextView.text
        
        let destinationAppDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let destinationContext: NSManagedObjectContext = destinationAppDel.managedObjectContext
        let newDestination = NSEntityDescription.insertNewObject(forEntityName: "Destinations", into: destinationContext) as! Destinations
        
        newDestination.destinationName = destinationName
        newDestination.destinationLatitude = destinationLatitude
        newDestination.destinationLongitude = destinationLongitude
        newDestination.destinationShow = true
        newDestination.destinationType = "MY"
        newDestination.destinationNotes = destinationNotesTextView.text

        
        do {
            try destinationContext.save()
            topSaveConfirmationLabel.alpha = 1
            topSaveConfirmationLabel.text = "Saved:" + destinationName
            print("Saved the destination successfully \(destinationName)")
            
            photosButtonLabel.alpha = 1
            cameraButtonLabel.alpha = 1
            soundsButtonLabel.alpha = 1
            videosButtonLabel.alpha = 1
        } catch {
            topSaveConfirmationLabel.alpha = 1
            topSaveConfirmationLabel.text = "Error:" + destinationName
            print("Could not save \(error)")
        }
        
        destinationNotesTextView.resignFirstResponder()
        destinationNameTextField.resignFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addToPhotos" {
            
            let vc = segue.destination as! PhotosViewController
            vc.photosDestinationName = destinationName
            vc.photosSourceType = "Photos"
        }
        
        if segue.identifier == "addToCamera" {
            
            let vc = segue.destination as! PhotosViewController
            vc.photosDestinationName = destinationName
            vc.photosSourceType = "Camera"
        }
        
        if segue.identifier == "addToSounds" {
            
            let vc = segue.destination as! SoundsViewController
            vc.soundDestinationName = destinationName
        }
        
        if segue.identifier == "addToVideos" {
            
            let vc = segue.destination as! VideosViewController
            vc.videosDestinationName = destinationName
        }
        
    }
    
    
    // MARK: - Keyboard control
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        destinationNameTextField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
