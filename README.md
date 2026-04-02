# CloudPricing

A cloud instance pricing comparison tool that aggregates on-demand pricing data from **AWS**, **GCP**, and **Azure** into a filterable, sortable dashboard.

**Live:** [cloudpricing.buford.dev](https://cloudpricing.buford.dev)

## Features

- **Comparison Table** — Filter and sort instances across all three providers by vCPUs, memory, price, price/vCPU, and instance family
- **Full-text Search** — Find specific instance types (e.g., "m5", "Standard_D4")
- **Side-by-Side Compare** — Select 2-4 instances for detailed comparison
- **Charts** — Scatter plots and bar charts visualizing pricing across providers
- **Real Data** — Pricing imported directly from official cloud provider APIs

## Tech Stack

- **Ruby on Rails 7.2** with PostgreSQL
- **Hotwire** (Turbo Frames + Stimulus) for reactive filtering without full page reloads
- **Tailwind CSS** for styling
- **Chartkick + Chart.js** for data visualizations
- **RSpec + FactoryBot** for testing
- **Docker Compose** for deployment

## Getting Started

### Prerequisites

- Ruby 3.3+
- PostgreSQL 14+
- Node.js (for Tailwind CSS build)

### Local Development

```bash
git clone https://github.com/bufordeeds/cloud-pricing.git
cd cloud-pricing
bundle install
rails db:create db:migrate db:seed

# Import pricing data
rails pricing:import:gcp     # Fast (~5 seconds)
rails pricing:import:azure   # Medium (~30 seconds)
rails pricing:import:aws     # Slow (~2-5 minutes, large file)

# Start the server
bin/dev
```

### Docker

```bash
cp .env.example .env
# Edit .env with your values
docker compose up --build
docker compose exec web rails db:migrate db:seed
docker compose exec web rails pricing:import
```

## Data Sources

| Provider | Source | Region |
|----------|--------|--------|
| AWS | [EC2 Bulk Pricing API](https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/us-east-1/index.json) | us-east-1 |
| GCP | [Cloud Pricing Calculator](https://cloudpricingcalculator.appspot.com/static/data/pricelist.json) | us-central1 |
| Azure | [Retail Prices API](https://prices.azure.com/api/retail/prices) | eastus |

## Testing

```bash
rails db:test:prepare
bundle exec rspec
```

## Author

Built by [Buford Eeds](https://buford.dev) — [GitHub](https://github.com/bufordeeds) · [LinkedIn](https://linkedin.com/in/bufordeeds)
