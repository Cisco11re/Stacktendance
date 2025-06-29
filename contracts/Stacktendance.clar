
;; Stacktendance

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-CLAIMED (err u101))
(define-constant ERR-EVENT-NOT-ENDED (err u102))
(define-constant ERR-EVENT-ENDED (err u103))
(define-constant ERR-NO-REWARD (err u104))
(define-constant ERR-EVENT-NOT-FOUND (err u105))
(define-constant ERR-INSUFFICIENT-FUNDS (err u106))
(define-constant ERR-INVALID-DURATION (err u107))
(define-constant ERR-ALREADY-REGISTERED (err u108))


(define-constant MIN-NAME-LENGTH u3)
(define-constant MAX-NAME-LENGTH u50)
(define-constant MIN-DESC-LENGTH u10)
(define-constant MAX-DESC-LENGTH u200)
(define-constant ERR-INVALID-NAME (err u2000))
(define-constant ERR-INVALID-DESCRIPTION (err u2001))
(define-constant ERR-CONTAINS-INVALID-CHARS (err u2002))


(define-constant MAX-DURATION u52560) 
(define-constant MIN-DURATION u144)   
(define-constant MAX-REWARD u1000000000000) 
(define-constant ERR-INVALID-START-HEIGHT (err u110))
(define-constant ERR-INVALID-REWARD (err u111))
(define-constant ERR-INVALID-MIN-ATTENDANCE (err u112))


;; Data variables
(define-data-var contract-owner principal tx-sender)
(define-data-var event-counter uint u0)
(define-data-var treasury-balance uint u0)

;; Event struct
(define-map events 
    uint 
    {
        name: (string-ascii 50),
        description: (string-ascii 200),
        start-height: uint,
        end-height: uint,
        base-reward: uint,
        bonus-reward: uint,
        min-attendance-duration: uint,
        organizer: principal,
        is-active: bool
    })

;; Attendance tracking
(define-map event-attendance 
    { event-id: uint, attendee: principal }
    {
        check-in-height: uint,
        check-out-height: uint,
        duration: uint,
        verified: bool
    })

;; Separate map for verification details
(define-map verification-details
    { event-id: uint, attendee: principal }
    {
        verified-by: principal,
        verified-at: uint
    })


;; Rewards claimed
(define-map rewards-claimed
    { event-id: uint, attendee: principal }
    {
        amount: uint,
        claimed-at: uint,
        reward-tier: uint
    })

;; Verification authorities
(define-map verifiers principal bool)

;; Read-only functions
(define-read-only (get-owner)
    (var-get contract-owner))

(define-read-only (get-event (event-id uint))
    (map-get? events event-id))

(define-read-only (get-attendance-record (event-id uint) (attendee principal))
    (map-get? event-attendance {event-id: event-id, attendee: attendee}))

(define-read-only (get-reward-claim (event-id uint) (attendee principal))
    (map-get? rewards-claimed {event-id: event-id, attendee: attendee}))

(define-read-only (is-verifier (address principal))
    (default-to false (map-get? verifiers address)))

;; Helper function to check if string contains only valid characters
(define-private (is-valid-ascii (s (string-ascii 200)))
    (let ((len (len s)))
        (and
            ;; Check if length is greater than 0
            (> len u0)
            ;; Ensure first character isn't whitespace
            (not (is-eq (unwrap-panic (element-at s u0)) " "))
            ;; Ensure last character isn't whitespace
            (not (is-eq (unwrap-panic (element-at s (- len u1))) " ")))))
