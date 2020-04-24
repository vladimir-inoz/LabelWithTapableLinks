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
    
    @IBOutlet private weak var shortOneLineTextLabel: TapableLinkLabel!
    @IBOutlet private weak var longOneLineTextLabel: TapableLinkLabel!
    @IBOutlet private weak var multilineLabel: TapableLinkLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shortText = NSMutableAttributedString(string: "Hello! This is link")
        _ = shortText.setAsLink(textToFind: "link", linkURL: "https://www.google1.com")
        shortOneLineTextLabel.attributedText = shortText
        
        let longText = NSMutableAttributedString(string: "Lorem ipsum dolor sit amet, link consectetur adipiscing elit")
        _ = longText.setAsLink(textToFind: "link", linkURL: "https://www.google2.com")
        longOneLineTextLabel.attributedText = longText
        
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
        _ = multilineText.setAsLink(textToFind: "link", linkURL: "https://www.google3.com")
        multilineLabel.attributedText = multilineText
    }


}

extension ViewController: TapableLinkLabelDelegate {
    func tapableLinkLabel(_ label: TapableLinkLabel, openString string: String) {
        print("String link \(string)")
    }
    
    func tapableLinkLabel(_ label: TapableLinkLabel, openURL url: URL) {
        print("URL link \(url)")
    }
    
    
}

