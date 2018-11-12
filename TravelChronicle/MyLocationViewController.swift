//
//  MyLocationViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-09-26.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MyLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var myLocationDestinationName: UITextField!
    @IBOutlet weak var addConfirmationLabel: UILabel!
    
    @IBOutlet weak var myLocationAddress: UILabel!
    @IBOutlet weak var myLocationLatitude: UILabel!
    @IBOutlet weak var myLocationLongitude: UILabel!
    
    @IBOutlet weak var photosButtonLabel: UIButton!
    @IBOutlet weak var cameraButtonLabel: UIButton!
    @IBOutlet weak var soundsButtonLabel: UIButton!
    @IBOutlet weak var videosButtonLabel: UIButton!
    @IBOutlet weak var uploadButtonLabel: UIButton!
    @IBOutlet weak var uploadImageView: UIImageView!
    
    @IBOutlet weak var myLocationMapView: MKMapView!
    
    var manager: CLLocationManager!
    var destinationName: String = ""
    var destinationNotes: String = ""
    
    //Social media upload variables
    
    var destinationSocialMediaText = ""
    var destinationSaved: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myLocationDestinationName.delegate = self //Used for the UITextField keyboad control
        
        myLocationDestinationName.text = ""
        addConfirmationLabel.alpha = 0
        photosButtonLabel.alpha = 0
        cameraButtonLabel.alpha = 0
        soundsButtonLabel.alpha = 0
        videosButtonLabel.alpha = 0
        uploadButtonLabel.alpha = 0
        uploadImageView.alpha = 0
        
        manager = CLLocationManager()
        manager.delegate =  self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        //This starts the location updates. While the locations are being updated, sae them in the location manager array locations[] in the function below
        
        let saveRightBarButton = UIBarButtonSystemItem.save
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: saveRightBarButton, target: self, action: #selector(myLocationSaveButtonAction))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if destinationSaved == true {
            
        var destinationPhotosArray: [Photos] = []
        
        let destinationPhotosAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let destinationPhotosContext: NSManagedObjectContext = destinationPhotosAppDel.managedObjectContext
        let destinationPhotosFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
        
        destinationPhotosFetchRequest.predicate = NSPredicate(format: "destinationName = %@", destinationName)
        
        
        do {
            let destinationPhotosFetchResults = try destinationPhotosContext.fetch(destinationPhotosFetchRequest) as? [Photos]
            destinationPhotosArray = destinationPhotosFetchResults!
        } catch {
            print("Could not fetch photos for destination \(error)")
        }
        
        if destinationPhotosArray.count > 0 {
            
            let endIndexOfDestinationPhotosArray = destinationPhotosArray.count - 1 // Last photo taken ( -1 as arrays start at 0)
            let destinationPhoto: Photos = destinationPhotosArray[endIndexOfDestinationPhotosArray] as Photos
            let destinationPhotoImage = UIImage(data: destinationPhoto.destinationPhoto! as Data) //Storage is of type Data
            
            if (destinationPhotoImage != nil) {
                uploadImageView.image = destinationPhotoImage
            } else {
                let destinationDefaultPhotoImage = UIImage(named: "photo_default")
                uploadImageView.image = destinationDefaultPhotoImage
            }
        }
      }
        
    }
    
    @IBAction func findMeButtonAction(_ sender: Any) {
        
        manager.requestWhenInUseAuthorization()
        myLocationMapView.removeAnnotations(myLocationMapView.annotations)
        manager.startUpdatingLocation()
        
    }
    
    
    
    @IBAction func myLocationSaveButtonAction(sender: AnyObject) {
        
        if myLocationDestinationName.text!.isEmpty {
            showAlert(alertTitle: "Invalid Destination Name", alertMessage: "Destination Name cannot be blank")
        } else {
        
        destinationName = myLocationDestinationName.text!
        
        //Save destination record to the core data
        
        let destinationAppDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let destinationContext: NSManagedObjectContext = destinationAppDel.managedObjectContext
        let newDestination = NSEntityDescription.insertNewObject(forEntityName: "Destinations", into: destinationContext) as! Destinations
        
        newDestination.destinationName = destinationName
        newDestination.destinationLatitude = Double(myLocationLatitude.text!) ?? 0.0
        newDestination.destinationLongitude = Double(myLocationLongitude.text!) ?? 0.0
        newDestination.destinationShow = true
        newDestination.destinationType = "MY"
        newDestination.destinationNotes = myLocationAddress.text!
        
        
        do {
            try destinationContext.save()
            addConfirmationLabel.alpha = 1
            addConfirmationLabel.text = "Saved:" + destinationName
            print("Saved the destination successfully \(destinationName)")
            
            photosButtonLabel.alpha = 1
            cameraButtonLabel.alpha = 1
            soundsButtonLabel.alpha = 1
            videosButtonLabel.alpha = 1
            uploadButtonLabel.alpha = 1
            uploadImageView.alpha = 1
            
            destinationSaved =  true
            
        } catch {
            addConfirmationLabel.alpha = 1
            addConfirmationLabel.text = "Error:" + destinationName
            print("Could not save \(error)")
        }
        
      }
        myLocationDestinationName.resignFirstResponder()
    }
    
    
    @IBAction func uploadButtonAction(_ sender: UIButton) {
        
        //Once the imapge is uploaded, it will display
        //1. Name of the Destination
        //2. destinationSocialMediaText which is set to subAdministrativeArea + country in didUpdateLocations
        //3. The image
        //4. TravelChronicle http://www.pendoo.com
        //See video 064 at 06:34 for a screenshot
        
        
        var destinationItems: [AnyObject]?
        let destinationURL: NSURL = NSURL(string: "http://www.pendoo.com")!
        let destinationSignature = "\nTravelChronicle! \(destinationURL)"
        
        if (uploadImageView.image != nil) {
            destinationItems = [destinationName as AnyObject, destinationSocialMediaText as AnyObject, uploadImageView.image!, destinationSignature as AnyObject]
        } else {
            destinationItems = [destinationName as AnyObject, destinationSocialMediaText as AnyObject, destinationSignature as AnyObject]
        }
        
        let activityController = UIActivityViewController(activityItems: destinationItems!, applicationActivities: nil)
        
        self.present(activityController, animated: true, completion: nil)
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let myLocation: CLLocation = locations[0]
        
        let myLatitude: CLLocationDegrees = myLocation.coordinate.latitude
        let myLongitude: CLLocationDegrees = myLocation.coordinate.longitude
        let myDeltaLatitude: CLLocationDegrees = 0.01
        let myDeltaLongitude: CLLocationDegrees = 0.01
        let mySpan: MKCoordinateSpan = MKCoordinateSpanMake(myDeltaLatitude, myDeltaLongitude)
        let myCurrentLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLatitude, myLongitude)
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMake(myCurrentLocation, mySpan)
        myLocationMapView.setRegion(myRegion, animated: true)
        
        manager.stopUpdatingLocation() //We don not want the location to keep on moving all the time
        
        //Annotation
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = myCurrentLocation
        destinationAnnotation.title = "My Location"
        myLocationMapView.addAnnotation(destinationAnnotation)
        
        //Update the lat and long labels
        
        myLocationLatitude.text = "\(myLatitude)"
        myLocationLongitude.text = "\(myLongitude)"
        
        //Geocoder function
        
        
        CLGeocoder().reverseGeocodeLocation(myLocation, completionHandler: { (placemarks, error) in
            
            if ((error) != nil) { print("Error: \(String(describing: error))") }
            else {
                
                let p = CLPlacemark(placemark: (placemarks?[0] as CLPlacemark?)!)
                
                var subThoroughfare: String = ""
                var thoroughfare: String = ""
                var subLocality: String = ""
                var subAdministrativeArea: String = ""
                var postalCode: String = ""
                var country: String = ""
                
                if ((p.subThoroughfare) != nil) {
                    subThoroughfare = (p.subThoroughfare)!
                }
                if ((p.thoroughfare) != nil) {
                    thoroughfare = (p.thoroughfare)!
                }
                if ((p.subLocality) != nil) {
                    subLocality = (p.subLocality)!
                }
                if ((p.subAdministrativeArea) != nil) {
                    subAdministrativeArea = (p.subAdministrativeArea)!
                }
                if ((p.postalCode) != nil) {
                    postalCode = (p.postalCode)!
                }
                if ((p.country) != nil) {
                    country = (p.country)!
                }
                
                self.myLocationAddress.text = "\(subThoroughfare) \(thoroughfare)\n\(subLocality) \(subAdministrativeArea) \(postalCode)\n\(country)"
                self.destinationSocialMediaText = "\n" + subAdministrativeArea + " " + country //This can be anything
        }
                
            }
            
        )
        
    }
    
    // MARK: - Keyboard control
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        myLocationDestinationName.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showAlert(alertTitle: String, alertMessage: String) {
        
        let alert = UIAlertController(title: alertTitle, message: "\(alertMessage)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myLocationToPhotos" {
            let vc = segue.destination as! PhotosViewController
            vc.photosDestinationName = destinationName
            vc.photosSourceType = "Photos"
        }
        
        if segue.identifier == "myLocationToCamera" {
            let vc = segue.destination as! PhotosViewController
            vc.photosDestinationName = destinationName
            vc.photosSourceType = "Camera"
        }
        
        if segue.identifier == "myLocationToSounds" {
            let vc = segue.destination as! SoundsViewController
            vc.soundDestinationName = destinationName
        }
        
        if segue.identifier == "myLocationToVideos" {
            let vc = segue.destination as! VideosViewController
            vc.videosDestinationName = destinationName
            vc.videosSourceType = "Video"
        }
        
    }
    


}
