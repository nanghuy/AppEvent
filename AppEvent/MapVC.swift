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

    @IBOutlet weak var clvSuggestMap: UICollectionView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // set constraint
        if let navi = navigationController {
            topConstraint.constant = navi.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height+100
            view.layoutIfNeeded()
        }
        
        // set collectionView
        guard let flowLayout = clvSuggestMap.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let height = clvSuggestMap.frame.size.height
        print("height",height)
        flowLayout.itemSize = CGSize(width: height, height: height)
        
        flowLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // regist cell
        //clvSuggestMap.registerNib(UINib.init(nibName: MapSuggestCell.MapSuggest.rawValue, bundle: nil), forCellWithReuseIdentifier: MapSuggestCell.MapSuggestCell.rawValue)
        clvSuggestMap.register(UINib.init(nibName: "SearchCell", bundle: nil), forCellWithReuseIdentifier: "searchCell")
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("bbbbbbbbb")
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MapSuggestCell.MapSuggestCell.rawValue, forIndexPath: indexPath) as! MapSuggest
//        
//        cell.setup(2)
//        print("aaaaaaaaa")
//        
//        
//        return cell
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCell
        
        return cell
    }
}

extension MapVC : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("cccccccc")
    }
}


