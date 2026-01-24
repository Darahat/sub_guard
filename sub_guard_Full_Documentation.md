#  [Core problem (clear scope)]{.mark} {#core-problem-clear-scope .unnumbered}

# [People:]{.mark} {#people .unnumbered}

# [Forget free trials]{.mark}

# [Don't know how many subscriptions they have]{.mark}

# [Don't notice price increases]{.mark}

# [Feel cancellation is annoying or confusing]{.mark}

# [Your app does ONE thing extremely well:]{.mark} {#your-app-does-one-thing-extremely-well .unnumbered}

# ["Show me where my money leaks every month and stop it before renewal."]{.mark} {#show-me-where-my-money-leaks-every-month-and-stop-it-before-renewal. .unnumbered}

#  {#section .unnumbered}

# [3. Requirement Analysis (Mobile-first MVP)]{.mark} {#requirement-analysis-mobile-first-mvp .unnumbered}

# [3.1 User roles]{.mark} {#user-roles .unnumbered}

# [Only one role initially:]{.mark} {#only-one-role-initially .unnumbered}

# [User]{.mark}

# [(No admin dashboard in MVP -- use logs + basic panel later)]{.mark} {#no-admin-dashboard-in-mvp-use-logs-basic-panel-later .unnumbered}

#  {#section-1 .unnumbered}

# [3.2 Functional Requirements]{.mark} {#functional-requirements .unnumbered}

# [1. Authentication]{.mark} {#authentication .unnumbered}

# [Email + password]{.mark}

# [Google Sign-In]{.mark}

# [Apple Sign-In (important for iOS trust)]{.mark}

# [Optional: anonymous → convert later]{.mark}

#  {#section-2 .unnumbered}

# [2. Subscription Detection (core value)]{.mark} {#subscription-detection-core-value .unnumbered}

# [Phase 1 (MVP -- realistic for solo dev):]{.mark} {#phase-1-mvp-realistic-for-solo-dev .unnumbered}

# [Email scan (Gmail / Outlook permission)]{.mark}

# [Parse receipts:]{.mark}

# ["Your subscription"]{.mark}

# ["Renewal"]{.mark}

# ["Invoice"]{.mark}

# [Detect:]{.mark}

# [Service name]{.mark}

# [Amount]{.mark}

# [Billing cycle]{.mark}

# [Renewal date]{.mark}

# [Phase 2 (later):]{.mark} {#phase-2-later .unnumbered}

# [Manual add/edit]{.mark}

# [Bank integration (Plaid-like) → expensive, optional]{.mark}

#  {#section-3 .unnumbered}

# [3. Subscription Dashboard]{.mark} {#subscription-dashboard .unnumbered}

# [Each subscription shows:]{.mark} {#each-subscription-shows .unnumbered}

# [App / Service name (logo)]{.mark}

# [Monthly or yearly cost]{.mark}

# [Next renewal date]{.mark}

# [Status:]{.mark}

# [Active]{.mark}

# [Trial]{.mark}

# [Cancelled]{.mark}

# ["Cancel help" button]{.mark}

#  {#section-4 .unnumbered}

# [4. Smart Alerts (must be excellent)]{.mark} {#smart-alerts-must-be-excellent .unnumbered}

# [7 days before renewal]{.mark}

# [3 days before renewal]{.mark}

# [Same day reminder]{.mark}

# [Price increase detection (email comparison)]{.mark}

# [Notification channels:]{.mark} {#notification-channels .unnumbered}

# [Push notification]{.mark}

# [Email]{.mark}

# [In-app alert]{.mark}

#  {#section-5 .unnumbered}

# [5. Cancel Assistance (huge differentiator)]{.mark} {#cancel-assistance-huge-differentiator .unnumbered}

# [You do NOT cancel on behalf initially (legal risk).]{.mark} {#you-do-not-cancel-on-behalf-initially-legal-risk. .unnumbered}

# [Instead:]{.mark} {#instead .unnumbered}

# [Show:]{.mark}

# [Direct cancellation link]{.mark}

# [Step-by-step instructions (screenshots / text)]{.mark}

# [Mark as "Cancelled" manually]{.mark}

# [Later: affiliate redirect]{.mark}

#  {#section-6 .unnumbered}

# [6. Insights & Waste Tracking]{.mark} {#insights-waste-tracking .unnumbered}

# [Simple but powerful:]{.mark} {#simple-but-powerful .unnumbered}

# [Monthly spend]{.mark}

# [Yearly projection]{.mark}

# ["Unused for 30/60/90 days" (user confirms)]{.mark}

# ["You could save \$X this month"]{.mark}

# [This creates emotional payoff.]{.mark} {#this-creates-emotional-payoff. .unnumbered}

