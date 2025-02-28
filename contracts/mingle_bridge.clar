;; Constants
(define-constant err-not-found (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-invalid-date (err u102))
(define-constant err-already-exists (err u103))

;; Data variables
(define-data-var next-event-id uint u1)
(define-map events 
  { event-id: uint }
  {
    title: (string-ascii 50),
    description: (string-ascii 500),
    date: uint,
    organizer: principal,
    capacity: uint,
    attendees: (list 50 principal),
    status: (string-ascii 10)
  }
)

(define-map user-profiles
  { user: principal }
  {
    interests: (list 10 (string-ascii 20)),
    reputation: uint,
    events-attended: (list 50 uint)
  }
)

;; Public functions
(define-public (create-event (title (string-ascii 50)) 
                            (description (string-ascii 500))
                            (date uint)
                            (organizer principal)
                            (capacity uint))
  (let ((event-id (var-get next-event-id)))
    (asserts! (> date block-height) err-invalid-date)
    (map-insert events
      { event-id: event-id }
      {
        title: title,
        description: description,
        date: date,
        organizer: organizer,
        capacity: capacity,
        attendees: (list),
        status: "active"
      }
    )
    (var-set next-event-id (+ event-id u1))
    (ok event-id)
  )
)

(define-public (rsvp-event (event-id uint) (attending bool))
  (let ((event (unwrap! (map-get? events { event-id: event-id }) err-not-found)))
    (if attending
      (begin
        (asserts! (< (len (get attendees event)) (get capacity event)) err-unauthorized)
        (map-set events { event-id: event-id }
          (merge event {
            attendees: (append (get attendees event) tx-sender)
          })
        )
        (ok true)
      )
      (ok false)
    )
  )
)

(define-read-only (get-event-details (event-id uint))
  (ok (unwrap! (map-get? events { event-id: event-id }) err-not-found))
)

(define-public (update-profile (interests (list 10 (string-ascii 20))))
  (ok (map-set user-profiles
    { user: tx-sender }
    {
      interests: interests,
      reputation: u0,
      events-attended: (list)
    }
  ))
)

(define-read-only (get-friend-suggestions (user principal))
  (let ((user-profile (unwrap! (map-get? user-profiles { user: user }) err-not-found)))
    (ok (get interests user-profile))
  )
)
