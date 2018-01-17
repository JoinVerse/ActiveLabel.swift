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
        label.activeElements["func"] = NSRange(location: 5, length: 4)
        label.activeElements["dafuck"] = NSRange(location: 15, length: 4)

        label.customize {
            label.textColor = UIColor.lightGray
            label.font = UIFont.systemFont(ofSize: 18)
            let attributedText = NSMutableAttributedString(string: "This is a post with #multiple #hashtags and a @userhandle.\n Links are also supported like\nvefver vergv erg ergver gver vgerv")
            attributedText.addAttributes([.foregroundColor: UIColor.orange], range: NSRange(location: 5, length: 4))
            attributedText.addAttributes([.foregroundColor: UIColor.blue], range: NSRange(location: 15, length: 4))
            label.textAlignment = .center
            label.attributedText = attributedText
            label.numberOfLines = 0
        }

        label.tapHandler = { (key) in
            print(key)
        }

        view.addSubview(label)
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