#  {#section-7 .unnumbered}

# [3.3 Non-Functional Requirements]{.mark} {#non-functional-requirements .unnumbered}

# [Fast startup (\<2s)]{.mark}

# [Offline read access]{.mark}

# [Encrypted sensitive data]{.mark}

# [Battery-friendly background jobs]{.mark}

# [Scales to 50k users without rewrite]{.mark}

#  {#section-8 .unnumbered}

# [4. Architecture (Clean, solo-friendly, 2025-ready)]{.mark} {#architecture-clean-solo-friendly-2025-ready .unnumbered}

# [4.1 High-level architecture]{.mark} {#high-level-architecture .unnumbered}

# [Mobile App (Flutter)]{.mark} {#mobile-app-flutter .unnumbered}

#  [\|]{.mark} {#section-9 .unnumbered}

# [API Gateway (REST)]{.mark} {#api-gateway-rest .unnumbered}

#  [\|]{.mark} {#section-10 .unnumbered}

# [Backend (Modular Monolith)]{.mark} {#backend-modular-monolith .unnumbered}

#  [\|]{.mark} {#section-11 .unnumbered}

# [Database + Queue + Email Parser]{.mark} {#database-queue-email-parser .unnumbered}

# [No microservices. Solo dev = fewer moving parts.]{.mark} {#no-microservices.-solo-dev-fewer-moving-parts. .unnumbered}

#  {#section-12 .unnumbered}

# [5. Technology Stack (strict recommendation)]{.mark} {#technology-stack-strict-recommendation .unnumbered}

# [Mobile App]{.mark} {#mobile-app .unnumbered}

# [Flutter]{.mark} {#flutter .unnumbered}

# [One codebase]{.mark}

# [Fast iteration]{.mark}

# [Great UI control]{.mark}

# [Push notifications easy]{.mark}

# [State management:]{.mark} {#state-management .unnumbered}

# [Riverpod (you already prefer it 👍)]{.mark}

# [Local storage:]{.mark} {#local-storage .unnumbered}

# [Hive (encrypted box)]{.mark}

#  {#section-13 .unnumbered}

# [Backend]{.mark} {#backend .unnumbered}

# [Laravel 11+ Why:]{.mark} {#laravel-11-why .unnumbered}

# [You already know it]{.mark}

# [Queues, mail parsing, auth = easy]{.mark}

# [Faster shipping than Node for this use case]{.mark}

# [Architecture:]{.mark} {#architecture .unnumbered}

# [Modular monolith]{.mark}

# [Service layer (important)]{.mark}

# [Queue workers]{.mark}

#  {#section-14 .unnumbered}

# [Database]{.mark} {#database .unnumbered}

# [PostgreSQL]{.mark}

# [Time-based queries + analytics friendly]{.mark}

#  {#section-15 .unnumbered}

# [Background Jobs]{.mark} {#background-jobs .unnumbered}

# [Laravel Queue + Redis]{.mark}

# [Email scanning]{.mark}

# [Renewal detection]{.mark}

# [Notifications]{.mark}

#  {#section-16 .unnumbered}

# [Email Integration]{.mark} {#email-integration .unnumbered}

# [Gmail API]{.mark}

# [Outlook API]{.mark}

# [Read-only permission]{.mark}

# [Parse with:]{.mark} {#parse-with .unnumbered}

# [Regex + heuristics (not AI first)]{.mark}

# [AI parsing later for edge cases]{.mark}

#  {#section-17 .unnumbered}

# [Notifications]{.mark} {#notifications-1 .unnumbered}

# [Firebase Cloud Messaging (FCM)]{.mark}

# [Apple Push Notification Service (APNS)]{.mark}

#  {#section-18 .unnumbered}

# [Payments]{.mark} {#payments .unnumbered}

# [Stripe]{.mark}

# [Monthly + yearly plan]{.mark}

# [Free trial (7 days)]{.mark}

#  {#section-19 .unnumbered}

# [Hosting]{.mark} {#hosting .unnumbered}

# [Backend: DigitalOcean / Hetzner]{.mark}

# [Queue worker: same server initially]{.mark}

# [Storage: S3-compatible (DO Spaces)]{.mark}

#  {#section-20 .unnumbered}

# [6. Internal Architecture (important)]{.mark} {#internal-architecture-important .unnumbered}

# [Domain Modules]{.mark} {#domain-modules .unnumbered}

# [Auth]{.mark} {#auth .unnumbered}

# [Users]{.mark} {#users .unnumbered}

# [Subscriptions]{.mark} {#subscriptions .unnumbered}

# [EmailParser]{.mark} {#emailparser .unnumbered}

# [Notifications]{.mark} {#notifications-2 .unnumbered}

