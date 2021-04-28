import UIKit

protocol ErrorViewDelegate: class {
    func didPressActionButton()
}

final class MainErrorView: UIView {

    // MARK: - ViewData

    struct ViewData {
        let title: String
        let subtitle: String?
        let buttonTitle: String
    }

    // MARK: - Constants

    private struct Constants {
        struct ContainerView {
            static let leftSpacing: CGFloat = 36
            static let rightSpacing: CGFloat = 36
        }

        struct TitleLabel {
            static let topSpacing: CGFloat = 0
            static let leftSpacing: CGFloat = 0
            static let rightSpacing: CGFloat = 0
            static let minimumHeight: CGFloat = 0
            static let font = UIFont.systemFont(ofSize: 22, weight: .semibold)
            static let textAlignment: NSTextAlignment = .center
            static let textColor = UIColor.counters.primaryText
            static let numberOfLines = 0
        }

        struct SubtitleLabel {
            static let topSpacing: CGFloat = 20
            static let leftSpacing: CGFloat = 0
            static let rightSpacing: CGFloat = 0
            static let minimumHeight: CGFloat = 0
            static let font = UIFont.systemFont(ofSize: 17, weight: .regular)
            static let textAlignment: NSTextAlignment = .center
            static let textColor = UIColor.counters.secondaryText
            static let numberOfLines = 0
        }

        struct ActionButton {
            static let topSpacing: CGFloat = 20
            static let bottomSpacing: CGFloat = 0
            static let backgroundColor = UIColor.counters.accent
            static let textColor = UIColor.counters.buttonText
            static let cornerRadius: CGFloat = 8
            static let font = UIFont.systemFont(ofSize: 17, weight: .bold)
            static let edgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
    }

    // MARK: - Public properties

    weak var delegate: ErrorViewDelegate?

    var viewData: ViewData? {
        didSet {
            updateContent()
        }
    }

    // MARK: - Private properties

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton()

    // MARK: - Initialization

    required init(viewData: ViewData?, delegate: ErrorViewDelegate?) {
        self.viewData = viewData
        self.delegate = delegate
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        configureContainerView()
        configureTitleLabel()
        configureSubtitleLabel()
        configureActionButton()
        updateContent()
    }

    // MARK: - Layout

    private func configureContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.ContainerView.leftSpacing),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.ContainerView.rightSpacing)
        ])
    }

    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        titleLabel.font = Constants.TitleLabel.font
        titleLabel.numberOfLines = Constants.TitleLabel.numberOfLines
        titleLabel.textAlignment = Constants.TitleLabel.textAlignment
        titleLabel.textColor = Constants.TitleLabel.textColor

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.TitleLabel.topSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.TitleLabel.leftSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.TitleLabel.rightSpacing),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.TitleLabel.minimumHeight)
        ])
    }

    private func configureSubtitleLabel() {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)

        subtitleLabel.font = Constants.SubtitleLabel.font
        subtitleLabel.numberOfLines = Constants.SubtitleLabel.numberOfLines
        subtitleLabel.textAlignment = Constants.SubtitleLabel.textAlignment
        subtitleLabel.textColor = Constants.SubtitleLabel.textColor

        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.SubtitleLabel.topSpacing),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.SubtitleLabel.leftSpacing),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.SubtitleLabel.rightSpacing),
            subtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.SubtitleLabel.minimumHeight)
        ])
    }

    private func configureActionButton() {
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(actionButton)

        actionButton.backgroundColor = Constants.ActionButton.backgroundColor
        actionButton.layer.cornerRadius = Constants.ActionButton.cornerRadius
        actionButton.layer.masksToBounds = true
        actionButton.titleLabel?.font = Constants.ActionButton.font
        actionButton.contentEdgeInsets = Constants.ActionButton.edgeInsets
        actionButton.setTitleColor(Constants.ActionButton.textColor, for: .normal)
        actionButton.addTarget(self, action: #selector(didTapActionButton(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Constants.ActionButton.topSpacing),
            actionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.ActionButton.bottomSpacing)
        ])
    }

    // MARK: - Content

    private func updateContent() {
        titleLabel.text = viewData?.title
        subtitleLabel.text = viewData?.subtitle
        actionButton.setTitle(viewData?.buttonTitle, for: .normal)
    }

    // MARK: - Action button

    @objc
    private func didTapActionButton(_ button: UIButton) {
        delegate?.didPressActionButton()
    }
}
