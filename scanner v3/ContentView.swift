//
//  ContentView.swift
//  scanner v3
//
//  Created by andrew bell on 31/12/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScannerViewControllerRepresentable()
            .ignoresSafeArea()
    }
}

struct ScannerViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ScannerViewController {
        return ScannerViewController()
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct MockScannerView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Label Scanner")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: UIScreen.main.bounds.height * 0.6)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 10) {
                    ForEach(["Scan Food", "Barcode", "Food label", "Gallery"], id: \.self) { title in
                        VStack {
                            Image(systemName: mockIcon(for: title))
                                .font(.system(size: 24))
                            Text(title)
                                .font(.system(size: 12))
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .padding(.top, 30)
            }
        }
    }
    
    private func mockIcon(for title: String) -> String {
        switch title {
        case "Scan Food": return "viewfinder"
        case "Barcode": return "barcode.viewfinder"
        case "Food label": return "tag"
        case "Gallery": return "photo"
        default: return "questionmark"
        }
    }
}

#Preview {
    MockScannerView()
}
