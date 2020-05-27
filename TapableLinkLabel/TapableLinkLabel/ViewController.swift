//
//  ViewController.swift
//  TapableLinkLabel
//
//  Created by Vladimir Inozemtsev on 24.04.2020.
//  Copyright © 2020 Vladimir Inozemtsev. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {

    public func setAsLink(textToFind:String, linkURL:String) -> Bool {

        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}

class ViewController: UIViewController {
    
    @IBOutlet private weak var shortOneLineTextLabel: TapableLabel!
    @IBOutlet private weak var longOneLineTextLabel: TapableLabel!
    @IBOutlet private weak var multilineLabel: TapableLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shortText = NSMutableAttributedString(string: "Hello! This is link")
        shortText.addAttribute(.font, value: UIFont.systemFont(ofSize: 10), range: NSRange(location: 0, length: shortText.length))
        _ = shortText.setAsLink(textToFind: "link", linkURL: "https://www.google1.com")
        shortOneLineTextLabel.textAlignment = .center
        shortOneLineTextLabel.attributedText = shortText
        shortOneLineTextLabel.delegate = self
        shortOneLineTextLabel.isDebug = true
        
        let longText = NSMutableAttributedString(string: "Lorem ipsum dolor sit amet, link consectetur adipiscing elit")
        longText.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: NSRange(location: 0, length: longText.length))
        _ = longText.setAsLink(textToFind: "link", linkURL: "https://www.google2.com")
        longOneLineTextLabel.attributedText = longText
        longOneLineTextLabel.delegate = self
        longOneLineTextLabel.isDebug = true
        
        let multilineText = NSMutableAttributedString(string: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit,
                sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            Aliquet nibh praesent tristique magna sit. Aliquam nulla facilisi cras fermentum odio eu feugiat pretium.
            Porta nibh venenatis cras sed felis eget velit aliquet.
            Consequat nisl vel pretium link lectus quam id leo.
            Eget velit aliquet sagittis id consectetur.
            Tempus egestas sed sed risus pretium quam vulputate.
            Eget gravida cum sociis natoque.
    """)
        multilineText.addAttribute(.font, value: UIFont.systemFont(ofSize: 20), range: NSRange(location: 0, length: multilineText.length))
        _ = multilineText.setAsLink(textToFind: "link", linkURL: "https://www.google3.com")
        multilineLabel.attributedText = multilineText
        multilineLabel.delegate = self
        multilineLabel.isDebug = true
        
        view.layoutIfNeeded()
    }
}

extension ViewController: TapableLabelDelegate {
    func tapableLabel(_ label: TapableLabel, detectedLinkTap link: String) {
        print("String link \(link)")
    }
}

