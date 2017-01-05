//
//  MapVC.swift
//  AppEvent
//
//  Created by Kata Mr on 1/5/17.
//  Copyright © 2017 Kata Mr. All rights reserved.
//

import UIKit

private enum MapSuggestCell:String {
    case MapSuggest = "MapSuggest"
    case MapSuggestCell = "mapSuggestCell"
}

class MapVC: UIViewController {

    @IBOutlet weak var clvSuggest: UICollectionView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // set constraint
        if let navi = navigationController {
            topConstraint.constant = navi.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
            view.layoutIfNeeded()
        }
        
        // set collectionView
        guard let flowLayout = clvSuggest.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let width = clvSuggest.frame.size.height
        flowLayout.itemSize = CGSizeMake(100, width)
        
        flowLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // regist cell
        clvSuggest.registerNib(UINib.init(nibName: MapSuggestCell.MapSuggest.rawValue, bundle: nil), forCellWithReuseIdentifier: MapSuggestCell.MapSuggestCell.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapVC : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("bbbbbbbbb")
        return 10
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MapSuggestCell.MapSuggestCell.rawValue, forIndexPath: indexPath) as! MapSuggest
        
//        cell.setup(indexPath.item)
        print("aaaaaaaaa")
        
        
        return cell
    }
}

extension MapVC : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        print("cccccccc")
    }
}


