//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Integration
import Interface
import UIKit

internal protocol HomeScreenScenario: Scenario {
    static var riskyPostcodeEnabled: Bool { get }
    static var checkInEnabled: Bool { get }
    static var showOrderTestButton: Bool { get }
    static var shouldShowSelfDiagnosis: Bool { get }
}

extension HomeScreenScenario {
    
    static func postcodeViewModel(parent: UIViewController) -> RiskLevelBanner.ViewModel? {
        if Self.riskyPostcodeEnabled {
            return RiskLevelBanner.ViewModel(postcode: .init("SW12"), risk: .v1(.low))
        } else {
            return nil
        }
    }
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            
            let exposureNotificationsEnabled = CurrentValueSubject<Bool, Never>(true)
            
            return HomeViewController(
                interactor: Interactor(
                    viewController: parent,
                    checkInEnabled: checkInEnabled,
                    setExposureNotifcationEnabled: { enabled in
                        exposureNotificationsEnabled.send(enabled)
                    }
                ),
                riskLevelBannerViewModel: .constant(postcodeViewModel(parent: parent)),
                isolationViewModel: RiskLevelIndicator.ViewModel(isolationState: .constant(.notIsolating), paused: .constant(false)),
                exposureNotificationsEnabled: exposureNotificationsEnabled.removeDuplicates().eraseToAnyPublisher(),
                showOrderTestButton: .constant(showOrderTestButton),
                shouldShowSelfDiagnosis: .constant(shouldShowSelfDiagnosis),
                userNotificationsEnabled: .constant(false),
                country: .constant(.england)
            )
        }
    }
}

public class SuccessHomeScreenScenario: HomeScreenScenario {
    public static var name = "Home Screen"
    
    public static var kind = ScenarioKind.screen
    
    public static var riskyPostcodeEnabled = true
    public static var selfDiagnosisEnabled: Bool = true
    public static var checkInEnabled: Bool = true
    public static var showOrderTestButton = true
    public static var shouldShowSelfDiagnosis = true
}

public class DisabledFeaturesHomeScreenScenario: HomeScreenScenario {
    public static var name = "Features disabled Homescreen"
    
    public static var kind = ScenarioKind.prototype
    
    public static var riskyPostcodeEnabled = false
    public static var selfDiagnosisEnabled = false
    public static var checkInEnabled: Bool = false
    public static var showOrderTestButton = false
    public static var shouldShowSelfDiagnosis = false
}

public class HomeScreenAlerts {
    public static let diagnosisAlertTitle = "I don't feel well button tapped."
    public static let adviceAlertTitle = "Read current advice button tapped."
    public static let isolationAdviceAlertTitle = "Read isolation advice button tapped."
    public static let checkInAlertTitle = "Check-in into a venue."
    public static let testingInformationAlertTitle = "Testing information button tapped"
    public static let exposureNotificationAlertTitle = "Exposure notifications toggled"
    public static let aboutAlertTitle = "About tapped"
    public static let linkTestResultTitle = "Link test result tapped"
    public static let postcodeBannerAlertTitle = "Postcode banner tapped"
    public static let scheduleNotificationAlertTitle = "Notification scheduled"
}

private class Interactor: HomeViewController.Interacting {
    
    var checkInEnabled: Bool
    var _setExposureNotifcationEnabled: (Bool) -> Void
    
    private weak var viewController: UIViewController?
    
    init(
        viewController: UIViewController,
        checkInEnabled: Bool,
        setExposureNotifcationEnabled: @escaping (Bool) -> Void
    ) {
        self.viewController = viewController
        self.checkInEnabled = checkInEnabled
        _setExposureNotifcationEnabled = setExposureNotifcationEnabled
    }
    
    func didTapRiskLevelBanner(viewModel: RiskLevelInfoViewController.ViewModel) {
        viewController?.showAlert(title: HomeScreenAlerts.postcodeBannerAlertTitle)
    }
    
    func didTapDiagnosisButton() {
        viewController?.showAlert(title: HomeScreenAlerts.diagnosisAlertTitle)
    }
    
    func didTapAdviceButton() {
        viewController?.showAlert(title: HomeScreenAlerts.adviceAlertTitle)
    }
    
    func didTapIsolationAdviceButton() {
        viewController?.showAlert(title: HomeScreenAlerts.isolationAdviceAlertTitle)
    }
    
    func didTapCheckInButton() {
        viewController?.showAlert(title: HomeScreenAlerts.checkInAlertTitle)
    }
    
    func didTapTestingInformationButton() {
        viewController?.showAlert(title: HomeScreenAlerts.testingInformationAlertTitle)
    }
    
    func didTapAboutButton() {
        viewController?.showAlert(title: HomeScreenAlerts.aboutAlertTitle)
    }
    
    func didTapLinkTestResultButton() {
        viewController?.showAlert(title: HomeScreenAlerts.linkTestResultTitle)
    }
    
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never> {
        viewController?.showAlert(title: HomeScreenAlerts.exposureNotificationAlertTitle)
        _setExposureNotifcationEnabled(enabled)
        return Result.success(()).publisher.eraseToAnyPublisher()
    }
    
    public func scheduleReminderNotification(reminderIn: ExposureNotificationReminderIn) {
        viewController?.showAlert(title: HomeScreenAlerts.scheduleNotificationAlertTitle)
    }
    
    var shouldShowCheckIn: Bool {
        checkInEnabled
    }
}
