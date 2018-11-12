//
//  PhotosViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-10-10.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import MobileCoreServices

class PhotosViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var addImageLabel: UILabel!
    @IBOutlet weak var addImageSwitchLabel: UISwitch!
    @IBOutlet weak var saveImageConfirmationLabel: UILabel!
    @IBOutlet weak var destinationImage: UIImageView!
    @IBOutlet weak var filterPicker: UIPickerView!
    
    
    var photosDestinationName: String!
    var photosSourceType: String!
    var selectedImage: UIImage!
    
    // filter Title and Name list
    var filterTitleList: [String]!
    var filterNameList: [String]!
    
    @IBAction func addDestinationPhotoAction(_ sender: Any) {
        
        accessCameraOrPhotoLibrary()
    }
    
    @IBAction func addImageToCoreDataAction(_ sender: Any) {
        
        addImageToCoreData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImageSwitchLabel.alpha = 0
        saveImageConfirmationLabel.alpha = 0
        addImageSwitchLabel.isOn = false
        
        accessCameraOrPhotoLibrary()
        
        // set filter title list array.
        self.filterTitleList = ["(Select a Filter)" ,"Chrome", "Fade", "Instant", "Mono", "Noir", "Process", "Tonal", "Transfer", "Invert", "Maximum Component", "Minimum Component"]
        
        // set filter name list array.
        self.filterNameList = ["No Filter" ,"CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer", "CIColorInvert", "CIMaximumComponent", "CIMinimumComponent"]
        
        // set delegate for filter picker
        self.filterPicker.delegate = self
        self.filterPicker.dataSource = self
        
        // disable filter pickerView
        self.filterPicker.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        addImageLabel.text = "Add to " + photosDestinationName + "?"
        addImageSwitchLabel.isOn = false
        
    }
    
    func accessCameraOrPhotoLibrary() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if photosSourceType == "Photos" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
                present(imagePicker, animated: true, completion: nil)
            }
        }
        
        if photosSourceType == "Camera" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.cameraCaptureMode = .photo
                present(imagePicker, animated: true, completion: nil)
            } else {
                noCamera()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeImage as NSString as String) {
            
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            selectedImage = image
            
            destinationImage.image = selectedImage
            destinationImage.contentMode = .scaleAspectFit
        }
        
        addImageLabel.alpha = 1
        addImageSwitchLabel.alpha = 1
        addImageSwitchLabel.setOn(true, animated: true)
        saveImageConfirmationLabel.alpha = 0
        filterPicker.isUserInteractionEnabled = true
        
        // set filter pickerview to default position
        self.filterPicker.selectRow(0, inComponent: 0, animated: true)
        
        //addImageToCoreData()
    }
    
    
    // MARK: - picker view delegate and data source (to choose filter name)
    // how many component (i.e. column) to be displayed within picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // How many rows are there is each component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.filterTitleList.count
    }
    
    // title/content for row in given component
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.filterTitleList[row]
    }
    
    // called when row selected from any component within picker view
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // call funtion to apply the selected filter
        self.applyFilter(selectedFilterIndex: row)
    }
    
    // apply filter to current image
    fileprivate func applyFilter(selectedFilterIndex filterIndex: Int) {
        
        //        print("Filter - \(self.filterNameList[filterIndex)")
        
        /* filter name
         0 - NO Filter,
         1 - PhotoEffectChrome, 2 - PhotoEffectFade, 3 - PhotoEffectInstant, 4 - PhotoEffectMono,
         5 - PhotoEffectNoir, 6 - PhotoEffectProcess, 7 - PhotoEffectTonal, 8 - PhotoEffectTransfer
         */
        
        // if No filter selected then apply default image and return.
        if filterIndex == 0 {
            // set image selected image
            self.destinationImage.image = self.selectedImage
            return
        }
        
        
        // Create and apply filter
        // 1 - create source image
        let sourceImage = CIImage(image: self.selectedImage)
        
        // 2 - create filter using name
        let myFilter = CIFilter(name: self.filterNameList[filterIndex])
        myFilter?.setDefaults()
        
        // 3 - set source image
        myFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - create core image context
        let context = CIContext(options: nil)
        
        // 5 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage(myFilter!.outputImage!, from: myFilter!.outputImage!.extent)
        
        // 6 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!, scale: destinationImage.image!.scale, orientation: destinationImage.image!.imageOrientation)
        
        // 7 - set filtered image to preview
        self.destinationImage.image = filteredImage
    }
    
    
    func addImageToCoreData() {
        
        let photoAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let photosContext: NSManagedObjectContext = photoAppDel.managedObjectContext
        
        if addImageSwitchLabel.isOn {
            
            let newImageData = UIImageJPEGRepresentation(destinationImage.image!, 1)
            
            let newPhoto = NSEntityDescription.insertNewObject(forEntityName: "Photos", into: photosContext) as! Photos
            
            newPhoto.destinationName = photosDestinationName
            newPhoto.destinationPhoto = newImageData! as NSData
            
            do {
                try
                    photosContext.save()
                
                print("Photo Saved")
                saveImageConfirmationLabel.alpha = 1
                saveImageConfirmationLabel.text = "Saved Photo for: " + photosDestinationName
            } catch _ {
                
            }
        }
    }
    
    func noCamera() {
        
        let alertVC = UIAlertController(title: "No Camera!", message: "Hello, your device does not have a camera", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
