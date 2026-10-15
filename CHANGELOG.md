# Release notes

## Unreleased

- Add app-scoped refund creation, history and lookup through the existing transaction manager.
- Add merchant payouts: masked payout methods, fee quotes, withdrawal requests and paginated status/history. Payouts withdraw available merchant funds to the merchant’s own verified account; owner permission is required for new requests.
- Add checkout cancellation requests, capability/history and lookup. Unsupported providers return a recorded rejection; uncertain outcomes remain queryable and must not trigger a replacement request.
- Require stable caller-provided idempotency keys for these mutations and preserve structured API error details.
- Parse and verify signed refund, withdrawal and checkout-cancellation resource updates without converting them into payment transactions.

Existing payment initiation, payment queries and subscription APIs remain available. No automated payout transfer is implied by request acceptance.
