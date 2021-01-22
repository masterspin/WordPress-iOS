import UIKit
import CocoaLumberjack
import WordPressShared
import WordPressUI

class JetpackBackupStatusViewController: BaseRestoreStatusViewController {

    // MARK: - Properties

    private let downloadID: Int

    private lazy var coordinator: JetpackBackupStatusCoordinator = {
        return JetpackBackupStatusCoordinator(site: self.site,
                                              store: self.store,
                                              downloadID: self.downloadID,
                                              view: self)
    }()

    // MARK: - Initialization

    init(site: JetpackSiteRef, activity: Activity, store: ActivityStore, downloadID: Int) {
        self.downloadID = downloadID

        let restoreStatusConfiguration = JetpackRestoreStatusConfiguration(
            title: NSLocalizedString("Backup", comment: "Title for Jetpack Backup Status screen"),
            iconImage: .gridicon(.history),
            messageTitle: NSLocalizedString("Currently creating a downloadable backup of your site", comment: "Title for the Jetpack Backup Status message."),
            messageDescription: NSLocalizedString("We're creating a downloadable backup of your site from %1$@.", comment: "Description for the Jetpack Backup Status message. %1$@ is a placeholder for the selected date."),
            hint: NSLocalizedString("No need to wait around. We'll notify you when your backup is ready.", comment: "A hint to users about creating a downloadable backup of their site."),
            primaryButtonTitle: NSLocalizedString("OK, notify me!", comment: "Title for the button that will dismiss this view."),
            placeholderProgressTitle: nil,
            progressDescription: nil
        )

        super.init(site: site, activity: activity, store: store, configuration: restoreStatusConfiguration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coordinator.viewWillDisappear()
    }

    // MARK: - Override

    override func primaryButtonTapped() {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.coordinator.resumeStatusUpdateOnActivityLog()
        })
    }
}

extension JetpackBackupStatusViewController: JetpackBackupStatusView {

    func render(_ backup: JetpackBackup) {
        guard let progress = backup.progress else {
            return
        }

        statusView.update(progress: progress)
    }

    func showBackupStatusUpdateFailed() {
        let statusFailedVC = JetpackBackupStatusFailedViewController(site: site, activity: activity)
        self.navigationController?.pushViewController(statusFailedVC, animated: true)
    }

    func showBackupComplete(_ backup: JetpackBackup) {
        let completeVC = JetpackBackupCompleteViewController(site: site, activity: activity, backup: backup)
        self.navigationController?.pushViewController(completeVC, animated: true)
    }
}
