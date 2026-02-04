# Wamo Project Spec (MVP)

## 1. Product Brief
- Problem: Africans want to support urgent needs, but existing crowdfunding platforms don’t support local payments or trust models.
- Target users: campaign creators (individuals, families, communities), donors (local MoMo users and diaspora card users).
- Value proposition: fast, trusted, mobile-first fundraising with local payouts and transparent progress.
- Success metrics (MVP):
  - Campaign creation time < 5 minutes
  - Donation completion time < 30 seconds
  - Donation success rate >= 95%
  - Verification time < 24 hours
  - Low fraud / dispute rate

## 2. PRD Summary (MVP Scope)
### Core features
- Campaign creation: cause, story, target, proof upload, payout method.
- Verification: manual review, verified badge, ability to request more proof.
- Donations: MoMo + card, anonymous or named, instant confirmation.
- Campaign page: story, progress bar, updates, share links.
- Creator dashboard: raised amount, donation feed, payout status, updates.
- Notifications: donations, verification status, payout status.
- Safety: identity checks, reporting, freeze/suspend rules.

### Out of scope (later)
- Multi-currency wallets
- NGO bulk campaigns
- Public API
- AI fraud detection
- Multi-language

## 3. User Stories (MVP)
- As a creator, I can create a campaign in under 5 minutes and submit proof.
- As a creator, I can see live progress and donation history.
- As a creator, I can post updates and upload receipts.
- As a donor, I can donate without creating an account.
- As a donor, I can pay with MoMo or card and get instant confirmation.
- As an admin, I can approve, reject, or freeze campaigns.

## 4. Information Architecture / Screens (MVP)
- Home
- Create Campaign (multi-step)
- Campaign Page
- Donation Flow (amount, method, processing, result)
- Creator Dashboard
- Verification Pending

## 5. Data Model (MVP)
### Entities
- User
  - id, name, phone, email(optional), role, verification_status
- Campaign
  - id, owner_id, title, cause, story, target_amount, raised_amount,
    status, created_at, verified_at, payout_method, proof_urls
- Donation
  - id, campaign_id, donor_name(optional), donor_contact(optional),
    amount, fee_amount, payment_method, status, created_at, paystack_ref
- Update
  - id, campaign_id, text, media_urls, created_at
- Payout
  - id, campaign_id, amount, status, initiated_at, completed_at, reference

## 6. API Contracts (MVP)
- POST /campaigns
- GET /campaigns/{id}
- POST /campaigns/{id}/donations (server verifies Paystack webhook)
- POST /campaigns/{id}/updates
- POST /admin/campaigns/{id}/approve
- POST /admin/campaigns/{id}/reject
- POST /admin/campaigns/{id}/freeze

## 7. Architecture (High Level)
- Flutter app
- Firebase Auth
- Firestore (campaigns, donations, updates)
- Firebase Storage (proof uploads)
- Cloud Functions for Paystack webhooks + notifications
- Paystack for payments (MoMo + cards)

## 8. Risk & Compliance
- Fraud risk: manual verification, escrow, report + freeze workflow.
- Payment failures: retry flow, clear errors, webhook verification.
- Privacy: minimal PII, secure storage, role-based access.

## 9. Delivery Plan (MVP)
### Phase 1 (Weeks 1-2)
- Core data model
- Campaign creation flow
- Campaign page UI

### Phase 2 (Weeks 3-4)
- Paystack integration + webhook verification
- Donation flow + confirmations

### Phase 3 (Weeks 5-6)
- Creator dashboard
- Updates + notifications
- Admin verification workflow

---
Owner decisions still needed:
- Country launch target
- Fee model (platform fee % + processing pass-through)
- Payout rules (manual vs conditional auto)
