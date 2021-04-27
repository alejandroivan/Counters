import UIKit

final class MainTableViewDataSource: NSObject, UITableViewDataSource {
    weak var presenter: MainPresenter?

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        let rows = presenter?.items.count ?? 0
        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MainViewItemCell = tableView.dequeueReusable(for: indexPath)
        return cell
    }
}
