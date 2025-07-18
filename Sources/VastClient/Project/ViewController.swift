//
//  ViewController.swift
//  VastClient
//
//  Created by Carlos Luis Seva Llor on 17/7/25.
//

import UIKit

class ViewController: UIViewController {

    private let logTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "VAST Client Test Logs...\n"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addTestButtons()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(logTextView)
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            logTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            buttonStackView.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func addTestButtons() {
        let testFiles = ["Vast4.3_full", "Vast4.2_wrapper", "Vast4.1_ad_verification", "Vast_ad_pods"]
        
        for fileName in testFiles {
            let button = UIButton(type: .system)
            button.setTitle("Parse \(fileName)", for: .normal)
            button.addTarget(self, action: #selector(parseVastTapped(_:)), for: .touchUpInside)
            button.accessibilityIdentifier = fileName // Use identifier to pass the filename
            buttonStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func parseVastTapped(_ sender: UIButton) {
        guard let fileName = sender.accessibilityIdentifier else {
            log("Error: Could not identify which VAST file to parse.")
            return
        }
        
        log("\n--- Attempting to parse \(fileName).xml ---")
        
        guard let url = getVastUrl(for: fileName) else {
            log("Error: Could not find \(fileName).xml in the test assets.")
            return
        }
        
        // Corrected to use the proper VastClient API
        let vastClient = VastClient()
        vastClient.parseVast(withContentsOf: url) { [weak self] (vastModel, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.log("Failure: Parsing failed with error: \(error.localizedDescription)")
                    return
                }
                
                if let model = vastModel {
                    self?.log("Success: Parsed VAST model successfully.")
                    self?.log("VAST Version: \(model.version)")
                    self?.log("Total Ads: \(model.ads.count)")
                    
                    if let firstAd = model.ads.first {
                        self?.log("First Ad ID: \(firstAd.id ?? "N/A")")
                        self?.log("  - Creatives: \(firstAd.creatives.count)")
                        if let firstCreative = firstAd.creatives.first {
                            self?.log("  - First Creative ID: \(firstCreative.id ?? "N/A")")
                            if let adServingId = firstCreative.adServingId {
                                self?.log("  - AdServingId (4.3): \(adServingId)")
                            }
                        }
                        if let adVerifications = firstAd.adVerifications {
                            self?.log("  - Verifications: \(adVerifications.verifications.count)")
                            self?.log("  - Supplemental Verifications (4.3): \(adVerifications.supplementalAdVerifications.count)")
                        }
                    }
                }
                self?.log("Completed.")
            }
        }
    }
    
    private func getVastUrl(for name: String) -> URL? {
        // This assumes the test files are copied into the main app bundle for testing purposes.
        // You'll need to add the test XML files to the "Copy Bundle Resources" build phase of your app target.
        let bundle = Bundle(for: ViewController.self)
        return bundle.url(forResource: name, withExtension: "xml")
    }
    
    private func log(_ message: String) {
        print(message) // Also print to console for easier debugging
        let currentText = logTextView.text ?? ""
        logTextView.text = currentText + message + "\n"
        // Scroll to the bottom
        let range = NSMakeRange(logTextView.text.count - 1, 1)
        logTextView.scrollRangeToVisible(range)
    }
}
