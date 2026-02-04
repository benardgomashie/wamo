# Wamo Screens (MVP)

This document lists the screens planned for Wamo and their purpose. It is scoped to MVP.

## Public and Donor Screens
- Splash / Intro
  - Purpose: brand meaning + tagline; short load.
- Home
  - Purpose: explain Wamo in 3 steps; primary CTA to start a fundraiser.
- Campaign Page
  - Purpose: donor conversion and trust; story, proof, progress, updates, verified badge.
- Donation Amount
  - Purpose: quick amount selection with presets.
- Donor Info (Optional)
  - Purpose: optional name/contact + anonymous option.
- Fee Breakdown
  - Purpose: transparent fee display before payment.
- Payment Method
  - Purpose: choose MoMo or card.
- Payment Processing
  - Purpose: show MoMo approval instructions and progress state.
- Payment Result
  - Purpose: success/failure, receipt, share CTA.

## Creator Screens
- Auth (Phone + OTP)
  - Purpose: verify creator identity and session.
- Create Campaign (Multi-step)
  - Step 1: Cause selection
  - Step 2: Title + story
  - Step 3: Target amount
  - Step 4: Proof upload
  - Step 5: Payout setup (MoMo)
  - Step 6: Review + submit
- Verification Pending
  - Purpose: show review status and ETA.
- Creator Dashboard
  - Purpose: progress, donation feed, payout status, quick actions.
- Post Update
  - Purpose: updates with text/photos/receipts.
- Payout Status
  - Purpose: payout state, timing, reference.

## Shared / Utility Screens
- Notifications
  - Purpose: donation alerts, verification updates, payout updates.
- Campaign Closed
  - Purpose: explain why donations are disabled (goal reached / expired).
- Error / Empty States
  - Purpose: safe fallback when data is missing or network is slow.
- Support / Contact
  - Purpose: report campaign, request help.

## Admin (Web)
- Admin Login
  - Purpose: restricted access for moderation.
- Campaign Review Queue
  - Purpose: approve/reject/freeze workflows.
- Campaign Detail Review
  - Purpose: proof inspection, checklist, endorsement review.
- Payout Approval
  - Purpose: manual payout approvals where needed.
- Basic Analytics
  - Purpose: daily totals, fees, payment success rate.

## MVP Non-Negotiables
- Donor flow must not require account creation.
- Payments must be verified server-side before recording donations.
- Mobile Money flows must be first-class.

## Screen Principles
- One primary action per screen.
- No screen should require scrolling to understand its purpose.
- Every payment-related screen must show clear status feedback.
