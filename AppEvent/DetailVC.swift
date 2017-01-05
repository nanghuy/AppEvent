//
//  DetailVC.swift
//  AppEvent
//
//  Created by Kata Mr on 1/3/17.
//  Copyright © 2017 Kata Mr. All rights reserved.
//

import UIKit

class DetailVC: UITabBarController {

    @IBOutlet weak var viewAbout: UIView!
    @IBOutlet weak var viewAboutLine: UIView!
    @IBOutlet weak var lbViewAbout: UILabel!
    
    
    @IBOutlet weak var viewDicussion: UIView!
    @IBOutlet weak var viewDiscussionLine: UIView!
    @IBOutlet weak var lbDiscussion: UILabel!
    
    var pageMenu : CAPSPageMenu?
    
    static let selectionBackground = UIColor(red: 255/255, green: 0, blue: 128/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        NSBundle.mainBundle().loadNibNamed("DetailVC", owner: self, options: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(DetailVC.handleTapAbout(_:)))
        viewAbout.addGestureRecognizer(tap)
        
        let tapDis = UITapGestureRecognizer(target: self, action: #selector(DetailVC.handleTapDiscussion(_:)))
        viewDicussion.addGestureRecognizer(tapDis)
    }
    
    func handleTapAbout(sender: UITapGestureRecognizer? = nil) {
        self.viewAboutLine.backgroundColor = UIColor(red: 255/255, green: 0, blue: 128/255, alpha: 1.0)
        self.lbViewAbout.textColor = UIColor(red: 255/255, green: 0, blue: 128/255, alpha: 1.0)
        self.viewDiscussionLine.backgroundColor = UIColor.clearColor()
        self.lbDiscussion.textColor = UIColor.blackColor()
    }
    func handleTapDiscussion(sender: UITapGestureRecognizer? = nil) {
        self.viewDiscussionLine.backgroundColor = UIColor(red: 255/255, green: 0, blue: 128/255, alpha: 1.0)
        self.lbDiscussion.textColor = UIColor(red: 255/255, green: 0, blue: 128/255, alpha: 1.0)
        self.viewAboutLine.backgroundColor = UIColor.clearColor()
        self.lbViewAbout.textColor = UIColor.blackColor()
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
