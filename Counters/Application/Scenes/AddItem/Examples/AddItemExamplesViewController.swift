import UIKit

/*
 This class implements a UITableView whose cells have UICollectionViews inside.
 This could have easily been done using a UIScrollView+UIStackView+UICollectionView,
 but, for the sake of showing something different, it was made like this.
 */

final class AddItemExamplesViewController: UIViewController, AddItemExamplesTableViewShowcaseProvider {

    // MARK: - Showcase

    var showcase: [ItemCategory: [String]] = [
        .drink: [
            "Cups of coffee",
            "Glasses of water",
            "Piscolas"
        ],
        .food: [
            "Hot-dogs",
            "Cupcakes eaten",
            "Chicken strips"
        ],
        .misc: [
            "Times sneezed",
            "Naps 🥺",
            "Day dreams"
        ]
    ]

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

    private var tableViewDataSource: AddItemExamplesTableViewDataSource?
    private var tableViewDelegate: AddItemExamplesTableViewDelegate?
    weak var delegate: AddItemExamplesDelegate?

    // MARK: - Initialization

    init(
        tableViewDataSource: AddItemExamplesTableViewDataSource,
        tableViewDelegate: AddItemExamplesTableViewDelegate,
        delegate: AddItemExamplesDelegate? = nil
    ) {
        super.init(nibName: nil, bundle: nil)
        self.tableViewDataSource = tableViewDataSource
        self.tableViewDataSource?.showcaseSource = self
        self.tableViewDelegate = tableViewDelegate
        self.tableViewDelegate?.showcaseSource = self
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
        updateHeaderFrame()
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

        /// This header view doesn't require constraints, but rather a frame for its height
        /// to be set property. This should be done in viewDidLayoutSubviews.
        tableView.tableHeaderView = headerLabel
    }

    /// This method should be called on viewDidLayoutSubviews, and will calculate the
    /// UIBezierPath for the shadow in the header. This shouldn't be done before, because
    /// frames/bounds are not calculated before this method is called.
    /// It also calculates the correct size for the whole header.
    private func updateHeaderFrame() {
        headerLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.frame.size.width,
            height: Constants.Header.height
        )

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
        tableView.separatorStyle = .none
        tableViewDataSource?.selectItemDelegate = self
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate

        tableView.registerReusable(AddItemTableViewCell.self)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension AddItemExamplesViewController: AddItemExamplesDelegate {
    func userDidChooseExample(title: String) {
        delegate?.userDidChooseExample(title: title)
    }
}
