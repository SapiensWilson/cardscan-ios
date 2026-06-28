import StoreKit
import SwiftUI

/// Manages the $9.99 one-time Pro unlock via StoreKit 2.
/// Injected as @EnvironmentObject from CardScanApp.
@MainActor
final class ProStore: ObservableObject {

    static let productID = "com.sapienwilson.cardscan.pro"

    @Published private(set) var isPro: Bool = false
    @Published private(set) var product: Product? = nil
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var purchaseError: String? = nil

    private var transactionListener: Task<Void, Never>? = nil

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProduct() }
        Task { await refreshPurchaseStatus() }
    }

    deinit { transactionListener?.cancel() }

    // MARK: — Public API

    func purchase() async {
        guard let product else {
            purchaseError = "Product unavailable. Check your internet connection."
            return
        }
        isLoading = true
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                isPro = true
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval (e.g. Ask to Buy)."
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        isLoading = false
    }

    func restore() async {
        isLoading = true
        purchaseError = nil
        do {
            try await AppStore.sync()
            await refreshPurchaseStatus()
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: — Private helpers

    private func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
        } catch {
            // Product load failure is silent; paywall shows a spinner until resolved
        }
    }

    private func refreshPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                isPro = true
                return
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): return value
        case .unverified(_, let error): throw error
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result,
                   transaction.productID == Self.productID {
                    await transaction.finish()
                    await MainActor.run { self.isPro = true }
                }
            }
        }
    }
}
