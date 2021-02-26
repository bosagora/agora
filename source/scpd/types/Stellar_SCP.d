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

import agora.common.Serializer;

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

static assert(SCPNomination.sizeof == 112);

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

        static assert(_prepare_t.sizeof == 120);

        static struct _confirm_t {
            SCPBallot ballot;
            uint256 value_sig;  // used for Scalar of Signature for this ballot
            uint32_t nPrepared;
            uint32_t nCommit;
            uint32_t nH;
            Hash quorumSetHash;
        }

        static assert(_confirm_t.sizeof == 144);

        static struct _externalize_t {
            SCPBallot commit;
            uint32_t nH;
            Hash commitQuorumSetHash;
        }

        static assert(_externalize_t.sizeof == 104);

        //using _xdr_case_type = xdr::xdr_traits<SCPStatementType>::case_type;
        //private:
        //_xdr_case_type type_;
        SCPStatementType type_;
        union {
            _prepare_t prepare_;
            _confirm_t confirm_;
            _externalize_t externalize_;
            SCPNomination nominate_;
        }

        /// Support (de)serialization from Vibe.d
        extern(D) string toString () const @trusted
        {
            Json json = Json.emptyObject;
            final switch (this.type_)
            {
            case SCPStatementType.SCP_ST_PREPARE:
                json["prepare"] = serializeToJson(this.prepare_);
                break;
            case SCPStatementType.SCP_ST_CONFIRM:
                json["confirm"] = serializeToJson(this.confirm_);
                break;
            case SCPStatementType.SCP_ST_EXTERNALIZE:
                json["externalize"] = serializeToJson(this.externalize_);
                break;
            case SCPStatementType.SCP_ST_NOMINATE:
                json["nominate"] = serializeToJson(this.nominate_);
                break;
            }
            return json.toString();
        }

        /// Ditto
        extern(D) static _pledges_t fromString (const(char)[] input) @trusted
        {
            _pledges_t ret;
            // Need the case because `parseJsonString` expects a string,
            // but doesn't escape things past the `Json` object it returns
            auto json = parseJsonString(cast(string) input).get!(Json[string]);
            if (auto obj = "prepare" in json)
            {
                ret.type_ = SCPStatementType.SCP_ST_PREPARE;
                ret.prepare_ = (*obj).deserializeJson!_prepare_t();
            }
            else if (auto obj = "confirm" in json)
            {
                ret.type_ = SCPStatementType.SCP_ST_CONFIRM;
                ret.confirm_ = (*obj).deserializeJson!_confirm_t();
            }
            else if (auto obj = "externalize" in json)
            {
                ret.type_ = SCPStatementType.SCP_ST_EXTERNALIZE;
                ret.externalize_ = (*obj).deserializeJson!_externalize_t();
            }
            else if (auto obj = "nominate" in json)
            {
                ret.type_ = SCPStatementType.SCP_ST_NOMINATE;
                ret.nominate_ = (*obj).deserializeJson!SCPNomination();
            }
            else
                throw new Exception("Unrecognized envelope type");
            return ret;
        }

        extern(D)
        {
            import agora.crypto.Hash : HashDg, hashPart;
            /// Hashing support
            public void computeHash (scope HashDg dg) const @trusted @nogc nothrow
            {
                hashPart(this.type_, dg);
                switch (this.type_)
                {
                case SCPStatementType.SCP_ST_PREPARE:
                    return hashPart(this.prepare_, dg);
                case SCPStatementType.SCP_ST_CONFIRM:
                    return hashPart(this.confirm_, dg);
                case SCPStatementType.SCP_ST_EXTERNALIZE:
                    return hashPart(this.externalize_, dg);
                case SCPStatementType.SCP_ST_NOMINATE:
                    return hashPart(this.nominate_, dg);
                default:
                    assert(0);
                }
            }
        }

        ///
        extern(D) void serialize (scope SerializeDg dg) const @trusted
        {
            serializePart(this.type_, dg);
            switch (this.type_)
            {
            case SCPStatementType.SCP_ST_PREPARE:
                return serializePart(this.prepare_, dg);
            case SCPStatementType.SCP_ST_CONFIRM:
                return serializePart(this.confirm_, dg);
            case SCPStatementType.SCP_ST_EXTERNALIZE:
                return serializePart(this.externalize_, dg);
            case SCPStatementType.SCP_ST_NOMINATE:
                return serializePart(this.nominate_, dg);
            default:
                assert(0);
            }
        }

        ///
        extern(D) public static QT fromBinary (QT) (scope DeserializeDg dg,
            in DeserializerOptions opts) @safe
        {
            auto type = deserializeFull!(typeof(QT.type_))(dg, opts);
            final switch (type)
            {
            case SCPStatementType.SCP_ST_PREPARE:
                return enableNRVO!(QT, SCPStatementType.SCP_ST_PREPARE)(dg, opts);
            case SCPStatementType.SCP_ST_CONFIRM:
                return enableNRVO!(QT, SCPStatementType.SCP_ST_CONFIRM)(dg, opts);
            case SCPStatementType.SCP_ST_EXTERNALIZE:
                return enableNRVO!(QT, SCPStatementType.SCP_ST_EXTERNALIZE)(dg, opts);
            case SCPStatementType.SCP_ST_NOMINATE:
                return enableNRVO!(QT, SCPStatementType.SCP_ST_NOMINATE)(dg, opts);
            }
        }

        /***********************************************************************

            Allow `fromBinary` to do NRVO

            We need to initialize using a literal to account for type
            constructors, but we can't initialize the `union` in a generic way
            (because we need to use a different name based on the `type`).
            The normal solution is to put it in a `switch`, but since we
            declare multiple variable (one per `switch` branch),
            NRVO is disabled.
            The solution is to use `static if` to ensure the compiler only sees
            one temporary and does NRVO on this function, which in turn enables
            NRVO on the caller.

            See_Also:
              https://forum.dlang.org/thread/miuevyfxbujwrhghmiuw@forum.dlang.org

        ***********************************************************************/

        extern(D) private static QT enableNRVO (QT, SCPStatementType type) (
            scope DeserializeDg dg, in DeserializerOptions opts) @safe
        {
            static if (type == SCPStatementType.SCP_ST_PREPARE)
            {
                QT ret = {
                    type_: type,
                    prepare_: deserializeFull!(typeof(QT.prepare_))(dg, opts)
                };
                return ret;
            }
            else static if (type == SCPStatementType.SCP_ST_CONFIRM)
            {
                QT ret = {
                    type_: type,
                    confirm_: deserializeFull!(typeof(QT.confirm_))(dg, opts)
                };
                return ret;
            }
            else static if (type == SCPStatementType.SCP_ST_EXTERNALIZE)
            {
                QT ret = {
                    type_: type,
                    externalize_: deserializeFull!(typeof(QT.externalize_))(dg, opts)
                };
                return ret;
            }
            else static if (type == SCPStatementType.SCP_ST_NOMINATE)
            {
                QT ret = {
                    type_: type,
                    nominate_: deserializeFull!(typeof(QT.nominate_))(dg, opts)
                };
                return ret;
            }
            else
                static assert(0, "Unsupported statement type: " ~ type.stringof);
        }
    }

    NodeID nodeID;
    uint64_t slotIndex;
    _pledges_t pledges;
}

