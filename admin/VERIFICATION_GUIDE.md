# Wamo Campaign Verification System

This document explains how the **3-Level Verification System** works in the Wamo admin panel.

---

## Overview

Verification ensures that:
1. A **real person** created the campaign
2. The **need is plausible and current**
3. The **money will reach the right place**

---

## 3-Level Verification Checklist

### 🟡 Level 1: Identity Verification (Required)

**Purpose:** Confirm who is asking for help

**Creator Must Provide:**
- Phone number (OTP verified)
- Full name
- Government ID (Ghana Card, National ID, or Passport)
- Selfie or live photo (optional but recommended)

**Admin Checks:**
- ✅ Name matches ID
- ✅ ID is valid and readable
- ✅ Phone number is verified

**Red Flags:**
- Name mismatch between ID and account
- Multiple campaigns from same phone number
- Unverified phone number

---

### 🟢 Level 2: Need Verification (Required)

**Purpose:** Confirm why help is needed

**Accepted Proof by Category:**

| Category   | Required Documents                           |
|-----------|---------------------------------------------|
| Medical   | Hospital bill, doctor's note, admission slip |
| Education | School invoice, admission letter             |
| Funeral   | Funeral flyer, letter from family/church     |
| Emergency | Photos, letter from community leader         |

**Admin Checks:**
- ✅ Document is dated
- ✅ Names are consistent
- ✅ Proof is plausible
- ✅ No obvious red flags

**Red Flags:**
- No proof documents uploaded
- Reused images across multiple campaigns
- Document dates don't match story

---

### 🔵 Level 3: Payout Verification (Required)

**Purpose:** Confirm where money goes

**Creator Must Provide:**
- Mobile Money network (MTN, Vodafone, AirtelTigo)
- Mobile Money number
- OTP verification or test payment

**Admin Checks:**
- ✅ MoMo number is verified
- ✅ Name on MoMo matches creator (or explained)

**Red Flags:**
- Mobile Money not configured
- MoMo number not verified

---

## Admin Review Workflow

### Step 1: Campaign Submitted
- Status: `pending_review`
- Creator receives confirmation message
- Campaign appears in admin review queue

### Step 2: Admin Opens Campaign
Admin reviews:
1. **Identity** - Check ID, phone, selfie
2. **Need** - Review proof documents
3. **Payout** - Verify MoMo details

### Step 3: Admin Actions

#### ✅ Approve
- All 3 levels verified
- Campaign goes live (`active` status)
- Creator notified
- Verified badge shown to donors

#### 🟡 Request More Info
- Missing or unclear documents
- Creator receives notification with specific request
- Campaign stays in `pending_review`
- Creator can upload additional documents

#### ❌ Reject
- Verification failed
- Provide clear reason
- Campaign status: `rejected`
- Creator notified with reason

#### 🔴 Freeze
- Active campaign has issues
- Suspicious activity detected
- Campaign paused immediately
- Funds held in escrow

---

## Red Flag Detection

### Automatic Red Flags
The system automatically detects:

1. **Name Mismatch** - ID name ≠ Account name
2. **Duplicate Phone** - Same number used for multiple campaigns
3. **Reused Images** - Same proof photo in multiple campaigns
4. **Missing Documents** - Required verification not uploaded
5. **Unverified Contact** - Phone or MoMo not verified

### Manual Red Flags
Admin can add custom flags:
- Urgent pressure to bypass verification
- Story doesn't match proof documents
- Community reports or complaints
- Creator refuses to provide additional info

---

## Community Reporting

### How It Works
1. Donor clicks "Report this campaign"
2. Campaign auto-paused (`frozen`)
3. Funds held in escrow
4. Admin notified immediately
5. Campaign appears in **Reports Queue**

### Admin Actions on Reports
- **Review Details** - Check verification, story, proof
- **Approve & Unflag** - If report is unfounded
- **Reject** - If campaign violates terms
- **Freeze** - Hold campaign pending investigation

---

## Using the Admin Panel

### Campaign Review Page
**URL:** `/dashboard/campaigns`

**Features:**
- Filter by status (pending, active, rejected, frozen)
- See red flag indicators (⚠️)
- Quick actions: Approve, Reject, Request Info, Freeze
- "Review" button opens verification modal

### Verification Modal
Shows complete campaign details:

**Top Section:**
- Campaign info (title, creator, category, dates)
- Red flags alert (if any)

**Verification Checklist:**
- Toggle checkboxes for each level
- View ID documents (click to open)
- View proof documents (multiple files)
- Check MoMo verification status

**Bottom Section:**
- Add admin notes
- Save verification status

### Reports Queue
**URL:** `/dashboard/reports`

**Features:**
- All community-reported campaigns
- Red flag warnings prominently displayed
- Report count badge
- Priority actions (Approve & Unflag, Reject, Freeze)

---

## Best Practices

### ✅ DO
- Review all 3 levels before approving
- Add detailed admin notes
- Request specific missing info
- Check for red flags
- Review reported campaigns within 12 hours
- Be consistent with verification standards

### ❌ DON'T
- Approve campaigns with red flags without investigation
- Skip verification to grow faster
- Reject without clear explanation
- Share sensitive ID information
- Ignore community reports

---

## Verification SLA

| Action              | Target Time |
|--------------------|-------------|
| Initial review     | 12-24 hours |
| Info request reply | 24-48 hours |
| Report investigation | 6-12 hours |
| Final decision     | 48 hours max |

---

## What Donors See

### Verified Badge
✅ **Verified by Wamo**

**Tooltip:**
> "This campaign has been reviewed by Wamo. The creator's identity, need, and payout details have been verified."

### NO Internal Details Shown
Donors do NOT see:
- Admin notes
- Verification checklist status
- Red flags
- ID documents
- Specific verification levels

**Confidence > Complexity**

---

## Security Notes

1. **Access Control**
   - Only users with `role: 'admin'` in Firestore can access
   - Protected routes check authentication + role
   - Cloud Functions verify admin status

2. **Data Privacy**
   - ID documents stored securely in Firebase Storage
   - Sensitive info can be blurred by creator
   - Admin notes not visible to public

3. **Audit Trail**
   - All admin actions logged with timestamp
   - `approvedBy`, `rejectedBy` fields track decisions
   - Firebase Functions logs provide full history

---

## Cloud Functions Reference

### `requestMoreInfo`
**Purpose:** Ask creator for additional documents

**Parameters:**
- `campaignId` - Campaign to request info for
- `message` - Specific request (e.g., "Please upload hospital admission slip")

**Result:**
- Campaign updated with requested info
- Notification sent to creator
- Campaign stays in `pending_review`

### `updateVerification`
**Purpose:** Update verification checklist

**Parameters:**
- `campaignId` - Campaign to update
- `verification` - Object with:
  - `identityVerified` (boolean)
  - `needVerified` (boolean)
  - `momoVerified` (boolean)
  - `verificationNotes` (string)
  - `redFlags` (array of strings)

**Result:**
- Campaign verification status updated
- Changes saved to Firestore

### `detectRedFlags` (Automatic)
**Trigger:** When campaign is created or updated

**Checks:**
- Name mismatches
- Duplicate phone numbers
- Reused images
- Missing documents

**Result:**
- Red flags array updated automatically
- Admin alerted if flags found

---

## Support

For issues or questions about the verification system:
1. Check admin notes in campaign
2. Review Firebase Functions logs
3. Contact tech team

---

**Remember:** Verification protects everyone — especially Wamo.
