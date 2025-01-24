import Foundation
import AVFoundation
import UIKit

enum Config {
    // MARK: - FatSecret API Configuration
    static let fatSecretClientId = "621a500792004b78ad6076d3b1891c91"
    static let fatSecretClientSecret = "112caad01c53457099e27261edf9d8b0"
    
    // MARK: - App Configuration
    static let supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [
        .ean8,
        .ean13,
        .upce,
        .code39,
        .code39Mod43,
        .code93,
        .code128,
        .interleaved2of5,
        .itf14,
        .pdf417
    ]
    
    // MARK: - UI Configuration
    static let primaryColor = UIColor.systemBlue
    static let secondaryColor = UIColor.white
    static let backgroundColor = UIColor.black
    
    // MARK: - Camera Configuration
    static let defaultCameraPosition: AVCaptureDevice.Position = .back
    static let preferredCameraQuality: AVCaptureSession.Preset = .high
    
    // MARK: - Vision Configuration
    static let minimumTextConfidence: Float = 0.5
    static let minimumBarcodeConfidence: Float = 0.8
} 