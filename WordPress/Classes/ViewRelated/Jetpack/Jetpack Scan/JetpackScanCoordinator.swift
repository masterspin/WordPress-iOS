import Foundation

protocol JetpackScanView {
    func render(_ scan: JetpackScan)

    func showLoading()
    func showError()

    func presentAlert(_ alert: UIAlertController)
}

class JetpackScanCoordinator {
    private let service: JetpackScanService
    private let view: JetpackScanView

    private(set) var scan: JetpackScan?
    let blog: Blog

    /// Returns the threats if we're in the idle state
    var threats: [JetpackScanThreat]? {
        return scan?.state == .idle ? scan?.threats : nil
    }

    init(blog: Blog,
         view: JetpackScanView,
         service: JetpackScanService? = nil,
         context: NSManagedObjectContext = ContextManager.sharedInstance().mainContext) {

        self.service = service ?? JetpackScanService(managedObjectContext: context)
        self.blog = blog
        self.view = view
    }

    public func viewDidLoad() {
        view.showLoading()

        refreshData()
    }

    public func refreshData() {
        service.getScan(for: blog) { [weak self] scanObj in
            self?.refreshDidSucceed(with: scanObj)
        } failure: { [weak self] error in
            DDLogError("Error fetching scan object: \(String(describing: error?.localizedDescription))")

            self?.view.showError()
        }
    }

    public func viewWillDisappear() {
        stopPolling()
    }

    private func refreshDidSucceed(with scanObj: JetpackScan) {
        scan = scanObj
        view.render(scanObj)

        togglePolling()
    }

    public func startScan() {
        // Optimistically trigger the scanning state
        scan?.state = .scanning

        // Refresh the view's scan state
        if let scan = scan {
            view.render(scan)
        }

        // Since we've locally entered the scanning state, start polling
        // but don't trigger a refresh immediately after calling because the
        // server doesn't update its state immediately after starting a scan
        startPolling(triggerImmediately: false)

        service.startScan(for: blog) { [weak self] (success) in
            if success == false {
                DDLogError("Error starting scan: Scan response returned false")

                self?.view.showError()
            }
        } failure: { [weak self] (error) in
            DDLogError("Error starting scan: \(String(describing: error?.localizedDescription))")

            self?.view.showError()
        }
    }

    public func fixAllThreats() {

    }

    public func ignoreThreat(threat: JetpackScanThreat) {

    }

    public func openSupport() {

    }

    // MARK: - Private: Refresh Timer
    private var refreshTimer: Timer?

    /// Starts or stops the refresh timer based on the status of the scan
    private func togglePolling() {
        switch scan?.state {
        case .provisioning, .scanning:
            startPolling()
        default:
            stopPolling()
        }
    }

    private func stopPolling() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private func startPolling(triggerImmediately: Bool = true) {
        guard refreshTimer == nil else {
            return
        }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: Constants.refreshTimerInterval, repeats: true, block: { [weak self] (_) in
            self?.refreshData()
        })

        // Immediately trigger the refresh if needed
        guard triggerImmediately else {
            return
        }
        refreshData()
    }

    private struct Constants {
        static let refreshTimerInterval: TimeInterval = 5
    }
extension JetpackScan {
    var hasFixableThreats: Bool {
        let count = fixableThreats?.count ?? 0
        return count > 0
    }

    var fixableThreats: [JetpackScanThreat]? {
        return threats?.filter { $0.fixable != nil }
    }
}