static assert(SCPStatement.sizeof == 200);
static assert(Signature.sizeof == 64);

struct SCPEnvelope {
  SCPStatement statement;
  Signature signature;
}

static assert(SCPEnvelope.sizeof == 264);

struct SCPQuorumSet {
    import agora.crypto.Hash;

    uint32_t threshold;
    xvector!(PublicKey) validators;
    xvector!(SCPQuorumSet) innerSets;

    /// Hashing support
    extern(D) public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        hashPart(this.threshold, dg);

        foreach (const ref node; this.validators[])
            hashPart(node, dg);

        foreach (const ref quorum; this.innerSets[])
            hashPart(quorum, dg);
    }
}

@safe unittest
{
    import agora.common.crypto.Key;
    import agora.common.Config;
    import agora.common.Types;
    import agora.crypto.Hash;
    import std.conv;

    const qc1 = toSCPQuorumSet(QuorumConfig(2,
        [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
         PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")]));

    assert(qc1.hashFull() == Hash.fromString(
        "0x7b56982f02dfbf3737ff560fe6511674e182d38475f0516cb8b0f338a3156543b0731e66c9a3ced01c238652b12e51c95207ec2bf6eae237f24b08a357a1bd2a"),
        qc1.hashFull().to!string);

    const qc2 = toSCPQuorumSet(QuorumConfig(3,
        [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
         PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")]));

    assert(qc2.hashFull() == Hash.fromString(
        "0x05711002a8fc1c0b8c757fb2ddb60505af0ee49fa64af6e4d808aedc39af3eb911cf0b4a481c98ffdc4717e0d6a815b27b0bbac1eea85c5b61ba3f0ca66d8d15"),
        qc2.hashFull().to!string);

    const qc3 = toSCPQuorumSet(QuorumConfig(2,
        [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
         PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")],
             [QuorumConfig(2,
            [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
             PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")])]));

    assert(qc3.hashFull() == Hash.fromString(
        "0xbd1a17a20ce1df92e3cb2eca3e3fd9c40cf5a3b5f4cf492c52f0d43588f59a9720b1c020264325e279ad0d719180dd919bb28268040cb357a787859f95a4da26"),
        qc3.hashFull().to!string);

    const qc4 = toSCPQuorumSet(QuorumConfig(2,
        [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
         PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")],
             [QuorumConfig(3,
            [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
             PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")])]));

    assert(qc4.hashFull() == Hash.fromString(
        "0x05dbab4600c1f61044179fefc3372be33eaae218240f9a2a87bee720594c6f39486c10b6be57320fb9e036c709f0dc387d34dcb8f56674449c7ed21f5bb8c638"),
        qc4.hashFull().to!string);
}
static assert(SCPQuorumSet.sizeof == 56);

/// From SCPDriver, here for convenience
public alias SCPQuorumSetPtr = shared_ptr!SCPQuorumSet;
