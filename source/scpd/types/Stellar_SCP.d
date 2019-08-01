/*******************************************************************************

    Porting of Stellar's `Stellar_SCP.h`, itself derived from `Stellar_SCP.x`

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.types.Stellar_SCP;

import vibe.data.json;

import scpd.Cpp;
import scpd.types.Stellar_types;
import scpd.types.XDRBase;

import core.stdc.config;
import core.stdc.inttypes;

extern(C++, `stellar`):

alias Value = opaque_vec!();

static assert(Value.sizeof == 24);

struct SCPBallot {
  uint32_t counter;
  Value value;
}

static assert(SCPBallot.sizeof == 32);

enum SCPStatementType : int32_t {
  SCP_ST_PREPARE = 0,
  SCP_ST_CONFIRM = 1,
  SCP_ST_EXTERNALIZE = 2,
  SCP_ST_NOMINATE = 3,
}

struct SCPNomination {
    Hash quorumSetHash;
    xvector!(Value) votes;
    xvector!(Value) accepted;
}

static assert(SCPNomination.sizeof == 80);

struct SCPStatement {

    /***************************************************************************

        Note: XDRPP defines a lot of boilerplate accessors to ensure those
        tagged unions are properly accessed from code.
        We don't, and instead we just bind the size, hoping for the best.

    ***************************************************************************/

    static struct _pledges_t {
        static struct _prepare_t {
            Hash quorumSetHash;
            SCPBallot ballot;
            pointer!(SCPBallot) prepared;
            pointer!(SCPBallot) preparedPrime;
            uint32_t nC;
            uint32_t nH;
        }

        static assert(_prepare_t.sizeof == 88);

        static struct _confirm_t {
            SCPBallot ballot;
            uint32_t nPrepared;
            uint32_t nCommit;
            uint32_t nH;
            Hash quorumSetHash;
        }

        static assert(_confirm_t.sizeof == 80);

        static struct _externalize_t {
            SCPBallot commit;
            uint32_t nH;
            Hash commitQuorumSetHash;
        }

        static assert(_externalize_t.sizeof == 72);

        //using _xdr_case_type = xdr::xdr_traits<SCPStatementType>::case_type;
        //private:
        //_xdr_case_type type_;
        int32_t type_;
        union {
            _prepare_t prepare_;
            _confirm_t confirm_;
            _externalize_t externalize_;
            SCPNomination nominate_;
        }

        /// Support (de)serialization from Vibe.d
        extern(D) string toString () const @trusted
        {
            switch (this.type_)
            {
            case SCPStatementType.SCP_ST_PREPARE:
                return "0" ~ serializeToJsonString(this.prepare_);
            case SCPStatementType.SCP_ST_CONFIRM:
                return "1" ~ serializeToJsonString(this.confirm_);
            case SCPStatementType.SCP_ST_EXTERNALIZE:
                return "2" ~ serializeToJsonString(this.externalize_);
            case SCPStatementType.SCP_ST_NOMINATE:
                return "3" ~ serializeToJsonString(this.nominate_);
            default:
                assert(0);
            }
        }

        /// Ditto
        extern(D) static _pledges_t fromString (const(char)[] input) @trusted
        {
            assert(input.length > 0);
            _pledges_t ret;
            switch (input[0])
            {
            case '0':
                ret.type_ = SCPStatementType.SCP_ST_PREPARE;
                ret.prepare_ = deserializeJson!_prepare_t(input[1 .. $]);
                break;
            case '1':
                ret.type_ = SCPStatementType.SCP_ST_CONFIRM;
                ret.confirm_ = deserializeJson!_confirm_t(input[1 .. $]);
                break;
            case '2':
                ret.type_ = SCPStatementType.SCP_ST_EXTERNALIZE;
                ret.externalize_ = deserializeJson!_externalize_t(input[1 .. $]);
                break;
            case '3':
                ret.type_ = SCPStatementType.SCP_ST_NOMINATE;
                ret.nominate_ = deserializeJson!SCPNomination(input[1 .. $]);
                break;
            default:
                assert(0);
            }
            return ret;
        }
    }

    NodeID nodeID;
    uint64_t slotIndex;
    _pledges_t pledges;
}

static assert(SCPStatement.sizeof == 144);

struct SCPEnvelope {
  SCPStatement statement;
  Signature signature;
}

static assert(SCPEnvelope.sizeof == 168);

struct SCPQuorumSet {
    uint32_t threshold;
    xvector!(PublicKey) validators;
    xvector!(SCPQuorumSet) innerSets;
}

static assert(SCPQuorumSet.sizeof == 56);

/// From SCPDriver, here for convenience
public alias SCPQuorumSetPtr = shared_ptr!SCPQuorumSet;

/// TODO: Move to a test folder and/or automate this
static assert(SCPBallot.sizeof == 32);
static assert(Value.sizeof == 24);
static assert(SCPQuorumSet.sizeof == 56);
static assert(SCPEnvelope.sizeof == 168);
