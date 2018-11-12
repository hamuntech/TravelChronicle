//
//  DestinationTableColorsViewController.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-11-28.
//  Copyright © 2017 M Aslam. All rights reserved.
//

import UIKit

class DestinationTableColorsViewController: UIViewController {
    
    @IBOutlet weak var row1ColorLabel: UILabel!
    @IBOutlet weak var row2ColorLabel: UILabel!
    @IBOutlet weak var row3ColorLabel: UILabel!
    @IBOutlet weak var row4ColorLabel: UILabel!
    @IBOutlet weak var row5ColorLabel: UILabel!
    @IBOutlet weak var row6ColorLabel: UILabel!
    @IBOutlet weak var row7ColorLabel: UILabel!
    @IBOutlet weak var row8ColorLabel: UILabel!
    @IBOutlet weak var row9ColorLabel: UILabel!
    @IBOutlet weak var row10ColorLabel: UILabel!
    //@IBOutlet weak var saveLabel: UILabel!
    //@IBOutlet weak var saveAsDefaultSwitchOutlet: UISwitch!
    @IBOutlet weak var rowHueSliderOutlet: UISlider!
    @IBOutlet weak var rowSaturationSliderOutlet: UISlider!
    
    var hueColor: CGFloat!
    var saturationColor: CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //saveAsDefaultSwitchOutlet.isOn = false
        //saveLabel.text = "Save as Default?"
        
        let userDefaultsHue: Any? = UserDefaults.standard.object(forKey: "userDestinationsTableHue")
        let userDefaultsSaturation: Any? = UserDefaults.standard.object(forKey: "userDestinationsTableSaturation")
        
        
        if let hue = userDefaultsHue {
            hueColor = hue as! CGFloat
        } else {
            hueColor = 0.5
        }
        
        if let sat = userDefaultsSaturation {
            saturationColor = sat as! CGFloat
            
        } else {
            saturationColor = 0.5
        }
        
        rowHueSliderOutlet.setValue(Float(hueColor), animated: true)
        rowSaturationSliderOutlet.setValue(Float(saturationColor), animated: true)
        
        setColorAndHue()
        
    }
    
    @IBAction func rowHueSliderChanged(_ sender: Any) {
        
        hueColor = CGFloat(rowHueSliderOutlet.value)
        setColorAndHue()
       
        
    }
    
    @IBAction func rowSaturationSliderChanged(_ sender: Any) {
        
        saturationColor = CGFloat(rowSaturationSliderOutlet.value)
        setColorAndHue()
        
    }
    
    func setColorAndHue() {
        
        row1ColorLabel.backgroundColor = UIColor(hue: hueColor, saturation: saturationColor - 3.0 / 12.0, brightness: 1.0, alpha: 1.0)
        row2ColorLabel.backgroundColor = UIColor(hue: hueColor, saturation: saturationColor - 4.0 / 12.0, brightness: 1.0, alpha: 1.0)
        row3ColorLabel.backgroundColor = UIColor(hue: hueColor, saturation: saturationColor - 5.0 / 12.0, brightness: 1.0, alpha: 1.0)
        row4ColorLabel.backgroundColor = UIColor(hue: hueColor, saturation: saturationColor - 6.0 / 12.0, brightness: 1.0, alpha: 1.0)
        row5ColorLabel.backgroundColor = UIColor(hue: hueColor, saturation: saturationColor - 7.0 / 12.0, brightness: 1.0, alpha: 1.0)
        row6ColorLabel.backgroundColor = UIColor(hue: hueColor, saturation: saturationColor - 8.0 / 12.0, brightness: 1.0, alpha: 1.0)
        row7ColorLabel.backgroundColor = UIColor(hue: hueColor, saturation: saturationColor - 9.0 / 12.0, brightness: 1.0, alpha: 1.0)
        row8ColorLabel.backgroundColor = UIColor(hue: hueColor, saturation: saturationColor - 10.0 / 12.0, brightness: 1.0, alpha: 1.0)
        row9ColorLabel.backgroundColor = UIColor(hue: hueColor, saturation: saturationColor - 11.0 / 12.0, brightness: 1.0, alpha: 1.0)
        row10ColorLabel.backgroundColor = UIColor(hue: hueColor, saturation: saturationColor - 12.0 / 12.0, brightness: 1.0, alpha: 1.0)
        
        let hueColorFloat = Float(hueColor)
        UserDefaults.standard.set(hueColorFloat, forKey: "userDestinationsTableHue")
        
        let saturationColorFloat = Float(saturationColor)
        UserDefaults.standard.set(saturationColorFloat, forKey: "userDestinationsTableSaturation")
        
    }
    
    /*
    @IBAction func saveAsDefaultSwitchAction(_ sender: Any) {
        
        if saveAsDefaultSwitchOutlet.isOn {
            
            let hueColorFloat = Float(hueColor)
            UserDefaults.standard.set(hueColorFloat, forKey: "userDestinationsTableHue")
            
            let saturationColorFloat = Float(saturationColor)
            UserDefaults.standard.set(saturationColorFloat, forKey: "userDestinationsTableSaturation")
            
            saveLabel.text = "Saved"
        } else {
            saveLabel.text = "Save as Default?"
        }
        
    }
 
 */

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

