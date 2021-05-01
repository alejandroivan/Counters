import UIKit

final class MainTableViewDataSource: NSObject, UITableViewDataSource {
    weak var presenter: MainPresenter?

    private var isFiltering: Bool { presenter?.viewController?.isFiltering ?? false }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        let rows: Int

        if isFiltering {
            rows = presenter?.filteredItems.count ?? 0
        } else {
            rows = presenter?.items.count ?? 0
        }

        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = isFiltering ? presenter?.filteredItems : presenter?.items
        let cell: MainViewItemCell = tableView.dequeueReusable(for: indexPath)
        cell.viewData = items?[indexPath.row]
        cell.delegate = presenter?.tableViewDelegate
        return cell
    }
}
