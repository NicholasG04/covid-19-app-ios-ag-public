//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol ErrorDetail {
    var title: String { get }
    var content: [UIView] { get }
    var imageView: UIImageView? { get }
    var logoStrapLineStyle: LogoStrapline.Style { get }
    var action: (title: String, act: () -> Void)? { get }
}

public extension ErrorDetail {
    var imageView: UIImageView? { nil }
}

open class RecoverableErrorViewController: UIViewController {
    
    // MARK: - Properties
    
    private let error: ErrorDetail
    private var isPrimaryLinkBtn: Bool = false
    
    // MARK: - init
    
    public init(error: ErrorDetail, isPrimaryLinkBtn: Bool = false) {
        self.error = error
        self.isPrimaryLinkBtn = isPrimaryLinkBtn
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Views lifecycle
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let label = UILabel()
        label.styleAsPageHeader()
        
        label.text = error.title
        
        let button = error.action.map { action -> UIView in
            self.isPrimaryLinkBtn ? self.primaryLinkBtn(title: action.title, act: action.act) : self.systemBtn(title: action.title, act: action.act)
        }
        
        let logoStrapline = LogoStrapline(.nhsBlue, style: error.logoStrapLineStyle)
        
        var content = error.content
        content.insert(label, at: 0)
        if let imageView = error.imageView {
            content.insert(imageView, at: 0)
        }
        content.insert(logoStrapline, at: 0)
        
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        stackView.layoutMargins = .standard
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.addFillingSubview(stackView)
        
        view.addAutolayoutSubview(scrollView)
        button.map { view.addAutolayoutSubview($0) }
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            stackView.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor),
        ])
        
        if let button = button {
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
                button.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
                button.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -.standardSpacing).withPriority(.defaultHigh),
            ])
        } else {
            NSLayoutConstraint.activate([
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
        
    }
    
    // MARK: - Actions
    
    @objc private func didTapActionButton() {
        error.action?.act()
    }
    
    // MARK: - Views
    
    private func systemBtn(title: String, act: () -> Void) -> UIView {
        let btn = UIButton(type: .system)
        btn.styleAsPrimary()
        btn.setTitle(title, for: .normal)
        btn.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        return btn
    }
    
    private func primaryLinkBtn(title: String, act: @escaping () -> Void) -> UIView {
        return PrimaryLinkButton(title: title, action: act)
    }
}
