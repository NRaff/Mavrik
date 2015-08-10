//
//  SettingsViewController.swift
//  SkiBum
//
//  Created by Nick Raff on 8/4/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//

import UIKit
import Mixpanel

class SettingsViewController: UIViewController {

    let mixpanel: Mixpanel = Mixpanel.sharedInstance()
    var metric: Bool = false
    
    @IBOutlet weak var measureSwitch: UISegmentedControl!
    
    @IBOutlet weak var settingsNavBar: UINavigationBar!
    
    @IBOutlet weak var doneItem: UIBarButtonItem!
    
    @IBAction func measureSwitchEvent(sender: AnyObject) {
        if measureSwitch.selectedSegmentIndex == 0 {
            metric = true
            mixpanel.track("Settings", properties: ["Options": "Metric is Selected"])
        }
        else {
            metric = false
            mixpanel.track("Settings", properties: ["Options": "Imperial is Selected"])
        }
        println("\(metric) idk")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Session.measureSwitch {
            measureSwitch.selectedSegmentIndex = 0
        }
        else { measureSwitch.selectedSegmentIndex = 1 }
        
        settingsNavBar.setTitleVerticalPositionAdjustment(-13, forBarMetrics: .Default)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        Session.measureSwitch = metric
        println(metric)
    }

}
