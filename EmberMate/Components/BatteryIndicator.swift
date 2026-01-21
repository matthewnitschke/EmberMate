import SwiftUI

struct BatteryIndicator: View {
    let percentage: Int
    let isCharging: Bool
    
    init(percentage: Int, isCharging: Bool = false) {
        self.percentage = min(max(percentage, 0), 100)
        self.isCharging = isCharging
    }
    
    private var fillColor: Color {
        if isCharging {
            return Color(.sRGB, red: 0/255, green: 190/255, blue: 58/255)
        } else if percentage <= 20 {
            return .red
        } else {
            return .white
        }
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ZStack(alignment: .center) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Color.gray.opacity(0.4)
                        fillColor
                            .frame(width: geometry.size.width * CGFloat(percentage) / 100)
                    }
                }
                .cornerRadius(4)
                .frame(width: 30, height:12)
                
                HStack(spacing:0) {
                    if (isCharging) {
                        Text("\(percentage)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 8))
                    } else {
                        Text("\(percentage)")
                            .font(.system(size: 10, weight: .bold))
                            .blendMode(.destinationOut)
                    }
                    
                    
                    
                }
                
            }
            
            
            
            // Battery terminal (bump)
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.4))
                .frame(width: 2, height: 4)
        }
    }
}

// Preview
struct BatteryIndicatorPreview: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 10) {
                
                BatteryIndicator(percentage: 68)
                
                BatteryIndicator(percentage: 100)
                
                BatteryIndicator(percentage: 50)
                
                BatteryIndicator(percentage: 15)
                
                BatteryIndicator(percentage: 75, isCharging: true)
                
                BatteryIndicator(percentage: 100, isCharging: true)
            }
        }
    }
}

#Preview {
    BatteryIndicatorPreview()
}
