/*******************************************************************************

    Bindings for scp/LocalNode.h

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.scp.LocalNode;

import scpd.scp.SCP;

import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.XDRBase;

extern(C++, stellar):

/**
 * This is one Node in the stellar network
 */
extern(C++, class) public struct LocalNode
{
  protected:
    const NodeID mNodeID;
    const bool mIsValidator;
    SCPQuorumSet mQSet;
    Hash mQSetHash;

    // // alternative qset used during externalize {{mNodeID}}
    Hash            gSingleQSetHash;  // hash of the singleton qset
    SCPQuorumSetPtr mSingleQSet;      // {{mNodeID}}

    SCP* mSCP;

  public:
    this(ref const(NodeID) nodeID, bool isValidator,
         ref const(SCPQuorumSet) qSet, SCP scp);

    ref const(NodeID) getNodeID();

    void updateQuorumSet(ref const(SCPQuorumSet) qSet);

    ref const(SCPQuorumSet) getQuorumSet();
    ref const(Hash) getQuorumSetHash();
    //ref const(SecretKey) getSecretKey();
    bool isValidator();
}

static assert(LocalNode.sizeof == 184);
