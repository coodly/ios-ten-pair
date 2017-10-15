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

public class ConversationCell: UITableViewCell {
    private(set) var timeLabel: UILabel!
    private(set) var snippetLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 320, height: 44)
        
        timeLabel = UILabel()
        timeLabel.text = "2016-09-12"
        timeLabel.numberOfLines = 1
        timeLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .right
        timeLabel.textColor = .lightGray
        
        snippetLabel = UILabel()
        snippetLabel.numberOfLines = 3
        snippetLabel.font = UIFont.preferredFont(forTextStyle: .body)
        snippetLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        snippetLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [timeLabel, snippetLabel])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        
        let views: [String: AnyObject] = ["stack": stack]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[stack]-(8)-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[stack]-(16)-|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
