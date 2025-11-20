# FixGuru API

Rails API backend for FixGuru - A professional services marketplace for Pakistan.

## Features

- User authentication with JWT
- Role-based access control (Service Seeker, Service Provider, Admin)
- Job posting and management
- Bidding system with subscription-based limits
- Real-time messaging with ActionCable
- Provider verification system
- Subscription management (Free, Standard, Pro)
- Payment processing with proof upload
- Admin dashboard

## Tech Stack

- Ruby 3.2.0
- Rails 7.1.6
- PostgreSQL
- Redis (for ActionCable)
- JWT for authentication
- ActiveStorage for file uploads

## Setup

### Prerequisites

- Ruby 3.2.0 or higher
- PostgreSQL
- Redis

### Installation

1. Install dependencies:
```bash
bundle install
```

2. Set up the database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

3. Start Redis (required for ActionCable):
```bash
redis-server
```

4. Start the Rails server:
```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register a new user
- `POST /api/v1/auth/login` - Login
- `GET /api/v1/auth/me` - Get current user

### Jobs
- `GET /api/v1/jobs` - List jobs (with filters)
- `GET /api/v1/jobs/:id` - Get job details
- `POST /api/v1/jobs` - Create a job (Seeker only)
- `PUT /api/v1/jobs/:id` - Update a job
- `DELETE /api/v1/jobs/:id` - Delete a job
- `POST /api/v1/jobs/:id/assign_provider` - Assign provider to job

### Bids
- `GET /api/v1/bids` - List bids
- `POST /api/v1/bids` - Create a bid (Provider only)
- `PUT /api/v1/bids/:id` - Update a bid
- `DELETE /api/v1/bids/:id` - Delete a bid

### Subscriptions
- `GET /api/v1/subscriptions` - List subscriptions
- `GET /api/v1/subscriptions/current` - Get current subscription
- `POST /api/v1/subscriptions` - Create a subscription

### Payments
- `GET /api/v1/payments` - List payments
- `POST /api/v1/payments` - Create a payment

### Messages
- `GET /api/v1/messages?user_id=:id` - Get conversation messages
- `POST /api/v1/messages` - Send a message
- `GET /api/v1/messages/conversations` - List all conversations

### Admin
- `GET /api/v1/admin/dashboard` - Admin dashboard stats
- `GET /api/v1/admin/pending_providers` - List pending providers
- `POST /api/v1/admin/providers/:id/approve` - Approve provider
- `POST /api/v1/admin/providers/:id/reject` - Reject provider
- `POST /api/v1/admin/payments/:id/approve` - Approve payment

## Default Users

After running seeds:
- Admin: `admin@fixguru.com` / `admin123`
- Seeker: `seeker@example.com` / `password123`
- Provider: `provider@example.com` / `password123`

## Environment Variables

Create a `.env` file or set:
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string (default: `redis://localhost:6379/0`)

## License

MIT
