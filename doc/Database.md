# Agora databases

Agora store its state in 2 SQLite3-backed databases, the state DB and the cache DB.
The state DB contains the state machine data while the cache DB contains transient,
largely expandable data.
For more informations, see [this description](https://github.com/bosagora/agora/blob/8228bcb77f2808722e30be8c84f578b354e9fd3c/source/agora/node/FullNode.d#L138-L168).

## State DB

### `utxo` table

Our oldest table, only contain binary serialized data, should be changed to a readable format.

| Field name      | SQL Type | D type      | Attributes  | Comment                                                |
|-----------------|----------|-------------|-------------|--------------------------------------------------------|
| `hash`          | TEXT     | string      | PRIMARY KEY | The hash of the UTXO (`hashMulti(txhash, index)`)      |
| `unlock_height` | INTEGER  | Height      | NOT NULL    | See `UTXO` struct                                      |
| `type`          | INTEGER  | OutputType  | NOT NULL    | See `Output` struct                                    |
| `amount`        | INTEGER  | Amount      | NOT NULL    | See `Output` struct                                    |
| `locktype`      | INTEGER  | LockType    | NOT NULL    | See `Lock` struct                                      |
| `lock`          | BLOB     | ubyte[]     | NOT NULL    | See `Lock` struct                                      |

### `validator` table

Should be cleaned up and make readable. Once `utxo` is usable, both can be used in combination.

| Field name      | SQL Type | D type           | Attributes                           | Comment                                            |
|-----------------|----------|------------------|--------------------------------------|----------------------------------------------------|
| key             | TEXT     | Hash             | PRIMARY KEY (with `enrolled_height`) | The `utxo` field in the `Enrollment`               |
| public_key      | TEXT     | PublicKey        |                                      | Should be replaced with a join using the UTXO hash |
| enrolled_height | INTEGER  | Height           | PRIMARY KEY (with `key`)             |                                                    |
| nonce           | TEXT     | Point            |                                      | The `R` used to sign the `Enrollment`              |
| slashed_height  | INTEGER  | Height           |                                      | Height at which a validator is slashed or null     |
| stake           | INTEGER  | Amount           |                                      | Frozen Amount staked when enrolling                |

### `preimages` table

Stores the preimage information

| Field name      | SQL Type | D type           | Attributes                           | Comment                                            |
|-----------------|----------|------------------|--------------------------------------|----------------------------------------------------|
| key             | TEXT     | Hash             |                                      | The `utxo` field in the `Enrollment`               |
| height          | INTEGER  | ulong            |                                      |                                                    |
| preimage        | TEXT     | Hash             |                                      |                                                    |

### `node_enroll_data` table

This table should be removed in favor of querying `validator` directly.

| Field name | SQL Type | D type | Attributes  | Comment                                                           |
|------------|----------|--------|-------------|-------------------------------------------------------------------|
| key        | TEXT     | string | PRIMARY KEY | Used as an AA. Valid values: `utxo`, `random_seed`                |
| val        | TEXT     | Hash   | NOT NULL    | In both case a hash, but the node could just query `ValidatorSet` |


### `block_fees` table

Keep track of fees as blocks are externalized.
Otherwise if the inputs are consumed in later blocks before the payout block it will not be possible to calculate them.

| Field name | SQL Type | D type     | Attributes  | Comment             |
|------------|----------|------------|-------------|---------------------|
| height     | INTEGER  | Height     | PRIMARY KEY |                     |
| fee        | INTEGER  | Amount     |             |                     |
| data_fee   | INTEGER  | Amount     |             |                     |

## Cache DB

### `tx_pool` table

Stores the pending transaction. Should be made readable.

| Field name | SQL Type | D type      | Attributes  | Comment           |
|------------|----------|-------------|-------------|-------------------|
| key        | TEXT     | Hash        | PRIMARY KEY | Transaction hash  |
| val        | BLOB     | Transaction | NOT NULL    | Binary-serialized |
| fee        | INTEGER  | Amount      | NOT NULL    | fee rate          |

### `enrollment_pool` table

Store the `Enrollment` that haven't made it to a `Block` yet. Should be made readable.

| Field name   | SQL Type | D type     | Attributes  | Comment                                                     |
|--------------|----------|------------|-------------|-------------------------------------------------------------|
| key          | TEXT     | Hash       | PRIMARY KEY | The `utxo` field, not the hash of the `Enrollment` itself   |
| val          | BLOB     | Enrollment |             | Binary serialized `Enrollment`, should be converted to text |
| avail_height | INTEGER  | Height     |             | It's not actually a hash but the key, should be `TEXT`      |

### `registry_validator_signature` and `registry_flash_signature` tables

Stores signature and last sequence number of the name registry.

| Field Name | SQL Type | D type | Attributes | Comment                                               |
|------------|----------|--------|------------|-------------------------------------------------------|
| pubkey     | TEXT     | string | PRIMARY KEY | String representation of Node's PublicKey             |
| signature  | TEXT     | string | NOT NULL   | String representation of Registry Payload's signature |
| sequence   | INTEGER  | ulong  | NOT NULL   | Sequence number of Registry Payload                   |

### `registry_validator_addresses` and `registry_flash_addresses` tables

Stores Addresses and `TYPE` of the name registry. These table have relationship with [signature](###-`registry_validator_signature`-and-`registry_flash_signature`-tables) tables over `pubkey` attribute. `DELETE` on signature table is cascaded.

| Field Name | SQL Type | D type | Attributes               | Comment                                          |
|------------|----------|--------|--------------------------|--------------------------------------------------|
| pubkey     | TEXT     | string | PRIMARY KEY, FOREIGN KEY | String representation of Node's PublicKey        |
| address    | TEXT     | string | PRIMARY KEY, NOT NULL    | String representation of Node's registry address |
| type       | INTEGER  | ushort | NOT NULL                 | Short representation for registry address' TYPE  |

## SCP envelope DB

This DB is in its own file and should probably merged in one or the other.

| Field name | SQL Type | D type      | Attributes                | Comment                             |
|------------|----------|-------------|---------------------------|-------------------------------------|
| seq        | INTEGER  |             | PRIMARY KEY AUTOINCREMENT | Unused on the D side                |
| envelope   | BLOB     | SCPEnvelope | NOT NULL                  | Serializing a C++ type is dangerous |


## Flash database

This contains Flash-related data.

### `channels` table

| Field name    | SQL Type | D type       | Attributes           | Comment                     |
|---------------|----------|--------------|----------------------|-----------------------------|
| chan_id       | BLOB     | Hash         | PRIMARY KEY NOT NULL | Binary-serialized hash      |
| data          | BLOB     | Transaction  | NOT NULL             | Binary-serialized `Channel` |
| update_signer | BLOB     | UpdateSigner |                      | Binary                      |


### `flash_metadata` table

| Field name | SQL Type | D type | Attributes           | Comment                         |
|------------|----------|--------|----------------------|---------------------------------|
| meta       | BLOB     | Hash   | PRIMARY KEY NOT NULL | Only ever set to `1` if present |
| data       | BLOB     |        | NOT NULL             | Binary-serialized `mixin`       |
