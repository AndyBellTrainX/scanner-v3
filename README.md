# Food Scanner App

A Swift-based iOS application that allows users to scan food items, barcodes, and food labels using the FatSecret API for nutritional information.

## Features

- Food item scanning and recognition
- Barcode scanning with nutritional information lookup
- Food label text recognition
- Photo gallery integration
- Real-time camera preview
- Integration with FatSecret API for comprehensive food data

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.0+
- FatSecret API credentials

## Setup

1. Clone the repository
2. Open `scanner v3.xcodeproj` in Xcode
3. Configure your FatSecret API credentials:
   - Sign up for a FatSecret API account at [FatSecret Platform API](https://platform.fatsecret.com)
   - Get your API credentials (Client ID and Client Secret)
   - Open `Config.swift` and replace the placeholder values:
     ```swift
     static let fatSecretClientId = "YOUR_CLIENT_ID_HERE"
     static let fatSecretClientSecret = "YOUR_CLIENT_SECRET_HERE"
     ```
4. Build and run the project

## Usage

1. Launch the app
2. Choose one of the scanning modes:
   - **Scan Food**: Point the camera at a food item for recognition
   - **Barcode**: Scan product barcodes for nutritional information
   - **Food Label**: Capture and process food label text
   - **Gallery**: Select existing photos from your device
3. View the nutritional information and details of the scanned items

## Privacy Permissions

The app requires the following permissions:
- Camera access for scanning
- Photo library access for gallery features

Make sure to grant these permissions when prompted.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- FatSecret API for nutritional data
- Vision framework for image processing
- AVFoundation for camera handling 