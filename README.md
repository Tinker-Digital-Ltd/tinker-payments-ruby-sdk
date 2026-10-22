# Tinker Payments Ruby SDK

Ruby 3.0+ SDK for payments, subscriptions and signed webhooks. Keep secret keys on the server.

## Install and configure

Add `gem 'tinker-pay-ruby-sdk'` to your Gemfile and run `bundle install`, or run:

```sh
gem install tinker-pay-ruby-sdk
```

```ruby
require 'tinker'

tinker = Tinker::Payments.new(api_public_key: 'pk_test_xxx', api_secret_key: 'sk_test_xxx')
```

Test key prefixes select `https://sandbox-api.tinkerpayments.com/v1/`; other keys select `https://api.tinkerpayments.com/v1/`. Override with `base_url:`. A custom `http_client:` must implement `get(url, headers:)` and `post(url, headers:, body:)`, returning responses with `status_code`, `json` and `headers`.

## Payments

```ruby
request = Tinker::Model::Dto::InitiatePaymentRequestDto.new(
  amount: 100, currency: 'KES', gateway: Tinker::Enum::Gateway::MPESA,
  merchant_reference: 'ORDER-12345',
  return_url: 'https://merchant.example/payment/return',
  customer_phone: '+254712345678'
)
payment = tinker.transactions.initiate(request)
result = tinker.transactions.query(Tinker::Model::Dto::QueryPaymentRequestDto.new(
  payment_reference: 'TXN-abc123xyz', gateway: Tinker::Enum::Gateway::MPESA
))
```

Payments use currency units. Mpesa requires `customer_phone`; `return_url` is the browser destination, while webhooks are configured separately in the dashboard. Hosted providers may return `payment.initiation_data&.authorization_url` for a redirect.

Plan-based subscriptions use `tinker.subscriptions.create_plan`, `list_plans`, `create`, `list` and `cancel` with the request DTOs in `Tinker::Model::Dto`.

## Managed recurring billing

Checkout uses exact integer minor-unit prices (`15000` = EUR 150.00), a `month` or `year` interval, and a quantity. The SDK does not convert prices or apply discounts. Responses are unwrapped data maps/objects.

| Method | Purpose |
|---|---|
| `checkout` | Create an exact-price recurring checkout |
| `billing_resource` | Read a managed billing resource |
| `change_quantity` | Change the current quantity |
| `schedule_quantity` | Schedule a quantity change |
| `clear_scheduled_quantity` | Remove a scheduled quantity change |
| `set_cancel_at_renewal` | Set cancellation at renewal; pass false to clear it |
| `billing_operation` | Recover the durable result by idempotency key |
| `payment_method_portal` | Create a short-lived hosted payment-method link |
| `billing_payment_history` | Read one page of captured payments and adjustments |

```ruby
billing = tinker.subscriptions
billing.checkout(Tinker::Model::Dto::ManagedCheckout.new(
  external_customer_id: 'workspace-123', email: 'buyer@example.com', name: 'Buyer',
  currency: 'EUR', unit_amount: 15000, quantity: 3, interval: 'year',
  return_url: 'https://example.com/billing', idempotency_key: 'checkout-123'
))
billing.change_quantity('resource-id', 4, 'quantity-123')
billing.set_cancel_at_renewal('resource-id', false, 'resume-123')
billing.payment_method_portal('resource-id', 'https://example.com/billing', 'portal-123')
page = billing.billing_payment_history('resource-id', '', 0)
# After an uncertain command response, recover using the SAME key:
operation = billing.billing_operation('quantity-123')
```

Pass Integer values for minor-unit amounts, quantities and snapshots; do not convert
through floating-point prices. `ManagedCheckout` exposes `to_hash`.

### Trials with a required payment method

Set `trial_days` (1 to 30) to collect a card at checkout and charge first when the trial ends. The SDK sends `trial_days` only when it is above 0, so checkouts without a trial keep working against servers released before trial support. A gateway without trial support returns HTTP 422 `TRIAL_UNSUPPORTED` with `outcome: not_applied`. Limiting a customer to one trial is the app's responsibility.

```ruby
billing.checkout(Tinker::Model::Dto::ManagedCheckout.new(
  external_customer_id: 'workspace-123', email: 'buyer@example.com', name: 'Buyer',
  currency: 'EUR', unit_amount: 15000, quantity: 3, interval: 'year',
  return_url: 'https://example.com/billing', idempotency_key: 'checkout-124',
  trial_days: 14
))
```

Checkout and billing resource responses include a provider-neutral `managed_state` map: `status` (`pending`, `trialing`, `active`, `past_due`, `paused` or `canceled`), `trial_ends_at`, `current_period_end` and `cancel_at_period_end`. Read it instead of raw provider fields; grant access while `status` is `trialing` or `active` and `current_period_end` is in the future. Managed subscription webhooks carry `billing_status` and `trial_ends_at`, and `subscription.trial_will_end` arrives up to three days before the trial ends. The trial's €0 invoice sends `invoice.paid` with amount 0 and is not a payment.

Use a stable key per mutation and reuse it with the same payload after a lost response. Recover through the operation lookup; missing or pending results remain uncertain. Only an explicit `outcome` of `not_applied` confirms no mutation.

