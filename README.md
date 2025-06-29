
# Stacktendance - Clarity Event Management & Reward Contract

This smart contract allows the creation and management of blockchain-based events, tracking user attendance, verifying participation, and rewarding attendees based on their engagement. It is implemented in [Clarity](https://docs.stacks.co/docs/clarity-overview), the smart contract language for the [Stacks](https://stacks.co/) blockchain.

---

## 📋 Features

* **Event Creation** by the contract owner
* **User Attendance Tracking** (check-in / check-out)
* **Event Attendance Verification**
* **Tiered Reward System** for attendees
* **Access Control** for verifiers and event organizers
* **On-chain record of events and attendance**

---

## 📂 Contract Structure

### Constants

#### Errors

Custom error codes:

```lisp
ERR-NOT-AUTHORIZED        ; u100
ERR-ALREADY-CLAIMED       ; u101
ERR-EVENT-NOT-ENDED       ; u102
ERR-EVENT-ENDED           ; u103
ERR-NO-REWARD             ; u104
ERR-EVENT-NOT-FOUND       ; u105
ERR-INSUFFICIENT-FUNDS    ; u106
ERR-INVALID-DURATION      ; u107
ERR-ALREADY-REGISTERED    ; u108
ERR-INVALID-START-HEIGHT  ; u110
ERR-INVALID-REWARD        ; u111
ERR-INVALID-MIN-ATTENDANCE; u112
ERR-INVALID-NAME          ; u2000
ERR-INVALID-DESCRIPTION   ; u2001
ERR-CONTAINS-INVALID-CHARS; u2002
```

#### Limits

```lisp
MIN-NAME-LENGTH: 3
MAX-NAME-LENGTH: 50
MIN-DESC-LENGTH: 10
MAX-DESC-LENGTH: 200
MIN-DURATION: 144 (blocks)
MAX-DURATION: 52560 (blocks)
MAX-REWARD: 1,000,000,000,000 microSTX
```

---

## 🗃️ Data Variables

| Variable           | Type        | Description                        |
| ------------------ | ----------- | ---------------------------------- |
| `contract-owner`   | `principal` | Owner of the contract              |
| `event-counter`    | `uint`      | ID counter for events              |
| `treasury-balance` | `uint`      | Balance of the contract's treasury |

---

## 🧱 Data Maps

### `events (uint → Event)`

Stores all event data.

```lisp
{
  name: string-ascii (max 50),
  description: string-ascii (max 200),
  start-height: uint,
  end-height: uint,
  base-reward: uint,
  bonus-reward: uint,
  min-attendance-duration: uint,
  organizer: principal,
  is-active: bool
}
```

### `event-attendance ({event-id, attendee} → Attendance)`

Stores user check-in/check-out.

```lisp
{
  check-in-height: uint,
  check-out-height: uint,
  duration: uint,
  verified: bool
}
```

### `verification-details ({event-id, attendee} → Verification)`

Stores who verified an attendee.

```lisp
{
  verified-by: principal,
  verified-at: uint
}
```

### `rewards-claimed ({event-id, attendee} → RewardClaim)`

Tracks claimed rewards.

```lisp
{
  amount: uint,
  claimed-at: uint,
  reward-tier: uint
}
```

### `verifiers (principal → bool)`

Approved verifiers for event attendance.

---

## 🔍 Read-only Functions

| Function                | Description                                |
| ----------------------- | ------------------------------------------ |
| `get-owner`             | Returns contract owner                     |
| `get-event`             | Fetch event by ID                          |
| `get-attendance-record` | Fetch user's attendance for an event       |
| `get-reward-claim`      | Fetch claimed reward info                  |
| `is-verifier`           | Check if address is an authorized verifier |
| `event-exists`          | Check if event ID exists                   |

---

## 🚀 Public Functions

### ✅ `create-event(...)`

Creates a new event.

**Parameters**:

* `name`: Name of the event (3–50 ASCII chars)
* `description`: Description (10–200 ASCII chars)
* `start-height`: Block height to start
* `duration`: Duration in blocks (between `MIN-DURATION` and `MAX-DURATION`)
* `base-reward`: Minimum reward for eligible users
* `bonus-reward`: Additional reward for high-tier users
* `min-attendance`: Minimum attendance time for eligibility

**Returns**:

* `(ok event-id)` on success
* Errors if parameters are invalid or unauthorized

---

### 🕒 `check-in(event-id)`

Marks a user as checked-in to the event.

**Checks**:

* Event must exist and be active
* Must be within event's timeframe
* User must not have already checked in

**Returns**: `(ok true)` or error

---

### 🕔 `check-out(event-id)`

Marks a user as checked-out and calculates duration.

**Checks**:

* Must have checked in
* Current block > check-in height

**Returns**: `(ok duration)` or error

---

## 🔐 Security & Validations

* Only the **contract owner** can create events.
* Input fields are validated for ASCII content and length.
* All time-based operations rely on `stacks-block-height`.
* No user can check in twice or claim multiple rewards.

---

## 📈 Reward Logic (Planned or External)

Although the reward claiming logic is not yet implemented here, the structure is in place to:

* Claim rewards based on duration
* Differentiate tiers (e.g. base vs bonus)
* Prevent multiple claims
* Allow verification before disbursement

---

## 🔧 TODO (Suggested Enhancements)

* Add `claim-reward` function
* Add admin control to toggle verifier roles
* Add function to end events early
* Implement fund withdrawal or STX reward pool

---

## ✅ Example Usage Flow

1. Contract owner calls `create-event(...)`.
2. Users check in using `check-in(event-id)` after the event starts.
3. Users check out using `check-out(event-id)` before the event ends.
4. A verifier (or automated system) validates attendance.
5. User claims reward (functionality to be added).

---

## 📜 License

This contract is open source under the MIT License.

