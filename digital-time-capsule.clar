;; Digital-Time-Capsule
(define-data-var next-id uint u1)

(define-map time-capsules
{
id: uint
}
{
owner: principal,
message: (optional (string-ascii 256)),
file-hash: (optional (string-ascii 64)), ;; Assuming file is stored as a hash
nft: (optional (tuple (contract principal) (token-id uint))),
release-date: uint
}
)

;; Function to lock a time capsule
(define-public (lock-capsule
(message (optional (string-ascii 256)))
(file-hash (optional (string-ascii 64)))
(nft (optional (tuple (contract principal) (token-id uint))))
(release-date uint))
(begin
;; Ensure the release date is in the future
(asserts! (> release-date block-height) (err u102))
;; Get the next capsule ID
(let ((capsule-id (var-get next-id)))
;; Save the capsule
(map-set time-capsules
{ id: capsule-id }
{
owner: tx-sender,
message: message,
file-hash: file-hash,
nft: nft,
release-date: release-date
})
;; Increment the next capsule ID
(var-set next-id (+ capsule-id u1))
;; Return the new capsule ID
(ok capsule-id)
)
)
)
;; Function to retrieve a time capsule

(define-public (retrieve-capsule (capsule-id uint))
(begin
(let ((capsule (map-get? time-capsules { id: capsule-id })))
(match capsule
capsule-data
(begin
;; Ensure the release date has passed
(asserts! (<= (get release-date capsule-data) block-height) (err u102))
;; Ensure the caller is the owner
(asserts! (is-eq (get owner capsule-data) tx-sender) (err u103))
;; Return the capsule data
(ok capsule-data))
(err u101)))))