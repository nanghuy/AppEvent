//
//  HomeDetailCell.swift
//  AppEvent
//
//  Created by Kata Mr on 1/3/17.
//  Copyright © 2017 Kata Mr. All rights reserved.
//

import UIKit
import Reactions

class HomeDetailCell: UITableViewCell {
    
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var viewShare: UIView!
    
    func tapLike() {
        print("hahahahahahaah")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(HomeDetailCell.tapLike))
        //        viewLike.addGestureRecognizer(tapGesture)

        // Reaction
        
        let select       = ReactionSelector()
        select.reactions = Reaction.facebook.all
        // Conforming to the ReactionFeedbackDelegate
        select.feedbackDelegate = self
        // React to reaction change
        select.addTarget(self, action: #selector(self.reactionDidChanged(_:)), forControlEvents: .ValueChanged)
        
        let button      = ReactionButton()
        button.frame.size = viewLike.frame.size
        button.backgroundColor = UIColor.whiteColor()
        button.reaction = Reaction.facebook.like
        button.config           = ReactionButtonConfig() {
            $0.iconMarging      = 6
            $0.spacing          = 8
            $0.font             = UIFont(name: "HelveticaNeue", size: 13)
            $0.neutralTintColor = UIColor.lightGrayColor()
            $0.alignment        = .centerLeft
        }
        //        button.addTarget(self, action: #selector(self.reactionDidChanged(_:)), forControlEvents: .TouchUpInside)
        // To attach a selector
        button.reactionSelector = ReactionSelector()
        
        viewLike.addSubview(button)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reactionDidChanged(sender: AnyObject) {
        print("sender:",sender)
    }
}

extension HomeDetailCell: ReactionFeedbackDelegate {
    func reactionFeedbackDidChanged(feedback: ReactionFeedback?) {
        print("feedback",feedback)
    }
}













