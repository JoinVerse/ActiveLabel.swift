//
//  ViewController.swift
//  ActiveLabelDemo
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import UIKit
import ActiveLabel

class ViewController: UIViewController {
    
    let label = ActiveLabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let customType = ActiveType.custom(pattern: "\\sare\\b") //Looks for "are"
        let customType2 = ActiveType.custom(pattern: "\\sit\\b") //Looks for "it"
        let customType3 = ActiveType.custom(pattern: "\\ssupports\\b") //Looks for "supports"

        label.enabledTypes.append(customType)
        label.enabledTypes.append(customType2)
        label.enabledTypes.append(customType3)
        let id = "1234"
        label.enabledTypes.append(.range(NSRange(location: 5, length: 4), id: id))

        label.urlMaximumLength = 31

        label.customize { label in
            label.text = "This is a post with #multiple\nfunc ccd"
            label.numberOfLines = 0
            label.lineSpacing = 4
            label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
            label.hashtagAttributes = [.foregroundColor: UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)]
            label.mentionAttributes = [.foregroundColor: UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)]
            label.URLAttributes = [.foregroundColor: UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)]
            label.URLSelectedAttributes = [.foregroundColor: UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)]
            label.customAttributes[customType] = [.foregroundColor: UIColor.purple]
            label.customSelectedAttributes[customType] = [.foregroundColor: UIColor.green]
            label.customAttributes[customType2] = [.foregroundColor: UIColor.magenta]
            label.customSelectedAttributes[customType2] = [.foregroundColor: UIColor.green]
            label.rangeAttributes[id] = [.font: UIFont.boldSystemFont(ofSize: 20), .foregroundColor: UIColor.purple]
            label.rangeSelectedAttributes[id] = [.font: UIFont.boldSystemFont(ofSize: 20), .foregroundColor: UIColor.orange]

            label.handleMentionTap { self.alert("Mention", message: $0) }
            label.handleHashtagTap { self.alert("Hashtag", message: $0) }
            label.handleURLTap { self.alert("URL", message: $0.absoluteString) }
            label.handleRangeTap { self.alert("Range", message: $0) }
            label.handleCustomTap(for: customType) { self.alert("Custom type", message: $0) }
            label.handleCustomTap(for: customType2) { self.alert("Custom type", message: $0) }
            label.handleCustomTap(for: customType3) { self.alert("Custom type", message: $0) }
        }

        view.addSubview(label)
        label.backgroundColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 50))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 30))

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alert(_ title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }

}

