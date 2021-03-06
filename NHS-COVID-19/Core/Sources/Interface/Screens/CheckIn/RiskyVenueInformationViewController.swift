//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol RiskyVenueInformationViewControllerInteracting {
    func goHome()
}

extension RiskyVenueInformationViewController {
    public struct ViewModel {
        var venueName: String
        var checkInDate: Date
        
        public init(venueName: String, checkInDate: Date) {
            self.venueName = venueName
            self.checkInDate = checkInDate
        }
    }
}

extension RiskyVenueInformationViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting, viewModel: ViewModel) {
            let title = localize(.checkin_risky_venue_information_title(venue: viewModel.venueName, date: viewModel.checkInDate))
            
            var scrollingViews: [UIView] = [
                UIImageView(.coronaVirus).styleAsDecoration(),
                UILabel().set(text: title).styleAsPageHeader(),
            ]
            
            scrollingViews += localizeAndSplit(.checkin_risky_venue_information_description).map {
                UILabel().set(text: $0).styleAsBody()
            }
            
            super.init(
                scrollingViews: scrollingViews,
                primaryButton: (
                    title: localize(.checkin_risky_venue_information_button_title),
                    action: interactor.goHome
                )
            )
        }
        
    }
}

public class RiskyVenueInformationViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = RiskyVenueInformationViewControllerInteracting
    
    public init(interactor: Interacting, viewModel: ViewModel) {
        super.init(content: Content(interactor: interactor, viewModel: viewModel))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
