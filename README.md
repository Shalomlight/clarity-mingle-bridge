# MingleBridge
A decentralized platform for organizing and discovering social events with friend suggestions built on Stacks blockchain.

## Features
- Create and manage social events
- RSVP to events
- Friend suggestions based on common interests and events
- View upcoming events in your area
- Event organizer reputation system

## Setup and Installation
1. Clone the repository
2. Install Clarinet
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to execute test suite

## Usage Examples
```clarity
;; Create a new event
(contract-call? .mingle-bridge create-event "Beach Party" "Join us for summer fun!" 
  u1687478400 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u100)

;; RSVP to an event
(contract-call? .mingle-bridge rsvp-event u1 true)

;; Get event details
(contract-call? .mingle-bridge get-event-details u1)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
