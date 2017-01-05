//
//  DetailVC.swift
//  AppEvent
//
//  Created by Kata Mr on 1/3/17.
//  Copyright © 2017 Kata Mr. All rights reserved.
//

import UIKit

class DetailVC: UITabBarController {

    
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSBundle.mainBundle().loadNibNamed("DetailVC", owner: self, options: nil)

        
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func didMoveToPage(controller: UIViewController, index: Int){
        print(index)
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)

    }
    
    @IBAction func searchAction(sender: AnyObject) {
    }
    
}