# [Insights]{.mark} {#insights .unnumbered}

# [Billing]{.mark} {#billing .unnumbered}

# [Each module has:]{.mark} {#each-module-has .unnumbered}

# [Controller]{.mark}

# [Service]{.mark}

# [Repository]{.mark}

# [DTOs]{.mark}

# [Never put logic in controllers.]{.mark} {#never-put-logic-in-controllers. .unnumbered}

#  {#section-21 .unnumbered}

# [Example flow (email scan)]{.mark} {#example-flow-email-scan .unnumbered}

# [Cron Job →]{.mark} {#cron-job .unnumbered}

# [EmailParserService →]{.mark} {#emailparserservice .unnumbered}

# [Detect Subscription →]{.mark} {#detect-subscription .unnumbered}

# [SubscriptionService →]{.mark} {#subscriptionservice .unnumbered}

# [Save / Update →]{.mark} {#save-update .unnumbered}

# [Trigger Notification Job]{.mark} {#trigger-notification-job .unnumbered}

#  {#section-22 .unnumbered}

# [7. UI & UX (this decides success)]{.mark} {#ui-ux-this-decides-success .unnumbered}

# [Design principles (2025--26)]{.mark} {#design-principles-202526 .unnumbered}

# [Calm UI]{.mark}

# [Minimal colors]{.mark}

# [Finance = trust]{.mark}

# [No clutter]{.mark}

# [One action per screen]{.mark}

#  {#section-23 .unnumbered}

# [Main Screens]{.mark} {#main-screens .unnumbered}

# [1. Onboarding]{.mark} {#onboarding .unnumbered}

# [3 screens max]{.mark}

# [Explain:]{.mark}

# ["We find subscriptions"]{.mark}

# ["We warn you"]{.mark}

# ["You save money"]{.mark}

# [Ask email access clearly]{.mark}

#  {#section-24 .unnumbered}

# [2. Home Dashboard]{.mark} {#home-dashboard .unnumbered}

# [Top:]{.mark} {#top .unnumbered}

# ["You spend \$124/month"]{.mark}

# ["You can save \$38"]{.mark}

# [List:]{.mark} {#list .unnumbered}

# [Subscriptions grouped by:]{.mark}

# [Renewing soon]{.mark}

# [Active]{.mark}

# [Trials]{.mark}

#  {#section-25 .unnumbered}

# [3. Subscription Detail]{.mark} {#subscription-detail .unnumbered}

# [Cost history]{.mark}

# [Renewal date]{.mark}

# [Cancel steps]{.mark}

# [Mark cancelled]{.mark}

#  {#section-26 .unnumbered}

# [4. Insights]{.mark} {#insights-1 .unnumbered}

# [Monthly bar chart]{.mark}

# [Top 3 money leaks]{.mark}

# [Yearly projection]{.mark}

#  {#section-27 .unnumbered}

# [5. Settings]{.mark} {#settings .unnumbered}

# [Notification control]{.mark}

# [Email provider]{.mark}

# [Export data]{.mark}

# [Delete account]{.mark}

#  {#section-28 .unnumbered}

# [UX tricks (small but powerful)]{.mark} {#ux-tricks-small-but-powerful .unnumbered}

# [Green when you save money]{.mark}

# [Red only for urgent renewal]{.mark}

# [Haptic feedback on cancel mark]{.mark}

# [Celebration animation when user saves \$X]{.mark}

# [People love emotional reward.]{.mark} {#people-love-emotional-reward. .unnumbered}

#  {#section-29 .unnumbered}

# [8. Monetization Strategy (realistic)]{.mark} {#monetization-strategy-realistic .unnumbered}

# [Free]{.mark} {#free .unnumbered}

# [Track up to 3 subscriptions]{.mark}

# [Basic alerts]{.mark}

# [Pro (\$6--8/month)]{.mark} {#pro-68month .unnumbered}

# [Unlimited tracking]{.mark}

# [Smart alerts]{.mark}

# [Insights]{.mark}

# [Price change detection]{.mark}

# [Affiliate (later)]{.mark} {#affiliate-later .unnumbered}

# [Redirect to cancellation pages]{.mark}

# [Partner offers (VPN, cloud tools)]{.mark}

# [💡 Only 170 paying users × \$6 = \$1,020/month]{.mark} {#only-170-paying-users-6-1020month .unnumbered}

# [This is achievable.]{.mark} {#this-is-achievable. .unnumbered}

#  {#section-30 .unnumbered}

# [9. Development Roadmap (solo dev friendly)]{.mark} {#development-roadmap-solo-dev-friendly .unnumbered}

# [Week 1--2]{.mark} {#week-12 .unnumbered}

