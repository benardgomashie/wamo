# Wamo Screens (MVP)

This document lists the screens planned for Wamo and their purpose. It is scoped to MVP.

**Last Updated:** February 4, 2026  
**Implementation Status:** 17/24 screens complete (71%)

---

## Implementation Status Legend
- ✅ Implemented and functional
- ⏳ Partially implemented
- ❌ Not yet implemented

---

## Public and Donor Screens (7/9 complete)
- ✅ **Splash / Intro** (`splash_screen.dart`)
  - Purpose: brand meaning + tagline; short load.
  - Status: Implemented with platform-aware routing
  
- ✅ **Home** (`home_screen.dart`)
  - Purpose: explain Wamo in 3 steps; primary CTA to start a fundraiser.
  - Status: Complete
  
- ✅ **Campaign Page** (`campaign_detail_screen.dart`)
  - Purpose: donor conversion and trust; story, proof, progress, updates, verified badge.
  - Status: Complete with real-time updates
  
- ✅ **Donation Amount** (`donate_screen.dart`)
  - Purpose: quick amount selection with presets.
  - Note: Combines amount, donor info, and fee breakdown in one screen
  - Status: Complete (includes Donor Info and Fee Breakdown)
  
- ✅ **Payment Method** (`donate_screen.dart`)
  - Purpose: choose MoMo or card.
  - Status: Integrated in donation flow
  
- ✅ **Payment Processing** (`payment_processing_screen.dart`)
  - Purpose: show MoMo approval instructions and progress state.
  - Status: Complete with real-time status updates
  
- ✅ **Payment Result** (`donation_success_screen.dart`, `donation_failure_screen.dart`)
  - Purpose: success/failure, receipt, share CTA.
  - Status: Complete with both success and failure screens

## Creator Screens (5/6 complete)
- ✅ **Auth (Phone + OTP)** (`phone_auth_screen.dart`, `otp_verification_screen.dart`)
  - Purpose: verify creator identity and session.
  - Status: Complete for mobile
  
- ✅ **Email Auth (Web)** (`email_auth_screen.dart`)
  - Purpose: Web alternative to phone OTP.
  - Status: Complete for web platform
  
- ✅ **Create Profile** (`create_profile_screen.dart`)
  - Purpose: Collect user details after authentication.
  - Status: Complete
  
- ✅ **Create Campaign (Multi-step)** (`create_campaign_screen.dart`)
  - Step 1: Cause selection
  - Step 2: Title + story
  - Step 3: Target amount
  - Step 4: Proof upload
  - Step 5: Payout setup (MoMo)
  - Step 6: Review + submit
  - Status: Complete with all 6 steps
  
- ❌ **Verification Pending**
  - Purpose: show review status and ETA.
  - Status: **NOT IMPLEMENTED** - Need to create
  
- ✅ **Creator Dashboard** (`dashboard_screen.dart`)
  - Purpose: progress, donation feed, payout status, quick actions.
  - Status: Complete with real-time data
  
- ❌ **Post Update**
  - Purpose: updates with text/photos/receipts.
  - Status: **NOT IMPLEMENTED** - Need to create
  
- ✅ **Payout Status** (`payout_request_screen.dart`, `payout_history_screen.dart`)
  - Purpose: payout state, timing, reference.
  - Status: Complete with request and history screens

## Shared / Utility Screens (1/4 complete)
- ✅ **Notifications** (`notification_center_screen.dart`)
  - Purpose: donation alerts, verification updates, payout updates.
  - Status: Complete with in-app notification center
  
- ❌ **Campaign Closed**
  - Purpose: explain why donations are disabled (goal reached / expired).
  - Status: **NOT IMPLEMENTED** - Need to create
  
- ⏳ **Error / Empty States**
  - Purpose: safe fallback when data is missing or network is slow.
  - Status: **PARTIAL** - Some widgets exist, needs comprehensive screen
  
- ❌ **Support / Contact**
  - Purpose: report campaign, request help.
  - Status: **NOT IMPLEMENTED** - Need to create

## Admin (Web) (0/5 complete)
**Note:** Cloud Functions for admin operations exist, but UI is not implemented.

- ❌ **Admin Login**
  - Purpose: restricted access for moderation.
  - Status: **NOT IMPLEMENTED**
  
- ❌ **Campaign Review Queue**
  - Purpose: approve/reject/freeze workflows.
  - Status: **NOT IMPLEMENTED** (Functions exist: `approveCampaign`, `rejectCampaign`, `freezeCampaign`)
  
- ❌ **Campaign Detail Review**
  - Purpose: proof inspection, checklist, endorsement review.
  - Status: **NOT IMPLEMENTED** (Backend ready)
  
- ❌ **Payout Approval**
  - Purpose: manual payout approvals where needed.
  - Status: **NOT IMPLEMENTED** (Functions exist: `approvePayout`)
  
- ❌ **Basic Analytics**
  - Purpose: daily totals, fees, payment success rate.
  - Status: **NOT IMPLEMENTED**

## Web Platform Additions
- ✅ **Web Donation Screen** (`web_donation_screen.dart`)
  - Purpose: Placeholder for web donations with app download prompt
  - Status: Complete (shows payment coming soon message)

---

## MVP Non-Negotiables
- Donor flow must not require account creation.
- Payments must be verified server-side before recording donations.
- Mobile Money flows must be first-class.

## Screen Principles
- One primary action per screen.
- No screen should require scrolling to understand its purpose.
- Every payment-related screen must show clear status feedback.

---

## Summary

### Completed: 17/24 screens (71%)
**Mobile App Functional:** ✅  
**Web App Foundation:** ✅  
**Admin Panel:** ❌ (0/5 screens)

### Priority Missing Screens (for MVP completion):
1. **Post Update Screen** - Critical for campaign transparency
2. **Verification Pending Screen** - Important for creator experience  
3. **Campaign Closed Screen** - Handles expired/completed campaigns
4. **Support/Contact Screen** - Essential for trust and safety

### Admin Screens (Can be built as separate web app):
- All backend Cloud Functions are implemented
- Admin UI can be built using Firebase Hosting
- Recommend building admin panel after mobile MVP launch

### Next Actions:
1. Implement 4 missing creator/utility screens
2. Test end-to-end flows on mobile
3. Consider admin panel as Phase 9 (post-MVP)
4. Complete web payment integration

**Repository:** https://github.com/benardgomashie/wamo  
**Documentation:** See IMPLEMENTATION_PLAN.md for detailed status
