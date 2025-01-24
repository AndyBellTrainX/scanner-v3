import UIKit
import AVFoundation
import Vision

class ScannerViewController: UIViewController {
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let fatSecretAPI = FatSecretAPI(clientId: Config.fatSecretClientId, clientSecret: Config.fatSecretClientSecret)
    private var currentMode: ScanMode = .food
    private var isShowingAlert = false
    
    enum ScanMode {
        case food
        case barcode
        case label
    }
    
    // UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Label Scanner"
        label.textColor = Config.secondaryColor
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let cameraView: UIView = {
        let view = UIView()
        view.backgroundColor = Config.backgroundColor
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            createButton(title: "Scan Food", image: "viewfinder", action: #selector(scanFoodTapped)),
            createButton(title: "Barcode", image: "barcode.viewfinder", action: #selector(barcodeTapped)),
            createButton(title: "Food label", image: "tag", action: #selector(foodLabelTapped)),
            createButton(title: "Gallery", image: "photo", action: #selector(galleryTapped))
        ])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10
        return stack
    }()
    
    private let captureButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.red.withAlphaComponent(0.2).cgColor
        button.addTarget(nil, action: #selector(captureButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermission()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupUI()
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupUI()
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            let alert = UIAlertController(
                title: "Camera Access Required",
                message: "Please grant camera access in Settings to use the scanner features.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        @unknown default:
            break
        }
    }
    
    private func setupUI() {
        view.backgroundColor = Config.backgroundColor
        
        // Add and configure subviews
        view.addSubview(titleLabel)
        view.addSubview(cameraView)
        view.addSubview(buttonStack)
        view.addSubview(captureButton)
        
        // Layout constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cameraView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cameraView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            buttonStack.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -30),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func createButton(title: String, image: String, action: Selector) -> UIButton {
        let button = UIButton(configuration: .plain())
        
        // Create configuration
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: image)
        config.imagePlacement = .top
        config.imagePadding = 8
        config.baseForegroundColor = .black
        config.background.backgroundColor = .white
        config.background.cornerRadius = 10
        
        // Apply configuration
        button.configuration = config
        
        // Set font
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12)
        button.configuration?.attributedTitle = AttributedString(title, attributes: container)
        
        // Add target
        button.addTarget(nil, action: action, for: .touchUpInside)
        
        // Set size constraints
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        return button
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = Config.preferredCameraQuality
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                      for: .video,
                                                      position: Config.defaultCameraPosition),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // Setup preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        
        // Start capture session
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func scanFoodTapped() {
        currentMode = .food
        titleLabel.text = "Scan Food"
    }
    
    @objc private func barcodeTapped() {
        currentMode = .barcode
        titleLabel.text = "Scan Barcode"
    }
    
    @objc private func foodLabelTapped() {
        currentMode = .label
        titleLabel.text = "Scan Food Label"
    }
    
    @objc private func galleryTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @objc private func captureButtonTapped() {
        // Handle capture based on current mode
        switch currentMode {
        case .food:
            // Take photo and process with Vision for food recognition
            break
        case .barcode:
            // Already continuously scanning for barcodes
            break
        case .label:
            // Take photo and process with Vision for text recognition
            break
        }
    }
    
    private func processBarcode(_ barcode: String) {
        Task {
            do {
                // Use the barcode to search for food
                let foods = try await fatSecretAPI.searchFood(query: barcode)
                
                if let food = foods.first {
                    // Show food details
                    let details = try await fatSecretAPI.getFoodById(id: food.food_id)
                    DispatchQueue.main.async {
                        self.showFoodDetails(details)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showError("No food found for this barcode")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func showFoodDetails(_ food: FoodDetails) {
        guard !isShowingAlert else { return }
        isShowingAlert = true
        
        let alert = UIAlertController(title: food.food_name, message: nil, preferredStyle: .actionSheet)
        
        if let serving = food.servings.serving.first {
            let details = """
                Calories: \(serving.calories)
                Protein: \(serving.protein ?? "N/A")
                Carbs: \(serving.carbohydrate ?? "N/A")
                Fat: \(serving.fat ?? "N/A")
                Serving: \(serving.serving_description)
                """
            alert.message = details
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.isShowingAlert = false
        })
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        guard !isShowingAlert else { return }
        isShowingAlert = true
        
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.isShowingAlert = false
        })
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraView.bounds
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard currentMode == .barcode,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let results = request.results as? [VNBarcodeObservation],
                  let barcode = results.first,
                  barcode.confidence >= Config.minimumBarcodeConfidence,
                  let barcodeValue = barcode.payloadStringValue else {
                return
            }
            
            DispatchQueue.main.async {
                self?.processBarcode(barcodeValue)
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ScannerViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        // Process the selected image based on current mode
        switch currentMode {
        case .food:
            // Process image for food recognition
            break
        case .barcode:
            // Process image for barcode
            if let cgImage = image.cgImage {
                let request = VNDetectBarcodesRequest { [weak self] request, error in
                    guard let results = request.results as? [VNBarcodeObservation],
                          let barcode = results.first?.payloadStringValue else {
                        return
                    }
                    self?.processBarcode(barcode)
                }
                try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
            }
        case .label:
            // Process image for text recognition
            break
        }
    }
} 