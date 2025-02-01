;; VaultTrack Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-vault (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-vault-locked (err u103))

;; Data vars
(define-map vaults
  { owner: principal }
  { 
    balance: uint,
    locked-until: uint,
    daily-limit: uint,
    withdrawals-today: uint,
    last-withdrawal: uint
  }
)

;; Public functions
(define-public (create-vault (daily-limit uint))
  (let ((vault { owner: tx-sender }))
    (if (is-none (map-get? vaults vault))
      (begin
        (map-set vaults vault {
          balance: u0,
          locked-until: u0,
          daily-limit: daily-limit,
          withdrawals-today: u0,
          last-withdrawal: block-height
        })
        (ok true))
      (err u104))))

(define-public (deposit (amount uint))
  (let ((vault { owner: tx-sender }))
    (match (map-get? vaults vault)
      vault-data (begin 
        (map-set vaults vault
          (merge vault-data { balance: (+ (get balance vault-data) amount) }))
        (ok true))
      (err u105))))

(define-public (withdraw (amount uint))
  (let ((vault { owner: tx-sender }))
    (match (map-get? vaults vault)
      vault-data (begin
        (asserts! (<= amount (get balance vault-data)) err-insufficient-balance)
        (asserts! (>= block-height (get locked-until vault-data)) err-vault-locked)
        (asserts! (<= amount (get daily-limit vault-data)) (err u106))
        (map-set vaults vault
          (merge vault-data { 
            balance: (- (get balance vault-data) amount),
            withdrawals-today: (+ (get withdrawals-today vault-data) amount)
          }))
        (ok true))
      (err u107))))

;; Read only functions
(define-read-only (get-vault-balance (owner principal))
  (match (map-get? vaults { owner: owner })
    vault-data (ok (get balance vault-data))
    (err u108)))

(define-read-only (get-vault-info (owner principal))
  (match (map-get? vaults { owner: owner })
    vault-data (ok vault-data)
    (err u109)))
