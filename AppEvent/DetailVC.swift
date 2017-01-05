//
//  DetailVC.swift
//  AppEvent
//
//  Created by Kata Mr on 1/3/17.
//  Copyright © 2017 Kata Mr. All rights reserved.
//

import UIKit

class DetailVC: UITabBarController {

    @IBOutlet weak var viewPageView: UIView!
    
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true
        
        
        var controllerArray : [UIViewController] = []
        
        let controller1 : DetailAboutVC = DetailAboutVC(nibName: "DetailAboutVC", bundle: nil)
        controller1.title = "About"
        controllerArray.append(controller1)
        let controller2 : DetailDescriptonVC = DetailDescriptonVC(nibName: "DetailDescriptonVC", bundle: nil)
        controller2.title = "Descripton"
        controllerArray.append(controller2)
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)),
            .ViewBackgroundColor(UIColor(red: 211/255.0, green: 165/255.0, blue: 166/255.0, alpha: 1.0)),
            .SelectionIndicatorColor(UIColor(red: 211/255.0, green: 165/255.0, blue: 166/255.0, alpha: 1.0)),
            .BottomMenuHairlineColor(UIColor(red: 211/255.0, green: 165/255.0, blue: 166/255.0, alpha: 1.0)),
            .MenuItemFont(UIFont(name: "HelveticaNeue", size: 13.0)!),
            .UnselectedMenuItemLabelColor(UIColor.darkGrayColor()),
            .SelectedMenuItemLabelColor(UIColor(red: 211/255.0, green: 165/255.0, blue: 166/255.0, alpha: 1.0)),
            .MenuHeight(40.0),
            .CenterMenuItems(true)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: viewPageView.frame, pageMenuOptions: parameters)
        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