The payment-method portal changes payment details only; quantity, price and overdue invoice payment are separate actions. It requires an app-owned managed subscription with a dedicated customer. Reuse the operation key after a lost response and use a new key for a deliberately new session after expiry.

For payment history, keep the returned `snapshot` across `next_cursor` pages until `has_more` is false. Amounts are integer minor units and timestamps are UTC RFC3339. History covers captured cash, tax-exclusive eligible amounts, refunds, and dispute principal withdrawals/reinstatements (`reverses_id` identifies the reversed withdrawal).

Quarantine items with `reconciliation_reason` and verify every page before committing a scan. The snapshot is an event cutoff, not an immutable provider snapshot: rescan from the first page to discover later adjustments, then apply facts idempotently by payment/adjustment ID. Zero-cash invoices advance pagination without an item. Processing/dispute fees are excluded from eligible principal; currency conversion and customer credits need explicit reconciliation.

## Refunds, merchant payouts and checkout cancellation

Payouts withdraw the merchant's available Tinker wallet balance to an existing
verified payout account. The app owner enables SDK withdrawal access in the
dashboard; the SDK cannot approve requests or verify payout accounts. Fees come
out of the requested amount: requesting 100 with a fee of 2 reserves 100 and pays
98. Quote first and send the quoted fee.

```ruby
refund = tinker.transactions.refund(payment_id,
  Tinker::Model::Dto::RefundRequest.new(reason: 'requested_by_customer', amount: 25), 'refund-order-42')
destination = tinker.payouts.methods.find { |method| method['is_verified'] && method['status'] == 'active' }
raise 'Configure an active, verified payout method' unless destination
method_id = destination['id']
quote = tinker.payouts.quote(payout_method_id: method_id, amount: 100, currency: destination['currency'])
payout = tinker.payouts.request_payout(
  Tinker::Model::Dto::PayoutRequest.new(payout_method_id: method_id, amount: 100,
    currency: destination['currency'], expected_fee_amount: quote['fee_amount']), 'withdrawal-42')
status = tinker.payouts.get(payout.withdrawal.id)
cancellation = tinker.transactions.cancel_checkout(unpaid_payment_id,
  Tinker::Model::Dto::CancellationRequest.new(reason: 'Order cancelled'), 'cancel-order-42')
```

Reuse the same key for retries of one operation. Keys are required, limited to
255 UTF-8 bytes, and never silently regenerated. Different payloads with one key
produce a conflict. `pending_review` refunds and `pending_approval` payouts are
accepted requests, not completed transfers. Only `refunded`, `paid`, or
provider-confirmed `cancelled` indicate completion. Query `outcome_unknown`
cancellations instead of assuming failure and retrying.

Use `refunds`, `get_refund`, `cancellations`, `get_cancellation`, and
`payouts.list` for history and status. `ApiException#details` preserves the full
error envelope; `details.dig('error', 'details')` includes the recorded request ID
for unsupported cancellation (422) or updated quote for a fee conflict (409).
Subscription cancellation is a separate operation. Existing administrative queues
handle manual refunds and withdrawals.

Cancellation history returns the newest 100 requests and `has_more`; use the
single-request lookup to track a known older request. A cancellation with
`payment_conflict` means later successful collection conflicts with cancellation
evidence; investigate the successful payment and use a refund if needed.

## Webhooks

```ruby
event = tinker.webhooks.handle(raw_body)
raise 'Invalid webhook signature' unless tinker.webhooks.verify_signature(event, webhook_secret)
transaction = event.to_transaction # nil for setup/lifecycle events
```

Verify the signature before consuming fields or converting the event to a transaction; reuse the parsed event rather than reading the request body twice. Deduplicate by event ID. The SDK verifies HMAC-SHA256 over the envelope excluding `security`, using the server's field order, map ordering and escaping.

After verification, acknowledge `setup.webhook_test` (`source: onboarding`) with HTTP 200, 202 or 204; it needs no payment lookup or fulfillment. The signed lifecycle events `refund.updated.v1`, `withdrawal.updated.v1` and `checkout.cancellation.updated.v1` carry `data.resource` with `source: payment`. Their typed resources never convert into payment transactions. Poll request IDs if delivery is delayed.

## Errors and response metadata

API errors retain `http_status`, `error_code`, `provider_code`, `request_id`, `retry_after`, `outcome` and the full envelope in `details`. Request IDs prefer the response body over `X-Request-ID`; `Retry-After` remains its original string. Non-JSON HTTP failures retain status/headers and an uncertain outcome. Only an explicit `not_applied` outcome confirms no mutation. Use `manager.last_meta` or `tinker.last_auth_meta` for response metadata.

```ruby
begin
  tinker.transactions.query(Tinker::Model::Dto::QueryPaymentRequestDto.new(
    payment_reference: 'TXN-abc123xyz', gateway: Tinker::Enum::Gateway::MPESA
  ))
rescue Tinker::Exception::ApiException => error
  warn "#{error.error_code}: #{error.message}"
end
```

## Development

```sh
bundle install
bundle exec rubocop
bundle exec rake spec
```

MIT License.