# [UX wireframes]{.mark}

# [DB schema]{.mark}

# [Auth]{.mark}

# [Subscription model]{.mark}

# [Week 3--4]{.mark} {#week-34 .unnumbered}

# [Email parsing]{.mark}

# [Background jobs]{.mark}

# [Push notifications]{.mark}

# [Week 5]{.mark} {#week-5 .unnumbered}

# [Insights]{.mark}

# [Polishing UI]{.mark}

# [Stripe integration]{.mark}

# [Week 6]{.mark} {#week-6 .unnumbered}

# [Beta testing]{.mark}

# [Fix parsing errors]{.mark}

# [App store prep]{.mark}

#  {#section-31 .unnumbered}

# [10. Launch strategy (important)]{.mark} {#launch-strategy-important .unnumbered}

# [Soft launch on Reddit:]{.mark}

# [r/personalfinance]{.mark}

# [r/Frugal]{.mark}

# [Not "I built an app"]{.mark}

# [Ask: *"How do you track subscriptions?"*]{.mark}

# [Offer early access]{.mark}

#  {#section-32 .unnumbered}

# [11. Why this can win]{.mark} {#why-this-can-win .unnumbered}

# [Clear pain]{.mark}

# [Emotional payoff (saving money)]{.mark}

# [Simple UI]{.mark}

# [No heavy AI dependency]{.mark}

# [Solo-friendly tech]{.mark}

# [Subscription revenue]{.mark}

#  {#section-33 .unnumbered}

#  {#section-34 .unnumbered}

# SubGuard -- Subscription Tracking App Full Technical & Product Documentation {#subguard-subscription-tracking-app-full-technical-product-documentation .unnumbered}

## 1. Database Schema {#database-schema .unnumbered}

Users\
- id (uuid)\
- name\
- email\
- password\
- provider (email/google/apple)\
- created_at\
- updated_at\
\
Subscriptions\
- id (uuid)\
- user_id (fk)\
- service_name\
- service_logo\
- amount\
- currency\
- billing_cycle (monthly/yearly/trial)\
- renewal_date\
- status (active/cancelled/trial)\
- created_at\
- updated_at\
\
Subscription_Emails\
- id\
- subscription_id\
- email_subject\
- sender\
- received_at\
\
Notifications\
- id\
- user_id\
- subscription_id\
- type (7day/3day/sameday/price_change)\
- sent_at\
\
Insights\
- id\
- user_id\
- month\
- total_spend\
- potential_savings

## 2. API Endpoint List {#api-endpoint-list .unnumbered}

Auth\
POST /api/auth/register\
POST /api/auth/login\
POST /api/auth/google\
POST /api/auth/apple\
\
Subscriptions\
GET /api/subscriptions\
POST /api/subscriptions\
PUT /api/subscriptions/{id}\
DELETE /api/subscriptions/{id}\
\
Email Parsing\
POST /api/email/connect\
POST /api/email/sync\
\
Notifications\
GET /api/notifications\
POST /api/notifications/test\
\
Insights\
GET /api/insights/monthly\
GET /api/insights/yearly\
\
Billing\
POST /api/billing/subscribe\
POST /api/billing/cancel

## 3. Flutter Folder Structure {#flutter-folder-structure .unnumbered}

lib/\
├── core/\
│ ├── theme/\
│ ├── router/\
│ ├── services/\
│ └── utils/\
├── features/\
│ ├── auth/\
│ ├── dashboard/\
│ ├── subscriptions/\
│ ├── insights/\
│ ├── notifications/\
│ └── billing/\
├── shared/\
│ ├── widgets/\
│ └── models/\
└── main.dart

## 4. Email Parsing Logic {#email-parsing-logic .unnumbered}

Step 1: User grants Gmail/Outlook read-only permission\
Step 2: Backend cron fetches recent emails\
Step 3: Filter emails by keywords:\
- subscription\
- renewal\
- invoice\
- receipt\
\
Step 4: Regex extract:\
- Service name\
- Amount\
- Currency\
- Billing cycle\
- Renewal date\
\
Step 5: Match with existing subscription\
- If exists → update\
- Else → create new subscription\
\
Step 6: Queue notification jobs

## 5. MVP Figma-style Screen Breakdown {#mvp-figma-style-screen-breakdown .unnumbered}

Onboarding\
- 3 screens (value explanation)\
- Email connect CTA\
\
Home Dashboard\
- Total monthly spend\
- Savings highlight\
- Subscription list\
\
Subscription Detail\
- Cost history\
- Renewal countdown\
- Cancel instructions\
\
Insights\
- Monthly bar chart\
- Top spenders\
\
Settings\
- Notification preferences\
- Email provider\
- Account delete
