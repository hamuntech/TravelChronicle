//
//  DestinationPhotosTableViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-10-12.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit
import CoreData

class DestinationPhotosTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    var destinationPhotosArray: [Photos] = []
    var hueColorForTable: CGFloat!
    var saturationColorForTable:CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.estimatedRowHeight = 60

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let destinationPhotosAppDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let destinationPhotosContext: NSManagedObjectContext = destinationPhotosAppDel.managedObjectContext
        let destinationPhotosFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
        
        destinationPhotosFetchRequest.predicate = NSPredicate(format: "destinationName = %@", viewSelectedDestinationName)
        
        do {
            let destinationPhotosFetchResults = try destinationPhotosContext.fetch(destinationPhotosFetchRequest) as? [Photos]
            destinationPhotosArray = destinationPhotosFetchResults!
        } catch {
            print("Could not fetch photos \(error)")
        }
                self.tableView.reloadData()
        
        let userDefaultsHue: Any? = UserDefaults.standard.object(forKey: "userDestinationsTableHue")
        let userDefaultsSaturation: Any? = UserDefaults.standard.object(forKey: "userDestinationsTableSaturation")
        
        hueColorForTable = userDefaultsHue as! CGFloat
        saturationColorForTable = userDefaultsSaturation as! CGFloat
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return destinationPhotosArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationPhotoCell", for: indexPath)

        // Configure the cell...
        
        let destinationPhoto: Photos = destinationPhotosArray[indexPath.row]
        let destinationPhotoName = destinationPhoto.destinationName
        let destinationPhotoImage = UIImage(data: destinationPhoto.destinationPhoto! as Data)
        
        if let nameLabel = cell.viewWithTag(101) as? UILabel {
            nameLabel.text = destinationPhotoName
        }
        
        if let destinationPhotoImageView = cell.viewWithTag(100) as? UIImageView {
            destinationPhotoImageView.image = destinationPhotoImage
        }
        
        let rowCount = CGFloat(tableView.numberOfRows(inSection: indexPath.section))
        let currentRow = CGFloat(indexPath.row)
        let hue = hueColorForTable!
        let saturation = saturationColorForTable! - currentRow / rowCount
        cell.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)

        return cell
    }
    
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height
   }
 
    */
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let destinationPhoto: Photos = destinationPhotosArray[indexPath.row]
        let destinationPhotoImage = UIImage(data: destinationPhoto.destinationPhoto! as Data)
        
        let aspectRatioOfImage = Float((destinationPhotoImage?.size.height)!) / Float((destinationPhotoImage?.size.width)!)
        
        return view.bounds.width * CGFloat(aspectRatioOfImage)
        
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
