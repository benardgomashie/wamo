# Wamo Admin Panel

Next.js admin dashboard for managing the Wamo crowdfunding platform.

## Features

- **Campaign Review**: Approve, reject, freeze, or request more info from campaigns
- **3-Level Verification**: Identity, Need, and Payout verification system
- **Red Flag Detection**: Automatic detection of suspicious patterns
- **Payout Management**: Review and approve payout requests
- **Transactions**: Monitor all donations and payment activity
- **Community Reports**: Handle flagged campaigns from users
- **Search**: Find campaigns by ID, phone number, or name
- **Audit Logs**: Complete history of all admin actions (legal compliance)
- **Analytics Dashboard**: Platform metrics and insights
- **Real-time Stats**: Live dashboard with today's activity
- **Firebase Integration**: Authentication, Firestore, Cloud Functions

## Tech Stack

- **Framework**: Next.js 16.1.6 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS 4
- **Backend**: Firebase (Auth, Firestore, Functions)
- **UI Components**: Radix UI + Custom components

## Getting Started

### Prerequisites

- Node.js 18+ installed
- Firebase project with project ID: `wamo-26a85`
- Admin user in Firestore with `role: 'admin'`

### Installation

1. Install dependencies:
```bash
npm install
```

2. Configure Firebase:
   - Go to [Firebase Console](https://console.firebase.google.com/project/wamo-26a85/settings/general)
   - Copy your Web API Key
   - Update `.env.local` file with your Firebase credentials

3. Create an admin user:
   - Go to Firebase Console > Firestore Database
   - Find your user document in the `users` collection
   - Add field: `role` = `"admin"`

### Development

Run the development server:
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build

Build for production:
```bash
npm run build
```

## Project Structure

```
admin/
├── src/
│   ├── app/
│   │   ├── login/                 # Admin login page
│   │   ├── dashboard/
│   │   │   ├── page.tsx          # Dashboard home (real-time stats)
│   │   │   ├── campaigns/        # Campaign review with verification
│   │   │   ├── payouts/          # Payout approval
│   │   │   ├── transactions/     # All donations & payments
│   │   │   ├── reports/          # Community-reported campaigns
│   │   │   ├── search/           # Search by ID/phone/name
│   │   │   ├── audit/            # Audit logs (legal compliance)
│   │   │   └── analytics/        # Analytics dashboard
│   │   └── layout.tsx
│   ├── components/
│   │   ├── ui/                    # UI components (Button, Card, Badge, Dialog)
│   │   ├── layout/               # Layout components (Sidebar, Navbar)
│   │   └── campaign-detail-modal.tsx # Verification modal
│   ├── lib/
│   │   ├── firebase/             # Firebase config & helpers
│   │   └── utils.ts              # Utility functions
│   └── types/                    # TypeScript interfaces
└── .env.local                    # Firebase configuration
```

## Firebase Cloud Functions

The admin panel integrates with these Cloud Functions:

**Campaign Management:**
- `approveCampaign`: Approve a pending campaign
- `rejectCampaign`: Reject a campaign with reason
- `freezeCampaign`: Suspend a campaign
- `requestMoreInfo`: Request additional documents from creator
- `updateVerification`: Update 3-level verification checklist
- `detectRedFlags`: Auto-detect suspicious patterns (background trigger)

**Payout Management:**
- `approvePayout`: Approve a payout request
- `rejectPayout`: Reject a payout with reason
- `holdPayout`: Hold a payout pending review

**Audit & Compliance:**
- `createAuditLog`: Record all admin actions (called automatically)

All admin functions create audit log entries for legal compliance.

## Design System

- **Primary Color**: #2FA4A9 (Wamo Teal)
- **Secondary Color**: #F39C3D (Wamo Orange)
- **Status Colors**:
  - Success: Green
  - Warning: Orange
  - Error: Red
  - Inactive: Gray

## Authentication

- Email/password authentication via Firebase Auth
- Admin role verification in Firestore
- Protected routes with auth checks
- Session management with `onAuthStateChanged`

## Environment Variables

Required variables in `.env.local`:

```
NEXT_PUBLIC_FIREBASE_API_KEY=your-api-key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=wamo-26a85.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=wamo-26a85
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=wamo-26a85.firebasestorage.app
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your-sender-id
NEXT_PUBLIC_FIREBASE_APP_ID=your-app-id
```

## Security

- All admin routes are protected with authentication checks
- Admin role verified both at login and in protected layout
- Firebase security rules should restrict admin functions to users with `role === 'admin'`

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
