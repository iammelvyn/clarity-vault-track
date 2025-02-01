;; VaultTrack Authorization Contract

;; Constants
(define-constant err-unauthorized (err u200))

;; Data vars
(define-map authorized-users
  { vault-owner: principal, user: principal }
  { can-withdraw: bool, withdraw-limit: uint }
)

;; Public functions
(define-public (add-authorized-user (user principal) (withdraw-limit uint))
  (let ((auth-data { vault-owner: tx-sender, user: user }))
    (map-set authorized-users auth-data
      { can-withdraw: true, withdraw-limit: withdraw-limit })
    (ok true)))

(define-public (remove-authorized-user (user principal))
  (let ((auth-data { vault-owner: tx-sender, user: user }))
    (map-delete authorized-users auth-data)
    (ok true)))

;; Read only functions
(define-read-only (is-authorized (vault-owner principal) (user principal))
  (match (map-get? authorized-users { vault-owner: vault-owner, user: user })
    auth-data (ok (get can-withdraw auth-data))
    (ok false)))
