/*
 * Copyright 2016 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit

private let NormalSpacing: CGFloat = 16
private let AlignmentSpacing: CGFloat = 50

enum MessageAlignment {
    case left
    case right
}

internal class MessageCell: UITableViewCell {
    private(set) var timeLabel: UILabel!
    private(set) var messageLabel: UILabel!
    private var stack: UIStackView!
    private var leftSpacing: NSLayoutConstraint!
    private var rightSpacing: NSLayoutConstraint!
    var alignment: MessageAlignment = .left {
        didSet {
            switch alignment {
            case .left:
                leftSpacing.constant = NormalSpacing
                rightSpacing.constant = AlignmentSpacing
                timeLabel.textAlignment = .left
            case .right:
                leftSpacing.constant = AlignmentSpacing
                rightSpacing.constant = NormalSpacing
                timeLabel.textAlignment = .right
            }
        }
    }
    private var bubbleBackground: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        bubbleBackground = UIView()
        bubbleBackground.layer.cornerRadius = 5
        bubbleBackground.backgroundColor = UIColor(white: 0.95, alpha: 1)
        bubbleBackground.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        timeLabel.numberOfLines = 1
        timeLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        timeLabel.setContentHuggingPriority(.required, for: .vertical)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel = UILabel()
        messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
        messageLabel.numberOfLines = 0
        messageLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        messageLabel.setContentHuggingPriority(.required, for: .vertical)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stack = UIStackView(arrangedSubviews: [timeLabel, messageLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bubbleBackground)
        contentView.addSubview(stack)
        
        contentView.addConstraint(NSLayoutConstraint(item: bubbleBackground, attribute: .right, relatedBy: .equal, toItem: stack, attribute: .right, multiplier: 1, constant: 5))
        contentView.addConstraint(NSLayoutConstraint(item: bubbleBackground, attribute: .top, relatedBy: .equal, toItem: stack, attribute: .top, multiplier: 1, constant: -5))
        contentView.addConstraint(NSLayoutConstraint(item: bubbleBackground, attribute: .left, relatedBy: .equal, toItem: stack, attribute: .left, multiplier: 1, constant: -5))
        contentView.addConstraint(NSLayoutConstraint(item: bubbleBackground, attribute: .bottom, relatedBy: .equal, toItem: stack, attribute: .bottom, multiplier: 1, constant: 5))
        
        let views: [String: AnyObject] = ["stack": stack, "time": timeLabel, "message": messageLabel]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[stack]-(8)-|", options: [], metrics: nil, views: views))
        let spacings = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[stack]-(20)-|", options: [], metrics: nil, views: views)
        // hacky stuff :x
        leftSpacing = spacings.filter({ $0.constant < 11 }).first!
        rightSpacing = spacings.filter({ $0.constant > 19 }).first!
        contentView.addConstraints(spacings)
        
        stack.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[time(>=0)]", options: [], metrics: nil, views: views))
        stack.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[message(>=0)]", options: [], metrics: nil, views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
