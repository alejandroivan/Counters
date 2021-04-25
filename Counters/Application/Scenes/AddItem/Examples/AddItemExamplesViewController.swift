import UIKit

final class AddItemExamplesViewController: UIViewController {

    // MARK: - Constants

    private struct Constants {
        struct Header {
            static let backgroundColor = UIColor.counters.background
            static let textColor = UIColor.counters.secondaryText
            static let font = UIFont.systemFont(ofSize: 15)
            static let height: CGFloat = 50

            struct Shadow {
                static let color = UIColor.counters.primaryText
                static let radius: CGFloat = 0.1
                static let opacity: Float = 1
                static let verticalOffset: CGFloat = 1
            }
        }

        struct TableView {
            static let backgroundColor = UIColor.counters.background
        }
    }

    // MARK: - Properties

    weak var delegate: AddItemExamplesDelegate?

    // MARK: - Initialization

    init(delegate: AddItemExamplesDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = nil
    }

    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderShadowFrame()
    }

    // MARK: - Subviews

    private let headerLabel = UILabel()
    private let tableView = UITableView()

    // MARK: - Private

    private func configureView() {
        title = "Examples"
        view.backgroundColor = UIColor.counters.background
        configureHeader()
        configureTableView()
    }

    private func configureHeader() {
        // UILabel stuff
        headerLabel.text = "ADD_ITEM_EXAMPLES_HEADER".localized
        headerLabel.font = Constants.Header.font
        headerLabel.backgroundColor = Constants.Header.backgroundColor
        headerLabel.textColor = Constants.Header.textColor
        headerLabel.textAlignment = .center

        // Bottom shadow (the actual UIBezierPath will be calculated on viewDidLayoutSubviews)
        headerLabel.layer.masksToBounds = false
        headerLabel.layer.shadowRadius = Constants.Header.Shadow.radius
        headerLabel.layer.shadowOpacity = Constants.Header.Shadow.opacity
        headerLabel.layer.shadowColor = Constants.Header.Shadow.color.cgColor
        headerLabel.layer.shadowOffset = CGSize(
            width: 0,
            height: Constants.Header.Shadow.verticalOffset
        )

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: Constants.Header.height)
        ])
    }

    /// This method should be called on viewDidLayoutSubviews, and will calculate the
    /// UIBezierPath for the shadow in the header. This shouldn't be done before, because
    /// frames/bounds are not calculated before this method is called.
    private func updateHeaderShadowFrame() {
        let frame = CGRect(
            x: 0,
            y: headerLabel.bounds.maxY - headerLabel.layer.shadowRadius,
            width: headerLabel.bounds.width,
            height: headerLabel.layer.shadowRadius
        )

        headerLabel.layer.shadowPath = UIBezierPath(rect: frame).cgPath
    }

    private func configureTableView() {
        tableView.backgroundColor = Constants.TableView.backgroundColor

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
