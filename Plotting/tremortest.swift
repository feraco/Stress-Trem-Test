import UIKit
import CoreMotion
import SwiftUI
import AVFoundation
import AVKit

class TremorTestViewController: UIViewController {
    var audioPlayer: AVPlayer?

    let binauralBeats = [
        "Chakra": "https://ia601608.us.archive.org/25/items/DeltaBox/Chakra.mp3",  // Replace with actual URLs
        "Delta Box": "https://archive.org/download/DeltaBox/DeltaBox.mp3",
        "Alpha Box": "https://archive.org/download/DeltaBox/alpha.mp3",
        "Euphoria Box": "https://archive.org/download/DeltaBox/EuphoriaBox.mp3",
              "Healing Beats Sampler": "https://archive.org/download/DeltaBox/HealingBeatsSampler.mp3",
              "Solfeggio-All": "https://archive.org/download/DeltaBox/Solfeggio-All.mp3",
              "Through The Mind": "https://archive.org/download/DeltaBox/ThroughTheMind.mp3",
              "Alpha": "https://archive.org/download/DeltaBox/alpha.mp3",
              "OOB": "https://archive.org/download/DeltaBox/oob.mp3"
        // ... add other audio files here ...
    ]
    var label: UILabel!
    
    let motionManager = CMMotionManager()
    var accelerometerData: [Double] = []
    var timer: Timer?
    
    // Create a UIHostingController property to hold your SwiftUI view
    var lineChartHostingController: UIHostingController<LineChartView>?
    var lineCharttenHostingController: UIHostingController<LineChartViewten>?
    
    var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
       // presentAudioSelection()

        
      //  startTremorTest()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Present the audio selection alert after the view appears
        presentAudioSelection()
    }

    func presentAudioSelection() {
           // Present a simple selection interface for audio files
           // This is a placeholder - you'll need to create a proper UI for this
           let alert = UIAlertController(title: "Select Binaural Beat", message: nil, preferredStyle: .actionSheet)
           for (name, url) in binauralBeats {
               alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                   self.playAudioFromURL(url)
               }))
           }
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
           present(alert, animated: true)
       }

    func playAudioFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let customPlayerViewController = CustomPlayerViewController()
        customPlayerViewController.playAudioFromURL(url)
        customPlayerViewController.startTremorTestAction = { [weak self] in
            self?.dismiss(animated: true) {
                self?.startTremorTest()
            }
        }

        present(customPlayerViewController, animated: true, completion: nil)
    }

    @objc func audioDidFinishPlaying() {
        // Remove observer
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        // Dismiss the AVPlayerViewController if needed
        dismiss(animated: true, completion: nil)
        
        // Start the tremor test
        startTremorTest()
    }

    func startTremorTest() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
                if let data = data {
                    let magnitude = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
                    self?.accelerometerData.append(magnitude)
                }
            }
            
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stopTremorTest), userInfo: nil, repeats: false)
        } else {
            print("Accelerometer is not available")
        }
        let image = UIImage(named: "tremortest4a")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        // Add imageView to view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        // Set up constraints for the imageView
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),  // set a fixed width
            imageView.heightAnchor.constraint(equalToConstant: 200),  // set a fixed height
        ])
        
        // Create UILabel with text instructions
        let label = UILabel()
        label.text = "Now hold your phone with your hand extended out at shoulder height."
        label.textColor = .black  // set text color to black
        label.textAlignment = .center
        label.numberOfLines = 0
        // Add label to view
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up constraints for the label
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -8),  // 8 points spacing between label and imageView
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    
    
    
    @objc func stopTremorTest() {
        motionManager.stopAccelerometerUpdates()
        
        // Convert accelerometer data to CGFloat for the LineChart
        let convertedData = accelerometerData.map { CGFloat($0) }
        
        // Create your SwiftUI view
        
        
        // Create a UIHostingController with the SwiftUI view
        lineChartHostingController = UIHostingController(rootView: LineChartView())
        lineCharttenHostingController = UIHostingController(rootView: LineChartViewten())
        
        // Add the UIHostingController as a child view controller
        addChild(lineChartHostingController!)
        addChild(lineCharttenHostingController!)
        
        
        // Add the SwiftUI view to the UIViewController's view
        let hostingView = lineChartHostingController!.view!
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingView)
        
        // Set up constraints for the hosting view
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingView.heightAnchor.constraint(equalToConstant: 200), // reduced height
        ])
        let hostingViewten = lineCharttenHostingController!.view!
        hostingViewten.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingView)
        
        // Set up constraints for the hosting view
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingView.heightAnchor.constraint(equalToConstant: 200), // reduced height
        ])
        
        // Add a label for the stats
        let statsLabel = UILabel()
        statsLabel.numberOfLines = 0
        let statsString = analyzeTremorData()
        statsLabel.text = statsString
        statsLabel.backgroundColor = .black // Set background color to see the label's frame
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statsLabel)
        
        // Set up constraints for the stats label
        NSLayoutConstraint.activate([
            statsLabel.topAnchor.constraint(equalTo: hostingView.bottomAnchor, constant: 8),
            statsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            statsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
        ])
        
        // Print the stats string to the console
        print(statsString)
    }
    
    
    func analyzeTremorData() -> String {
        let averageTremor = accelerometerData.reduce(0, +) / Double(accelerometerData.count)
        
        let variance = accelerometerData.reduce(0) { (sum, value) in
            let deviation = value - averageTremor
            return sum + (deviation * deviation)
        }
        let standardDeviation = sqrt(variance)
        
        let maxTremor = accelerometerData.max() ?? 0
        let minTremor = accelerometerData.min() ?? 0
        
        // Calculate the total power of acceleration
        let totalPowerOfAcceleration = accelerometerData.reduce(0) { sum, value in
            sum + pow(value, 4)
        }
        
        // Other stats calculations...
        
        // Display the stats including total power of acceleration
        let stats = """
        Average Tremor: \(averageTremor)
        Standard Deviation: \(standardDeviation)
        Max Tremor: \(maxTremor)
        Min Tremor: \(minTremor)
        Total Power of Acceleration (M^2/s^4): \(totalPowerOfAcceleration)
        """
        print(stats)
        return stats
    }
}

