Perfect. What you’re asking for is essentially a **“builder prompt”** — a context instruction you can give to an autonomous agent (or keep as your own north star) so the app is built **correctly without constant supervision**.

Below is a **clean, production-grade Context Instruction** tailored exactly for **Wamo**.

You can paste this directly into an autonomous AI, internal doc, or project kickoff.

---

# Context Instruction

**Autonomous Product Creation for Wamo**

## Product Identity

You are building **Wamo**, a mobile-first crowdfunding application for Africa.

**Meaning:** “Wamo” means *help* in Ga
**Tagline:** **Give. Help. Reach.**

Wamo exists to make fundraising in Africa accessible, trustworthy, and effective using local payment systems and community trust.

---

## Core Problem

People in Africa want to raise and donate money for urgent and everyday needs, but existing crowdfunding platforms are inaccessible, incompatible with local payments, or untrustworthy. This forces people to rely on informal, risky methods.

The problem is **not lack of generosity**, but **lack of infrastructure built for African realities**.

---

## Product Goals

* Enable fast and trusted fundraising
* Support local payment methods (starting with Paystack)
* Reduce friction for donors
* Enforce accountability for campaign creators
* Be mobile-first, low-data, and simple

---

## Target Users

1. **Campaign Creators**

   * Individuals or communities raising funds
   * Must be registered and verified
2. **Donors**

   * Local (Mobile Money)
   * Diaspora (cards)
   * Registration optional

---

## Core Principles (Non-Negotiable)

* Trust before growth
* Friction on receivers, not givers
* Transparency at every step
* Speed in emergencies
* Design for low bandwidth and mobile use

If a feature violates any of these, it should not be built.

---

## Functional Requirements

### Campaign Creators

* Must register using phone number + OTP
* Must submit proof and payout details
* Can create, edit, and track campaigns
* Can post updates and upload receipts
* Can see real-time progress and payout status

### Donors

* Can donate without creating an account
* Can pay using Paystack (Mobile Money + cards)
* Can donate anonymously
* Must see clear fee breakdown before payment
* Receive confirmation after donation

---

## Payments & Fees

* Use **Paystack** for all payments (initial phase)
* Wamo charges a **platform fee (3–5%)**
* Payment processing fees are shown transparently
* Fees are donor-paid by default
* Failed transactions are not charged

Paystack handles payment confirmation.
Wamo controls campaign logic, escrow, and payouts.

---

## Payout Logic

* Funds go into Wamo-controlled escrow
* No automatic payout for first-time creators
* Verified creators may receive conditional automatic payout
* Always include a delay buffer and admin override
* Payout status must be clearly visible to creators

---

## Essential Screens

* Splash / Branding
* Home
* Campaign Creation (multi-step)
* Campaign Page
* Donation Screen
* Payment Processing
* Payment Result
* Creator Dashboard
* Updates & Proof
* Payout Status
* Notifications



---

## Technical Constraints

* Build with **Flutter**
* Use **Firebase** (Auth, Firestore, Functions, Storage)
* Firebase free tier is acceptable for MVP
* Do not store sensitive payment data
* All payment confirmation must be validated via backend (webhooks)

---

## MVP Scope

INCLUDE:

* One country
* Individual campaigns
* Manual verification
* Paystack payments
* WhatsApp sharing
* Creator dashboard

EXCLUDE:


* AI fraud detection
* blockchain Wallets 
* Smart contracts
*

---

## UX Rules

* Campaign creation < 5 minutes
* Donation flow < 30 seconds
* No forced donor registration
* Clear status messaging at all times
* Error messages must be human, not technical

If a stressed user cannot understand what’s happening, the design has failed.

---

## Success Criteria

* Users trust the platform
* Donations complete reliably
* Campaign creators understand their progress and payouts
* Fees are accepted without backlash
* Support requests are minimal and predictable

---

## Final Instruction

Build Wamo as **infrastructure for help**, not just an app.
> Does this make it easier to give, safer to help, or faster to reach?