# Tinker Payments Ruby SDK

Official Ruby SDK for [Tinker Payments API](https://payments.tinker.co.ke/docs).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tinker-pay-ruby-sdk'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install tinker-pay-ruby-sdk
```

## Requirements

- Ruby 3.0 or higher
- No external runtime dependencies (uses standard library)

## Quick Start

```ruby
require 'tinker'

tinker = Tinker::Payments.new(
  api_public_key: 'your-public-key',
  api_secret_key: 'your-secret-key'
)
```

## Usage

### Initiate a Payment

```ruby
require 'tinker'

begin
  initiate_request = Tinker::Model::Dto::InitiatePaymentRequestDto.new(
    amount: 100.00,
    currency: 'KES',
    gateway: Tinker::Enum::Gateway::MPESA,
    merchant_reference: 'ORDER-12345',
    return_url: 'https://your-app.com/payment/return',
    customer_phone: '+254712345678',
    transaction_desc: 'Payment for order #12345',
    metadata: { order_id: '12345' }
  )

  transaction = tinker.transactions.initiate(initiate_request)
  initiation_data = transaction.initiation_data

  if initiation_data&.authorization_url
    # Redirect user to authorization URL (Paystack, Stripe, etc.)
    redirect_to initiation_data.authorization_url
  end
rescue Tinker::Exception::ApiException => e
  puts "API Error: #{e.message}"
rescue Tinker::Exception::NetworkException => e
  puts "Network Error: #{e.message}"
end
```

**Note:** The `return_url` is where users are redirected after payment completion. Webhooks are configured separately in your dashboard.

### Query a Transaction

```ruby
query_request = Tinker::Model::Dto::QueryPaymentRequestDto.new(
  payment_reference: 'TXN-abc123xyz',
  gateway: Tinker::Enum::Gateway::MPESA
)

transaction = tinker.transactions.query(query_request)

if transaction.successful?
  query_data = transaction.query_data
  puts "Amount: #{query_data.amount} #{query_data.currency}"
end
```

### Handle Webhooks

Webhooks support multiple event types: payment, subscription, invoice, and settlement. Check the event type and handle accordingly:

```ruby
require 'tinker'

event = tinker.webhooks.handle_from_request(request.body.read)

# Check event type
if event.payment_event?
  payment_data = event.payment_data
  # Handle payment.completed, payment.failed, etc.
elsif event.subscription_event?
  subscription_data = event.subscription_data
  # Handle subscription.created, subscription.cancelled, etc.
elsif event.invoice_event?
  invoice_data = event.invoice_data
  # Handle invoice.paid, invoice.failed
elsif event.settlement_event?
  settlement_data = event.settlement_data
  # Handle settlement.processed
end

# Access event details
puts "Event type: #{event.type}"        # e.g., "payment.completed"
puts "Event source: #{event.source}"    # e.g., "payment"
puts "App ID: #{event.meta.app_id}"
puts "Signature: #{event.security.signature}"
```

For payment events only, you can convert to a `Transaction` object:

```ruby
transaction = tinker.webhooks.handle_as_transaction(request.body.read)
if transaction && transaction.successful?
  callback_data = transaction.callback_data
  puts "Payment successful: #{callback_data.reference}"
end
```

## Custom HTTP Client

You can use your own HTTP client by passing it to the constructor:

```ruby
require 'tinker'

# Create a custom HTTP client that responds to #post(url, headers:, body:)
# and returns an object with #status_code, #body, and #json methods
custom_client = MyCustomHttpClient.new

tinker = Tinker::Payments.new(
  api_public_key: 'your-public-key',
  api_secret_key: 'your-secret-key',
  http_client: custom_client
)
```

## Documentation

For detailed API documentation, visit [Tinker Payments API Documentation](https://payments.tinker.co.ke/docs).

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tinker/payments-ruby-sdk.

## License

MIT License


## API errors

API exceptions preserve `http_status`, `error_code`, `provider_code`, `request_id`, `retry_after`, and `outcome`.
Request IDs prefer `error.request_id` over the `X-Request-ID` header. `Retry-After`
is retained as its original header string. Non-JSON HTTP failures retain status and
headers as API errors with an unknown outcome. Existing exception constructors and
legacy code/message access remain compatible.

Only an explicit `not_applied` outcome confirms no mutation. A missing outcome
remains uncertain.

## Managed recurring billing

Requires a Tinker server with the managed-billing, payment-method and payment-history
endpoints enabled. Installing the SDK does not deploy or enable those endpoints.
Existing plan-based subscription methods remain available.

Checkout uses exact integer minor-unit prices (for example, `15000` means EUR 150.00),
an explicit recurring interval (`month` or `year`), and a quantity. The SDK does not
convert prices or apply automatic discounts. Managed responses are unwrapped API
data objects/maps; payment history includes `items`, `snapshot`, `has_more` and
`next_cursor`.

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
billing = payments.subscriptions
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
# Rescue Tinker::Exception::ApiException and inspect error.http_status, error.outcome, etc.
```

Pass Integer values for minor-unit amounts, quantities and snapshots; do not convert
through floating-point prices. `ManagedCheckout` exposes `to_hash`.

Use a stable, unique idempotency key for each mutation, and reuse it only with the
same payload. After a timeout, retrieve the durable result with the operation lookup
method. Missing or pending results do not prove a charge failed. Do not retry with a
new key to work around an uncertain result. Only an explicit `outcome == "not_applied"`
confirms no mutation; missing outcome remains uncertain. No automatic charge retry is
performed by these methods.

The payment-method portal updates payment details only. It cannot change quantity or
price, and paying an overdue invoice is a separate action through its hosted invoice
URL. Reuse the operation key after an uncertain response; use a new key to deliberately
open a fresh session after expiry. The server checks app ownership and requires a
managed subscription with a dedicated customer.

For payment history, start with an empty cursor and zero snapshot, then retain the
returned snapshot and pass `next_cursor` until `has_more` is false. Amounts are integer
minor units and timestamps are UTC RFC3339. The history includes captured cash payments,
tax-exclusive eligible amounts, successful refunds, and dispute principal withdrawals
and reinstatements (`reverses_id` links a reinstatement to its withdrawal).

Quarantine items with `reconciliation_reason`; commit a scan only after every page has
been verified. The snapshot is an event cutoff, not an immutable provider snapshot.
Rescan from the first page regularly and apply facts idempotently by payment/adjustment
ID. Zero-cash invoices are omitted from items while still advancing pagination. Currency
conversion and customer credits require explicit reconciliation; processing and dispute
fees are excluded from eligible principal. The SDK returns these facts without applying
credits or reconciling them automatically.
