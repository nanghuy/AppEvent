/*
 * Reactions
 *
 * Copyright 2016-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit

/**
 A `ReactionButton` object is a control that executes a reaction in response to user interactions.
 
 You can tap a reaction button in order to highlight/unhighlight a reaction. You can also make a long press to the button to display a `ReactionSelector` if you have attached one.
 
 You can configure/skin the button using a `ReactionButtonConfig`.
 */
public final class ReactionButton: UIReactionControl {
    private let iconImageView: UIImageView = Components.reactionButton.facebookLikeIcon()
    private let titleLabel: UILabel        = Components.reactionButton.facebookLikeLabel()
    private lazy var overlay: UIView       = UIView().build {
        $0.clipsToBounds   = false
        $0.backgroundColor = .clearColor()
        $0.alpha           = 0
        
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ReactionButton.dismissReactionSelector)))
    }
    
    /**
     A Boolean value indicating whether the reaction button is in the selected state.
     */
    public override var selected: Bool {
        didSet {
            if !selected && reaction != Reaction.facebook.like {
                reaction = Reaction.facebook.like
                return
            }
            update()
        }
    }
    
    /**
     The reaction button configuration.
     */
    public var config: ReactionButtonConfig = ReactionButtonConfig() {
        didSet { update() }
    }
    
    /**
     The reaction used to build the button.
     
     The reaction `title` fills the button one, and the `alternativeIcon` is used to display the icon. If the `alternativeIcon` is nil, the `icon` is used instead.
     */
    public var reaction = Reaction.facebook.like {
        didSet {
            update()
        }
    }
    
    /**
     The attached selector that the button will use in order to choose a reaction.
     
     There are two ways to display the selector: calling the `presentReactionSelector` method or by doing a long press to the button.
     */
    public var reactionSelector: ReactionSelector? {
        didSet { setupReactionSelect(oldValue) }
    }
    
    // MARK: - Building Object
    
    override func setup() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ReactionButton.tapAction)))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ReactionButton.longPressAction)))
        
        addSubview(iconImageView)
        addSubview(titleLabel)
    }
    
    private func setupReactionSelect(old: ReactionSelector?) {
        if let selector = reactionSelector {
            overlay.addSubview(selector)
        }
        
        old?.removeFromSuperview()
        old?.removeTarget(self, action: #selector(ReactionButton.reactionSelectorTouchedUpInsideAction(_:)), forControlEvents: .TouchUpInside)
        old?.removeTarget(self, action: #selector(ReactionButton.reactionSelectorTouchedUpOutsideAction), forControlEvents: .TouchUpOutside)
        
        reaction = reactionSelector?.reactions.first ?? Reaction.facebook.like
        
        reactionSelector?.addTarget(self, action: #selector(ReactionButton.reactionSelectorTouchedUpInsideAction), forControlEvents: .TouchUpInside)
        reactionSelector?.addTarget(self, action: #selector(ReactionButton.reactionSelectorTouchedUpOutsideAction), forControlEvents: .TouchUpOutside)
    }
    
    // MARK: - Updating Object State
    
    override func update() {
        iconImageView.image = reaction.alternativeIcon ?? reaction.icon
        titleLabel.font     = config.font
        titleLabel.text     = reaction.title
        
        let iconSize   = min(bounds.width - config.spacing, bounds.height) - config.iconMarging * 2
        let titleSize  = titleLabel.sizeThatFits(CGSize(width: bounds.width - iconSize, height: bounds.height))
        var iconFrame  = CGRect(x: 0, y: (bounds.height - iconSize) / 2, width: iconSize, height: iconSize)
        var titleFrame = CGRect(x: iconSize + config.spacing, y: 0, width: titleSize.width, height: bounds.height)
        
        if config.alignment == .right {
            iconFrame.origin.x  = bounds.width - iconSize
            titleFrame.origin.x = bounds.width - iconSize - config.spacing - titleSize.width
        }
        else if config.alignment == .centerLeft || config.alignment == .centerRight {
            let emptyWidth = bounds.width - iconFrame.width - titleLabel.bounds.width - config.spacing
            
            if config.alignment == .centerLeft {
                iconFrame.origin.x  = emptyWidth / 2
                titleFrame.origin.x = emptyWidth / 2 + iconSize + config.spacing
            }
            else {
                iconFrame.origin.x  = emptyWidth / 2 + titleSize.width + config.spacing
                titleFrame.origin.x = emptyWidth / 2
            }
        }
        
        iconImageView.frame = iconFrame
        titleLabel.frame    = titleFrame
        
        UIView.transitionWithView(titleLabel, duration: 0.15, options: .TransitionCrossDissolve, animations: { [unowned self] in
            self.iconImageView.tintColor = self.selected ? self.reaction.color : self.config.neutralTintColor
            self.titleLabel.textColor    = self.selected ? self.reaction.color : self.config.neutralTintColor
            }, completion: nil)
    }
    
    // MARK: - Responding to Gesture Events
    
    
    func tapAction(_ gestureRecognizer: UITapGestureRecognizer) {
        selected = !selected
        
        if selected {
            UIView.animateKeyframesWithDuration(0.3, delay: 0, options: .CalculationModeCubic, animations: { [weak self] in
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5, animations: {
                    self?.iconImageView.transform = CGAffineTransformMakeScale(1.8, 1.8)
                })
                UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
                    self?.iconImageView.transform = CGAffineTransformIdentity
                })
                }, completion: nil)
        }
        
        sendActionsForControlEvents(.TouchUpInside)
    }
    
    private var isLongPressMoved = false
    
    func longPressAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let selector = reactionSelector where selector.reactions.count > 1 else { return }
        
        if gestureRecognizer.state == .Began {
            isLongPressMoved = false
            
            displayReactionSelector(.slideFingerAcross)
        }
        
        if gestureRecognizer.state == .Changed {
            isLongPressMoved = true
            
            selector.longPressAction(gestureRecognizer)
        }
        else if gestureRecognizer.state == .Ended {
            if isLongPressMoved {
                selector.longPressAction(gestureRecognizer)
                
                dismissReactionSelector()
            }
            else {
                selector.feedback = .tapToSelectAReaction
            }
        }
    }
    
    // MARK: - Responding to Select Events
    
    func reactionSelectorTouchedUpInsideAction(_ sender: ReactionSelector) {
        guard let selectedReaction = sender.selectedReaction else { return }
        
        let isReactionChanged = reaction != selectedReaction || !selected
        
        reaction   = selectedReaction
        selected = true
        
        if isReactionChanged {
            sendActionsForControlEvents(.ValueChanged)
        }
        
        dismissReactionSelector()
    }
    
    func reactionSelectorTouchedUpOutsideAction(_ sender: ReactionSelector) {
        dismissReactionSelector()
    }
    
    // MARK: - Presenting Reaction Selectors
    
    /**
     Presents the attached reaction selector.
     
     If no reaction selector is attached, the method does nothing.
     */
    public func presentReactionSelector() {
        displayReactionSelector(.tapToSelectAReaction)
    }
    
    /**
     Dismisses the attached reaction selector that was presented by the button.
     */
    public func dismissReactionSelector() {
        reactionSelector?.feedback = nil
        
        animateOverlay(0, center: CGPoint(x: overlay.bounds.midX, y: overlay.bounds.midY))
    }
    
    private func displayReactionSelector(feedback: ReactionFeedback) {
        guard let selector = reactionSelector, let window = UIApplication.sharedApplication().keyWindow where selector.reactions.count > 1 else { return }
        
        if overlay.superview == nil {
            UIApplication.sharedApplication().keyWindow?.addSubview(overlay)
        }
        
        overlay.frame = CGRect(x:0 , y: 0, width: window.bounds.width, height: window.bounds.height * 2)
        
        let centerPoint = convertPoint(CGPointMake(bounds.midX, 0), toView: nil)
        selector.frame  = selector.boundsToFit()
        
        switch config.alignment {
        case .left:
            selector.center = CGPoint(x: centerPoint.x + (selector.bounds.width - bounds.width) / 2, y: centerPoint.y)
        case .right:
            selector.center = CGPoint(x: centerPoint.x - (selector.bounds.width - bounds.width) / 2, y: centerPoint.y)
        default:
            selector.center = centerPoint
        }
        
        if selector.frame.origin.x - config.spacing < 0 {
            selector.center = CGPoint(x: selector.center.x - selector.frame.origin.x + config.spacing, y: centerPoint.y)
        }
        else if selector.frame.origin.x + selector.frame.width + config.spacing > overlay.bounds.width {
            selector.center = CGPoint(x: selector.center.x - (selector.frame.origin.x + selector.frame.width + config.spacing - overlay.bounds.width), y: centerPoint.y)
        }
        
        selector.feedback = feedback
        
        animateOverlay(1, center: CGPoint(x: overlay.bounds.midX, y: overlay.bounds.midY - selector.bounds.height))
    }
    
    private func animateOverlay(alpha: CGFloat, center: CGPoint) {
        UIView.animateWithDuration(0.1) { [weak self] in
            guard let overlay = self?.overlay else { return }
            
            overlay.alpha  = alpha
            overlay.center = center
        }
    }
}
