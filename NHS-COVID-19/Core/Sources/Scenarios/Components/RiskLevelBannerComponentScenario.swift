//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Integration
import Interface
import SwiftUI
import UIKit

public class RiskLevelBannerComponentScenario: Scenario {
    
    public static let name = "Risk Level Banner"
    public static let kind = ScenarioKind.component
    
    enum Showcases: CaseIterable {
        case lowRisk
        case mediumRisk
        case highRisk
        
        func content() -> RiskLevelBanner.ViewModel {
            switch self {
            case .lowRisk:
                return RiskLevelBanner.ViewModel(postcode: .init("SW12"), risk: .v1(.low))
            case .mediumRisk:
                return RiskLevelBanner.ViewModel(postcode: .init("SW12"), risk: .v1(.medium))
            case .highRisk:
                return RiskLevelBanner.ViewModel(postcode: .init("SW12"), risk: .v1(.high))
            }
        }
    }
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: RiskLevelBannerView()))
    }
}

private struct RiskLevelBannerView: View {
    
    @State var preferredColourScheme: ColorScheme? = nil
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    fileprivate init() {}
    
    var body: some View {
        NavigationView {
            List(RiskLevelBannerComponentScenario.Showcases.allCases, id: \.index) {
                RiskLevelBanner(viewModel: $0.content(), tapAction: { _ in })
                
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("RiskLevelBanner")
            
        }
        .preferredColorScheme(preferredColourScheme)
        
    }
    
    private var toggleColorSchemeButton: some View {
        Button(action: self.toggleColorScheme) {
            Image(systemName: colorScheme == .dark ? "moon.circle.fill" : "moon.circle")
                .frame(width: 44, height: 44)
        }
    }
    
    private func toggleColorScheme() {
        switch colorScheme {
        case .dark:
            preferredColourScheme = .light
        default:
            preferredColourScheme = .dark
        }
    }
}
