import UIKit
import ContinueControl
import SwiftUI

final class ContinueViewController: UITableViewController {
    enum Section: Int {
        case items
    }

    struct Item: Hashable {
        let id: UUID = UUID()
    }
    
    lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(
        tableView: tableView,
        cellProvider: { [unowned self] (tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "cell",
                for: indexPath
            )
            
            cell.contentConfiguration = UIHostingConfiguration(content: {
                Text("\(indexPath.row)")
            })
            
            return cell
        }
    )
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueControl = ContinueControl()
        continueControl!.addAction(UIAction { _ in
            Task {
                print("Refresh!")
                try await Task.sleep(for: .seconds(3))
                self.snapshot.appendItems((0..<10).map({ _ in Item() }), toSection: .items)
                await MainActor.run {
                    self.dataSource.apply(self.snapshot)
                }
                self.continueControl?.finishContinuing()
            }
        }, for: .primaryActionTriggered)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        _ = dataSource
        
        snapshot.appendSections([.items])
        snapshot.appendItems((0..<20).map({ _ in Item() }), toSection: .items)
        
        dataSource.apply(snapshot)
            
        let refreshMenuItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            menu: UIMenu(children: [
                UIAction(
                    title: "StartContinuing",
                    image: UIImage(systemName: "arrow.counterclockwise.circle"),
                    handler: { [weak self] _ in
                        self?.continueControl?.startContinuing()
                        self?.tableView.reloadData()
                    }
                ),
                UIAction(
                    title: "BeginContinuing",
                    image: UIImage(systemName: "play.fill"),
                    handler: { [weak self] _ in
                        self?.continueControl?.beginContinuing()
                    }
                ),
                UIAction(
                    title: "EndContinuing",
                    image: UIImage(systemName: "pause.fill"),
                    handler: { [weak self] _ in
                        self?.continueControl?.endContinuing()
                    }
                ),
                UIAction(
                    title: "FinishContinuing",
                    image: UIImage(systemName: "stop.fill"),
                    handler: { [weak self] _ in
                        self?.continueControl?.finishContinuing()
                    }
                ),
            ])
        )
        refreshMenuItem.preferredMenuElementOrder = .fixed
        setToolbarItems([
            UIBarButtonItem.flexibleSpace(),
            refreshMenuItem,
        ], animated: false)
        navigationController?.setToolbarHidden(false, animated: false)
    }
}

