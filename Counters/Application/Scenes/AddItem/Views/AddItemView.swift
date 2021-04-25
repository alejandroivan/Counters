import UIKit

final class AddItemView: UIView {

    // MARK: - View Data

    struct ViewData {
        /// The text that will be filled in the text field on init.
        let text: String?
        /// The placeholder text for the text field.
        let placeholderText: String?
        /// The subtitle attributed string (with the link to examples)
        let subtitle: NSAttributedString?
        /// Defines if the activity indicator inside the text field should be animating or not.
        let isAnimating: Bool

        init(
            text: String? = nil,
            placeholderText: String?,
            subtitle: NSAttributedString? = nil,
            isAnimating: Bool = false
        ) {
            self.text = text
            self.placeholderText = placeholderText
            self.subtitle = subtitle
            self.isAnimating = isAnimating
        }
    }

    // MARK: - Constants

    private struct Constants {
        static let backgroundColor = UIColor.counters.background

        struct StackView {
            static let insets = UIEdgeInsets(top: 25, left: 12, bottom: 25, right: 12)
            static let interItemSpacing: CGFloat = 13
        }

        struct TextField {
            static let placeholder = "ADD_ITEM_PLACEHOLDER".localized
        }

        struct Subtitle {
            static let font = UIFont.systemFont(ofSize: 15, weight: .regular)
            static let textColor = UIColor.counters.secondaryText
            static let insets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }
    }

    // MARK: - Properties

    var viewData: ViewData? {
        didSet {
            updateContent()
        }
    }

    weak var delegate: AddItemViewDelegate?

    // MARK: - Subviews

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = Constants.StackView.interItemSpacing
        return stackView
    }()

    private lazy var textField: ProgressIndicatorTextField = {
        let viewData = ProgressIndicatorTextField.ViewData(
            text: self.viewData?.text,
            placeholderText: self.viewData?.placeholderText,
            isAnimating: false
        )
        let textField = ProgressIndicatorTextField(viewData: viewData)
        return textField
    }()

    private let subtitleContainer = UIView()

    private lazy var subtitleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = Constants.Subtitle.font
        button.titleLabel?.textColor = Constants.Subtitle.textColor
        button.contentHorizontalAlignment = .left
        button.setAttributedTitle(viewData?.subtitle, for: .normal)
        button.addTarget(self, action: #selector(didPressExamples), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    /// Initializes the view using the data provided to it by the view controller.
    /// We'll call this "view data", since "view models" usually have business logic involved.
    /// This "view data" should be dumb.
    /// - Parameter viewData: The data that's being passed by the view controller for drawing the view.
    init(viewData: ViewData, delegate: AddItemViewDelegate? = nil) {
        super.init(frame: .zero)
        self.viewData = viewData
        self.delegate = delegate
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        // If this was added using AutoLayout, then we would need to do the following:
        // translatesAutoresizingMaskIntoConstraints = false
        // But since the view is replacing the default view of the view controller,
        // then it will be configured by the system using Springs & Struts, so we should
        // allow to translate the autoresizing mask automatically.

        backgroundColor = Constants.backgroundColor
        configureSubtitle()
        configureStackView()
    }

    private func configureSubtitle() {
        subtitleContainer.translatesAutoresizingMaskIntoConstraints = false
        subtitleContainer.addSubview(subtitleButton)

        let insets = Constants.Subtitle.insets
        NSLayoutConstraint.activate([
            subtitleButton.topAnchor.constraint(equalTo: subtitleContainer.topAnchor, constant: insets.top),
            subtitleButton.bottomAnchor.constraint(equalTo: subtitleContainer.bottomAnchor, constant: -insets.bottom),
            subtitleButton.leadingAnchor.constraint(equalTo: subtitleContainer.leadingAnchor, constant: insets.left),
            subtitleButton.trailingAnchor.constraint(equalTo: subtitleContainer.trailingAnchor, constant: -insets.right)
        ])
    }

    private func configureStackView() {
        addSubview(stackView)

        let insets = Constants.StackView.insets
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -insets.bottom),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)
        ])

        arrangedSubviews.forEach { stackView.addArrangedSubview($0) }
    }

    // MARK: - Private


    /// Defines the views that should be added as arranged views
    /// into the stackView.
    private var arrangedSubviews: [UIView] {
        [
            textField,
            subtitleContainer
        ]
    }

    private func updateContent() {
        let textFieldViewData = ProgressIndicatorTextField.ViewData(
            text: textField.text ?? viewData?.text,
            placeholderText: viewData?.placeholderText,
            isAnimating: false
        )
        textField.viewData = textFieldViewData
        subtitleButton.setAttributedTitle(viewData?.subtitle, for: .normal)

        if viewData?.isAnimating == true {
            startAnimating()
        } else {
            stopAnimating()
        }
    }

    @objc
    func didPressExamples() {
        delegate?.didPressExamples()
    }

    // MARK: - Public interface

    public func startAnimating() {
        textField.startAnimating()
        delegate?.progressIndicatorTextField(textField, isAnimating: true)
    }

    public func stopAnimating() {
        textField.stopAnimating()
        delegate?.progressIndicatorTextField(textField, isAnimating: false)
    }

    public var isAnimating: Bool { textField.isAnimating }
}
