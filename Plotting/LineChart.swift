import CoreMotion
import SwiftUI
// ViewModel that handles the CoreMotion logic
class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var accelerometerData: [CGFloat] = []
    @Published var lastTenSecondsData: [CGFloat] = []

    init() {
        startAccelerometer()
    }

    func startAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                guard let data = data else {
                    print("Error: \(error!)")
                    return
                }
                
                let x = CGFloat(data.acceleration.x)
                self?.accelerometerData.append(x)
                
                // Keep the array to a fixed size
                if self?.accelerometerData.count ?? 0 > 1000 {  // Increased size to capture more data
                    self?.accelerometerData.removeFirst()
                }
            }
        }
    }

    func stopAccelerometer() {
        motionManager.stopAccelerometerUpdates()
        
        // Capture the last 10 seconds of data
        lastTenSecondsData = Array(accelerometerData.suffix(600))  // Get the last 600 data points
    }
}

struct LineChartViewten: View {
    @StateObject private var motionManager = MotionManager()
    let settings = SettingsStruct()  // Replace with your specific instance of SettingsStruct

    var body: some View {
        LineChart(
            data: [motionManager.accelerometerData],
            color: [.blue],
            min: 0,
            max: 1,
            horizontalGridLines: 0,
            verticalGridLines: 0,
            blackAndWhite: false,
            settings: settings
        )
            .onAppear {
                motionManager.startAccelerometer()
            }
    }
}
struct LineChartView: View {
    @StateObject private var motionManager = MotionManager()
    let settings = SettingsStruct()  // Replace with your specific instance of SettingsStruct

    var lastTenSecondsData: [CGFloat] {
        let data = motionManager.accelerometerData
        return Array(data.suffix(600))  // Get the last 600 data points
    }

    var body: some View {
        LineChart(
            data: [lastTenSecondsData],
            color: [.blue],
            min: 0,
            max: 1,
            horizontalGridLines: 0,
            verticalGridLines: 0,
            blackAndWhite: false,
            settings: settings
        )
        .onAppear {
            motionManager.startAccelerometer()
        }
    }
}

struct LineChart: View {
    var data: [[CGFloat?]]
    var color: [Color]
    var min: CGFloat = 0
    var max: CGFloat = 0
    var horizontalGridLines: Int = 0
    var verticalGridLines: Int = 0
    var blackAndWhite: Bool = false
    var settings: SettingsStruct

    init(data: [[CGFloat?]], color: [Color], min: CGFloat = 0, max: CGFloat = 4, horizontalGridLines: Int = 0, verticalGridLines: Int = 0, blackAndWhite: Bool = false, settings: SettingsStruct) {
        self.data = data
        self.color = color
        self.min = min
        self.max = max
        self.horizontalGridLines = horizontalGridLines
        self.verticalGridLines = verticalGridLines
        self.blackAndWhite = blackAndWhite
        self.settings = settings

        if blackAndWhite {
            self.color = [.black, .black, .black, .black]
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid
                Path { path in
                    let horizontalGridStep: CGFloat = geometry.size.height / (CGFloat(horizontalGridLines) + 1.0)
                    let verticalGridStep: CGFloat = geometry.size.width / (CGFloat(verticalGridLines) + 1.0)

                    // Vertical gridlines
                    for i in 0 ... (verticalGridLines + 1) {
                        path.move(to: CGPoint(x: i * Int(verticalGridStep),
                                              y: 0))
                        path.addLine(to: CGPoint(x: i * Int(verticalGridStep),
                                                 y: Int(geometry.size.height)))
                    }

                    // Horizontal gridlines
                    for i in 0 ... (horizontalGridLines + 1) {
                        path.move(to: CGPoint(x: 0,
                                              y: i * Int(horizontalGridStep)))
                        path.addLine(to: CGPoint(x: Int(geometry.size.width),
                                                 y: i * Int(horizontalGridStep)))
                    }

                    path.closeSubpath()
                }.stroke(themes[settings.theme].gridColor, lineWidth: 1)

                // Graph
                ForEach(0 ..< data.count, id: \.self) { graph in
                    Path { path in
                        let thisData = data[graph]
                        var first: Bool = true
                        for i in 0 ..< thisData.count {
                            let xPos: CGFloat = CGFloat(i) * (CGFloat(geometry.size.width) / CGFloat(thisData.count - 1))
                            var yPos: CGFloat?
                            if thisData[i] != nil {
                                yPos = CGFloat(geometry.size.height) - (thisData[i]! - min) * CGFloat(geometry.size.height) / (max - min)
                            }

                            if yPos != nil {
                                if first {
                                    path.move(to: CGPoint(x: xPos, y: yPos!))
                                    first = false
                                } else {
                                    path.addLine(to: CGPoint(x: xPos, y: yPos!))
                                }
                            }
                        }
                    }.stroke(self.color[graph].opacity(lineChartOpacity), lineWidth: 2)
                }
            }
        }//.frame(height: 170)
    }
}
