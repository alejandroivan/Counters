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
        }

        struct TextField {
            static let placeholder = "ADD_ITEM_PLACEHOLDER".localized
        }
    }

    // MARK: - Properties

    var viewData: ViewData? {
        didSet {
            updateContent()
        }
    }

    // MARK: - Subviews

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var textField: ProgressIndicatorTextField = {
        let viewData = ProgressIndicatorTextField.ViewData(
            placeholderText: self.viewData?.placeholderText,
            isAnimating: false
        )
        let textField = ProgressIndicatorTextField(viewData: viewData)
        return textField
    }()

    // MARK: - Initialization

    /// Initializes the view using the data provided to it by the view controller.
    /// We'll call this "view data", since "view models" usually have business logic involved.
    /// This "view data" should be dumb.
    /// - Parameter viewData: The data that's being passed by the view controller for drawing the view.
    init(viewData: ViewData) {
        super.init(frame: .zero)
        self.viewData = viewData
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
        configureStackView()
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

        stackView.addArrangedSubview(textField)
    }

    // MARK: - Private

    private func updateContent() {
        textField.placeholder = viewData?.placeholderText
        textField.text = textField.text ?? viewData?.text
//        subtitleLabel.attributedText = viewData?.subtitle

        if viewData?.isAnimating == true {
            textField.startAnimating()
        } else {
            textField.stopAnimating()
        }
    }

    // MARK: - Public interface

    public func startAnimating() {
        textField.startAnimating()
    }

    public func stopAnimating() {
        textField.stopAnimating()
    }

    public var isAnimating: Bool { textField.isAnimating }
}
