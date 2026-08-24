# SubGuard — Notification & Exact Alarms Specification

**Notification Engine:** `flutter_local_notifications` (v18.0+)  
**Timezone Management:** `timezone` package (v0.10+) with IANA database  
**Scheduling Strategy:** Exact Alarms (`zonedSchedule`) with `androidAllowWhileIdle: true`  
**Document Version:** 2.0  
**Last Updated:** August 2026  

---

## 1. Core Philosophy: Zero-Failure Watchdog

In subscription tracking, **a missed reminder is a critical defect**. SubGuard treats notification scheduling with the same rigor as an alarm clock app.

### Key Tenets
1. **Never Depend on Background Timers:** We do not rely on fragile periodic background timers that Android OS or iOS kills in power-saving/Doze mode.
2. **Exact Native OS Alarms:** We register exact system-level alarms directly into Android's `AlarmManager` and iOS `UNNotificationRequest`.
3. **Reboot Survival:** All active subscription schedules are stored in local `Isar` DB and automatically re-registered upon device reboot (`BOOT_COMPLETED`).
4. **Timezone Awareness:** All calculations use standard IANA timezones to prevent notifications from drifting after traveling or daylight savings adjustments.

---

## 2. Multi-Stage Alert Schedule Matrix

```
       [ Subscription Created / Updated ]
                       │
       ┌───────────────┴───────────────┐
       ▼                               ▼
[ Normal Renewal Track ]       [ Free Trial Track ]
       │                               │
       ├─ 7 Days Before                ├─ 3 Days Before
       ├─ 2 Days Before                ├─ 1 Day Before
       ├─ 1 Day Before                 │
       ├─ Day of Renewal (Morning)     ▼
       │                       [ Trial Conversion ]
       ▼
 [ Charge Date Passes ]
       │
       ▼
 [ Post-Billing Confirmation Prompt ]
 (Next Day: "Did this charge occur?")
```

### 2.1 Standard Subscriptions
| Timing | Trigger | Notification Title & Copy | Action / Route |
| :--- | :--- | :--- | :--- |
| **7 Days Before** | `renewalDate - 7d @ 09:00` | **Upcoming Renewal in 7 Days**<br>`{serviceName}` will renew for `{amount} {currency}`. | Open Subscription Detail |
| **2 Days Before** | `renewalDate - 2d @ 09:00` | **Action Required: Renewal in 48 Hours**<br>`{serviceName}` renews soon. Review or cancel. | Open Cancel Guide |
| **1 Day Before** | `renewalDate - 1d @ 18:00` | **Renewal Tomorrow**<br>`{serviceName}` will charge `{amount}` tomorrow. | Open Subscription Detail |
| **Renewal Day** | `renewalDate @ 08:00` | **Renewing Today**<br>`{serviceName}` renews today. | Open Subscription Detail |
| **Day After Renewal**| `renewalDate + 1d @ 10:00` | **Payment Confirmation**<br>Did your `{amount}` charge for `{serviceName}` go through? | Payment Confirm Dialog |

### 2.2 Free Trials
| Timing | Trigger | Notification Title & Copy | Action / Route |
| :--- | :--- | :--- | :--- |
| **3 Days Before** | `trialEndDate - 3d @ 09:00` | **Trial Ending Soon (3 Days Left)**<br>Cancel `{serviceName}` before it converts to paid plan. | Open Cancel Guide |
| **1 Day Before** | `trialEndDate - 1d @ 12:00` | **Urgent: Trial Ends Tomorrow**<br>`{serviceName}` will convert to `{amount}/mo` tomorrow. | Open Cancel Guide |

---

## 3. Platform Native Configuration

### 3.1 Android Configuration (`AndroidManifest.xml`)
Android 13+ (API 33) requires explicit notification permissions, and Android 14+ (API 34) enforces exact alarm policies:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Notification & Alarm Permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

    <application>
        <!-- Boot Receiver for Reboot Rescheduling -->
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
                  android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
        
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
                  android:exported="true" />
    </application>
</manifest>
```

### 3.2 Android Notification Channels
SubGuard defines 3 distinct user-configurable channels:
1. `subscription_reminders`: High Importance, Sound, Vibration (Renewal warnings).
2. `trial_alerts`: Max Importance, Sound, Urgent Heads-up (Trial expirations).
3. `payment_confirmations`: Default Importance (Post-billing confirmations).

### 3.3 iOS Configuration (`Info.plist`)
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## 4. Date Arithmetic & Edge Case Protection

### 4.1 Month-End Safe Calculations
Naively adding 1 month in programming languages often causes the **"January 31st Problem"** (Jan 31 + 1 month -> March 3rd). SubGuard uses safe calendar clamping:

```dart
DateTime computeNextBillingDate(DateTime currentBillingDate, BillingCycle cycle) {
  switch (cycle) {
    case BillingCycle.daily:
      return currentBillingDate.add(const Duration(days: 1));
    case BillingCycle.weekly:
      return currentBillingDate.add(const Duration(days: 7));
    case BillingCycle.monthly:
      return _addMonthsClamped(currentBillingDate, 1);
    case BillingCycle.quarterly:
      return _addMonthsClamped(currentBillingDate, 3);
    case BillingCycle.yearly:
      return _addMonthsClamped(currentBillingDate, 12);
  }
}

DateTime _addMonthsClamped(DateTime date, int monthsToAdd) {
  final targetYear = date.year + ((date.month + monthsToAdd - 1) ~/ 12);
  final targetMonth = ((date.month + monthsToAdd - 1) % 12) + 1;
  final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
  final targetDay = date.day > daysInTargetMonth ? daysInTargetMonth : date.day;
  return DateTime(targetYear, targetMonth, targetDay, date.hour, date.minute);
}
```