struct TremorTestView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TremorTestViewController {
        return TremorTestViewController()
    }
    
    func updateUIViewController(_ uiViewController: TremorTestViewController, context: Context) {
        // No code needed here for now
    }
}



struct StatsView: View {
    var averageTremor: Double
    var maxTremor: Double
    var minTremor: Double
    var highIntensityDuration: Double

    var body: some View {
        VStack {
            Text("Tremor Stats")
                .font(.largeTitle)
            CircularGauge(value: averageTremor, maximum: maxTremor, color: .blue)
            Text("Max Tremor: \(maxTremor, specifier: "%.2f")")
            Text("Min Tremor: \(minTremor, specifier: "%.2f")")
            Text("High Intensity Duration: \(highIntensityDuration, specifier: "%.2f") seconds")
        }
        .padding()
    }
}

class CustomPlayerViewController: UIViewController {
    var playerViewController: AVPlayerViewController!
    var startButton: UIButton!
    var startTremorTestAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the AVPlayerViewController
        playerViewController = AVPlayerViewController()
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.bounds
        playerViewController.didMove(toParent: self)

        // Initialize the Start Tremor Test button
        setupStartButton()
    }

    func setupStartButton() {
        startButton = UIButton(type: .system)
        startButton.setTitle("Start Tremor Test", for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func startButtonTapped() {
        DispatchQueue.main.async {
            self.startTremorTestAction?()
        }
    }

    func playAudioFromURL(_ url: URL) {
        DispatchQueue.main.async {
            let player = AVPlayer(url: url)
            self.playerViewController.player = player
            player.play()
        }
    }
}


struct CircularGauge: View {
    var value: Double
    var maximum: Double
    var color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.value / self.maximum, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            
            Text(String(format: "%.2f", min(self.value, self.maximum)))
                .font(.system(size: 50.0))
                .bold()
                .foregroundColor(color)
        }
        .frame(width: 200, height: 200)
    }
}
