;; Constants
(define-constant err-not-found (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-invalid-date (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-canceled (err u104))
(define-constant err-full (err u105))

;; Data variables
(define-data-var next-event-id uint u1)

(define-map events 
  { event-id: uint }
  {
    title: (string-ascii 50),
    description: (string-ascii 500),
    date: uint,
    end-time: uint,
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
    events-attended: (list 50 uint),
    events-organized: (list 50 uint)
  }
)

;; Private functions
(define-private (validate-date (date uint) (end-time uint))
  (and
    (> date block-height)
    (> end-time date)
  )
)

(define-private (update-reputation (user principal) (value uint))
  (let ((profile (unwrap! (map-get? user-profiles { user: user }) err-not-found)))
    (ok (map-set user-profiles
      { user: user }
      (merge profile {
        reputation: (+ (get reputation profile) value)
      })
    ))
  )
)

;; Public functions
(define-public (create-event (title (string-ascii 50)) 
                          (description (string-ascii 500))
                          (date uint)
                          (end-time uint)
                          (capacity uint))
  (let ((event-id (var-get next-event-id)))
    (asserts! (validate-date date end-time) err-invalid-date)
    (asserts! (> capacity u0) err-invalid-date)
    
    (map-insert events
      { event-id: event-id }
      {
        title: title,
        description: description,
        date: date,
        end-time: end-time,
        organizer: tx-sender,
        capacity: capacity,
        attendees: (list),
        status: "active"
      }
    )
    
    (var-set next-event-id (+ event-id u1))
    (ok event-id)
  )
)

(define-public (cancel-event (event-id uint))
  (let ((event (unwrap! (map-get? events { event-id: event-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get organizer event)) err-unauthorized)
    (ok (map-set events
      { event-id: event-id }
      (merge event {
        status: "canceled"
      })
    ))
  )
)

(define-public (rsvp-event (event-id uint) (attending bool))
  (let ((event (unwrap! (map-get? events { event-id: event-id }) err-not-found)))
    (asserts! (is-eq (get status event) "active") err-canceled)
    (if attending
      (begin
        (asserts! (< (len (get attendees event)) (get capacity event)) err-full)
        (map-set events { event-id: event-id }
          (merge event {
            attendees: (append (get attendees event) tx-sender)
          })
        )
        (update-reputation tx-sender u1)
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
      events-attended: (list),
      events-organized: (list)
    }
  ))
)

(define-read-only (get-friend-suggestions (user principal))
  (let ((user-profile (unwrap! (map-get? user-profiles { user: user }) err-not-found)))
    (ok (get interests user-profile))
  )
)
