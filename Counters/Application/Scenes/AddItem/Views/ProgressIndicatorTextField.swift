import UIKit

final class ProgressIndicatorTextField: UITextField {

    // MARK: - View Data

    struct ViewData {
        let placeholderText: String?
        let isAnimating: Bool
    }

    // MARK: - Constants

    private struct Constants {
        static let backgroundColor = UIColor.counters.buttonText
        static let cornerRadius: CGFloat = 8
        static let minimumHeight: CGFloat = 55

        static let textInsets = UIEdgeInsets(top: 17, left: 17, bottom: 17, right: 17)

        struct ActivityIndicator {
            static let color: UIColor = UIColor.counters.background
            static let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        }
    }

    // MARK: - Insets

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds.inset(by: Constants.textInsets))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        textRect(forBounds: bounds)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        super.rightViewRect(forBounds: bounds.inset(by: Constants.ActivityIndicator.insets))
    }

    // MARK: - Subviews

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.tintColor = UIColor.counters.secondaryText
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    // MARK: - Private

    var viewData: ViewData? {
        didSet {
            updateContent()
        }
    }

    // MARK: - Initialization

    init(viewData: ViewData) {
        self.viewData = viewData
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        configureStyle()
        configureRightView()
        updateContent()
    }

    // MARK: - Layout

    private func configureStyle() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Constants.backgroundColor

        layer.masksToBounds = true
        layer.cornerRadius = Constants.cornerRadius
    }

    private func configureRightView() {
        rightViewMode = .always
    }

    private func updateContent() {
        placeholder = viewData?.placeholderText

        if viewData?.isAnimating == true {
            startAnimating()
        } else {
            stopAnimating()
        }
    }

    // MARK: - Public interface

    public func startAnimating() {
        resignFirstResponder()
        isUserInteractionEnabled = false
        rightView = activityIndicator
        activityIndicator.startAnimating()
    }

    public func stopAnimating() {
        activityIndicator.stopAnimating()
        rightView = nil
        isUserInteractionEnabled = true
    }

    public var isAnimating: Bool {
        activityIndicator.isAnimating
    }
}
