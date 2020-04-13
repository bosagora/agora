/*******************************************************************************

    Contains quorum intersection tests adapted from stellar-core.

    Note: some tests are only enabled when -version=PerformanceTests is enabled,
    as these tests take a long time to finish.

    Copyright:
        Copyright 2016-2019 Stellar Development Foundation and contributors.

    License:
        Licensed under the Apache License, Version 2.0. See the COPYING file at
        http://www.apache.org/licenses/LICENSE-2.0

*******************************************************************************/

module scpd.quorum.QuorumIntersectionTests;

version (unittest):

import scpd.quorum.QuorumIntersectionChecker;
import scpd.quorum.QuorumTracker;
import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types : uint256, NodeID;
import scpd.types.Utils;
import scpd.types.XDRBase;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Types;
import agora.utils.Log;

mixin AddLogger!();

// quorum intersection basic 4-node
unittest
{
    auto qm = QuorumTracker.QuorumMap.create();

    PublicKey pkA = KeyPair.random.address;
    PublicKey pkB = KeyPair.random.address;
    PublicKey pkC = KeyPair.random.address;
    PublicKey pkD = KeyPair.random.address;

    qm[pkA.toStellarKey] = makeSharedQuorumSet(2, [pkB, pkC, pkD], null);
    qm[pkB.toStellarKey] = makeSharedQuorumSet(2, [pkA, pkC, pkD], null);
    qm[pkC.toStellarKey] = makeSharedQuorumSet(2, [pkA, pkB, pkD], null);
    qm[pkD.toStellarKey] = makeSharedQuorumSet(2, [pkA, pkB, pkC], null);

    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
}

// quorum intersection 6-node with subquorums
unittest
{
    auto qm = QuorumTracker.QuorumMap.create();

    PublicKey pkA = KeyPair.random.address;
    PublicKey pkB = KeyPair.random.address;
    PublicKey pkC = KeyPair.random.address;
    PublicKey pkD = KeyPair.random.address;
    PublicKey pkE = KeyPair.random.address;
    PublicKey pkF = KeyPair.random.address;

    QuorumConfig qsABC = QuorumConfig(2, [pkA, pkB, pkC], null);
    QuorumConfig qsABD = QuorumConfig(2, [pkA, pkB, pkD], null);
    QuorumConfig qsABE = QuorumConfig(2, [pkA, pkB, pkE], null);
    QuorumConfig qsABF = QuorumConfig(2, [pkA, pkB, pkF], null);

    QuorumConfig qsACD = QuorumConfig(2, [pkA, pkC, pkD], null);
    QuorumConfig qsACE = QuorumConfig(2, [pkA, pkC, pkE], null);
    QuorumConfig qsACF = QuorumConfig(2, [pkA, pkC, pkF], null);

    QuorumConfig qsADE = QuorumConfig(2, [pkA, pkD, pkE], null);
    QuorumConfig qsADF = QuorumConfig(2, [pkA, pkD, pkF], null);

    QuorumConfig qsBDC = QuorumConfig(2, [pkB, pkD, pkC], null);
    QuorumConfig qsBDE = QuorumConfig(2, [pkB, pkD, pkE], null);
    QuorumConfig qsCDE = QuorumConfig(2, [pkC, pkD, pkE], null);

    qm[pkA.toStellarKey] = makeSharedQuorumSet(2, null, [qsBDC, qsBDE, qsCDE]);
    qm[pkB.toStellarKey] = makeSharedQuorumSet(2, null, [qsACD, qsACE, qsACF]);
    qm[pkC.toStellarKey] = makeSharedQuorumSet(2, null, [qsABD, qsABE, qsABF]);
    qm[pkD.toStellarKey] = makeSharedQuorumSet(2, null, [qsABC, qsABE, qsABF]);
    qm[pkE.toStellarKey] = makeSharedQuorumSet(2, null, [qsABC, qsABD, qsABF]);
    qm[pkF.toStellarKey] = makeSharedQuorumSet(2, null, [qsABC, qsABD, qsABE]);

    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
}

// quorum non intersection basic 6-node
unittest
{
    auto qm = QuorumTracker.QuorumMap.create();

    PublicKey pkA = KeyPair.random.address;
    PublicKey pkB = KeyPair.random.address;
    PublicKey pkC = KeyPair.random.address;
    PublicKey pkD = KeyPair.random.address;
    PublicKey pkE = KeyPair.random.address;
    PublicKey pkF = KeyPair.random.address;

    qm[pkA.toStellarKey] = makeSharedQuorumSet(2, [pkB, pkC, pkD, pkE, pkF], null);
    qm[pkB.toStellarKey] = makeSharedQuorumSet(2, [pkA, pkC, pkD, pkE, pkF], null);
    qm[pkC.toStellarKey] = makeSharedQuorumSet(2, [pkA, pkB, pkD, pkE, pkF], null);
    qm[pkD.toStellarKey] = makeSharedQuorumSet(2, [pkA, pkB, pkC, pkE, pkF], null);
    qm[pkE.toStellarKey] = makeSharedQuorumSet(2, [pkA, pkB, pkC, pkD, pkF], null);
    qm[pkF.toStellarKey] = makeSharedQuorumSet(2, [pkA, pkB, pkC, pkD, pkE], null);

    auto qic = QuorumIntersectionChecker.create(qm);
    assert(!qic.networkEnjoysQuorumIntersection());
}

// quorum non intersection 6-node with subquorums
unittest
{
    auto qm = QuorumTracker.QuorumMap.create();

    PublicKey pkA = KeyPair.random.address;
    PublicKey pkB = KeyPair.random.address;
    PublicKey pkC = KeyPair.random.address;
    PublicKey pkD = KeyPair.random.address;
    PublicKey pkE = KeyPair.random.address;
    PublicKey pkF = KeyPair.random.address;

    QuorumConfig qsABC = QuorumConfig(2, [pkA, pkB, pkC], null);
    QuorumConfig qsABD = QuorumConfig(2, [pkA, pkB, pkD], null);
    QuorumConfig qsABE = QuorumConfig(2, [pkA, pkB, pkE], null);
    QuorumConfig qsABF = QuorumConfig(2, [pkA, pkB, pkF], null);

    QuorumConfig qsACD = QuorumConfig(2, [pkA, pkC, pkD], null);
    QuorumConfig qsACE = QuorumConfig(2, [pkA, pkC, pkE], null);
    QuorumConfig qsACF = QuorumConfig(2, [pkA, pkC, pkF], null);

    QuorumConfig qsADE = QuorumConfig(2, [pkA, pkD, pkE], null);
    QuorumConfig qsADF = QuorumConfig(2, [pkA, pkD, pkF], null);

    QuorumConfig qsBDC = QuorumConfig(2, [pkB, pkD, pkC], null);
    QuorumConfig qsBDE = QuorumConfig(2, [pkB, pkD, pkE], null);
    QuorumConfig qsBDF = QuorumConfig(2, [pkB, pkD, pkF], null);
    QuorumConfig qsCDE = QuorumConfig(2, [pkC, pkD, pkE], null);
    QuorumConfig qsCDF = QuorumConfig(2, [pkC, pkD, pkF], null);

    qm[pkA.toStellarKey] = makeSharedQuorumSet(2, null, [qsABC, qsABD, qsABE]);
    qm[pkB.toStellarKey] = makeSharedQuorumSet(2, null, [qsBDC, qsABD, qsABF]);
    qm[pkC.toStellarKey] = makeSharedQuorumSet(2, null, [qsACD, qsACD, qsACF]);

    qm[pkD.toStellarKey] = makeSharedQuorumSet(2, null, [qsCDE, qsADE, qsBDE]);
    qm[pkE.toStellarKey] = makeSharedQuorumSet(2, null, [qsCDE, qsADE, qsBDE]);
    qm[pkF.toStellarKey] = makeSharedQuorumSet(2, null, [qsABF, qsADF, qsBDF]);

    auto qic = QuorumIntersectionChecker.create(qm);
    assert(!qic.networkEnjoysQuorumIntersection());
}

// quorum plausible non intersection
unittest
{
    auto qm = QuorumTracker.QuorumMap.create();

    PublicKey pkSDF1 = KeyPair.random.address;
    PublicKey pkSDF2 = KeyPair.random.address;
    PublicKey pkSDF3 = KeyPair.random.address;

    PublicKey pkLOBSTR1 = KeyPair.random.address;
    PublicKey pkLOBSTR2 = KeyPair.random.address;

    PublicKey pkSatoshi1 = KeyPair.random.address;
    PublicKey pkSatoshi2 = KeyPair.random.address;
    PublicKey pkSatoshi3 = KeyPair.random.address;

    PublicKey pkCOINQVEST1 = KeyPair.random.address;
    PublicKey pkCOINQVEST2 = KeyPair.random.address;

    // Some innersets used in quorums below.

    QuorumConfig qs1of2LOBSTR = QuorumConfig(1, [pkLOBSTR1, pkLOBSTR2], null);
    QuorumConfig qs1of2COINQVEST = QuorumConfig(1, [pkCOINQVEST1, pkCOINQVEST2], null);

    QuorumConfig qs2of3SDF = QuorumConfig(1, [pkSDF1, pkSDF2, pkSDF3], null);

    QuorumConfig qs2of3SatoshiPay = QuorumConfig(2, [pkSatoshi1, pkSatoshi2, pkSatoshi3],
                                  null);

    // All 3 SDF nodes get this:
    auto qsSDF = makeSharedQuorumSet(3, [pkSDF1, pkSDF2, pkSDF3],
                                 [qs1of2LOBSTR, qs2of3SatoshiPay]);
    qm[pkSDF1.toStellarKey] = qsSDF;
    qm[pkSDF2.toStellarKey] = qsSDF;
    qm[pkSDF3.toStellarKey] = qsSDF;

    // All SatoshiPay nodes get this:
    auto qsSatoshiPay =
        makeSharedQuorumSet(4, [pkSatoshi1, pkSatoshi2, pkSatoshi3],
                        [qs2of3SDF, qs1of2LOBSTR, qs1of2COINQVEST]);
    qm[pkSatoshi1.toStellarKey] = qsSatoshiPay;
    qm[pkSatoshi2.toStellarKey] = qsSatoshiPay;
    qm[pkSatoshi3.toStellarKey] = qsSatoshiPay;

    // All LOBSTR nodes get this:
    auto qsLOBSTR = makeSharedQuorumSet(
        5, [pkSDF1, pkSDF2, pkSDF3, pkSatoshi1, pkSatoshi2, pkSatoshi3],
        null);
    qm[pkLOBSTR1.toStellarKey] = qsLOBSTR;
    qm[pkLOBSTR2.toStellarKey] = qsLOBSTR;

    // All COINQVEST nodes get this:
    auto qsCOINQVEST =
        makeSharedQuorumSet(3, [pkCOINQVEST1, pkCOINQVEST2],
                        [qs2of3SDF, qs2of3SatoshiPay, qs1of2LOBSTR]);
    qm[pkCOINQVEST1.toStellarKey] = qsCOINQVEST;
    qm[pkCOINQVEST2.toStellarKey] = qsCOINQVEST;

    auto qic = QuorumIntersectionChecker.create(qm);
    assert(!qic.networkEnjoysQuorumIntersection());
}

uint roundUpPct (size_t n, size_t pct)
{
    return cast(uint)(size_t(1) +
        (((n * pct) - size_t(1)) / size_t(100)));
}

NodeID[][] generateOrgs (size_t n_orgs, size_t[] sizes = [3, 5])
{
    NodeID[][] ret;

    for (size_t i = 0; i < n_orgs; ++i)
    {
        ret.length = ret.length + 1;
        size_t n_nodes = sizes[i % sizes.length];
        for (size_t j = 0; j < n_nodes; ++j)
        {
            ret[$ - 1] ~= KeyPair.random.address.toStellarKey();
        }
    }
    return ret;
}

QuorumTracker.QuorumMap
interconnectOrgs(NodeID[][] orgs,
                 bool delegate(size_t i, size_t j) shouldDepend,
                 size_t ownThreshPct = 67, size_t innerThreshPct = 51)
{
    auto qm = QuorumTracker.QuorumMap.create();
    xvector!SCPQuorumSet emptySet;
    for (size_t i = 0; i < orgs.length; ++i)
    {
        const org = &orgs[i];
        SCPQuorumSet set;
        auto qs = makeSharedSCPQuorumSet(set);

        foreach (node; *org)
            qs.validators.push_back(node);

        foreach (pk; *org)
        {
            qm[pk] = qs;
        }

        auto depOrgs = &qs.innerSets;
        for (size_t j = 0; j < orgs.length; ++j)
        {
            if (i == j)
            {
                continue;
            }
            if (shouldDepend(i, j))
            {
                log.trace("dep: org#{} => org#{}", i, j);
                auto otherOrg = orgs[j];
                auto thresh = roundUpPct(otherOrg.length, innerThreshPct);

                xvector!NodeID other_orgs;
                foreach (NodeID node; otherOrg)
                    other_orgs.push_back(node);

                auto new_set = SCPQuorumSet(thresh, other_orgs, emptySet);
                (*depOrgs).push_back(new_set);
            }
        }
        qs.threshold = roundUpPct(qs.validators.length + qs.innerSets.length,
                                   ownThreshPct);
    }
    return qm;
}

QuorumTracker.QuorumMap
interconnectOrgsUnidir(NodeID[][] orgs,
                       size_t[2][] edges,
                       size_t ownThreshPct = 67, size_t innerThreshPct = 51)
{
    return interconnectOrgs(orgs,
                            (size_t i, size_t j) {
                                foreach (e; edges)
                                {
                                    if (e.first == i && e.second == j)
                                    {
                                        return true;
                                    }
                                }
                                return false;
                            },
                            ownThreshPct, innerThreshPct);
}

QuorumTracker.QuorumMap
interconnectOrgsBidir(NodeID[][] orgs,
                      size_t[2][] edges,
                      size_t ownThreshPct = 67, size_t innerThreshPct = 51)
{
    return interconnectOrgs(orgs,
                            (size_t i, size_t j) {
                                foreach (e; edges)
                                {
                                    if ((e.first == i && e.second == j) ||
                                        (e.first == j && e.second == i))
                                    {
                                        return true;
                                    }
                                }
                                return false;
                            },
                            ownThreshPct, innerThreshPct);
}

// quorum intersection 4-org fully-connected, elide all minquorums
unittest
{
    // Generate a typical all-to-all multi-org graph that checks quickly: every
    // quorum is a fair bit larger than half the SCC, so it will actually trim
    // its search to nothing before bothering to look in detail at a single
    // min-quorum. This is a bit weird but, I think, correct.
    auto orgs = generateOrgs(4);
    auto qm = interconnectOrgs(orgs, (size_t i, size_t j) { return true; });
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
}

// quorum intersection 3-org 3-node open line
unittest
{
    // Network: org0 <--> org1 <--> org2
    //
    // This fails to enjoy quorum intersection when the orgs each have 3
    // own-nodes: org0 or org2 at 67% need a 3/4 threshold (over their
    // validators and innersets), meaning either org can be satisfied by its own
    // nodes alone.
    auto orgs = generateOrgs(3, [3]);
    auto qm = interconnectOrgsBidir(orgs, [[0, 1], [1, 2]]);
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(!qic.networkEnjoysQuorumIntersection());
}

// quorum intersection 3-org 2-node open line
unittest
{
    // Network: org0 <--> org1 <--> org2
    //
    // This enjoys quorum intersection when the orgs each have 2 own-nodes: org0
    // and org2 at 67% need 3/3 nodes (including their 1 outgoing dependency),
    // meaning they have to agree with org1 to be satisfied.
    auto orgs = generateOrgs(3, [2]);
    auto qm = interconnectOrgsBidir(orgs, [[0, 1], [1, 2]]);
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
}

// quorum intersection 3-org 3-node closed ring
unittest
{
    // Network: org0 <--> org1 <--> org2
    //           ^                   ^
    //           |                   |
    //           +-------------------+
    //
    // This enjoys quorum intersection when the orgs each have 3 own-nodes: any
    // org at 67% needs a 4/5 threshold (over its validators and innersets),
    // meaning the org must be agree with at least one neighbour org.
    auto orgs = generateOrgs(3, [3]);
    auto qm = interconnectOrgsBidir(orgs, [[0, 1], [1, 2], [0, 2]]);
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
}

// "quorum intersection 3-org 3-node closed one-way ring"
unittest
{
    // Network: org0 --> org1 --> org2
    //           ^                  |
    //           |                  |
    //           +------------------+
    //
    // This fails to enjoy quorum intersection when the orgs each have 3
    // own-nodes: any org at 67% needs a 3/4 threshold (over its validators and
    // innersets), meaning the org can be satisfied by its own nodes alone. This
    // is similar to the 3-org 3-node open line case.
    auto orgs = generateOrgs(3, [3]);
    auto qm = interconnectOrgsUnidir(orgs, [
                                               [0, 1],
                                               [1, 2],
                                               [2, 0],
                                           ]);
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(!qic.networkEnjoysQuorumIntersection());
}

// "quorum intersection 3-org 2-node closed one-way ring"
unittest
{
    // Network: org0 --> org1 --> org2
    //           ^                  |
    //           |                  |
    //           +------------------+
    //
    // This enjoys quorum intersection when the orgs each have 2 own-nodes: any
    // org at 67% needs a 3/3 threshold (over its validators and innersets),
    // meaning the org must be agree with at least one neighbour org. This is
    // similar to the 3-org 2-node open line case.
    auto orgs = generateOrgs(3, [2]);
    auto qm = interconnectOrgsUnidir(orgs, [
                                               [0, 1],
                                               [1, 2],
                                               [2, 0],
                                           ]);
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
}

// "quorum intersection 3-org 2-node 2-of-3 asymmetric"
unittest
{
    //           +-------------------+
    //           |                   v
    // Network: org0 <--> org1 --> org2
    //           ^         ^         |
    //           |         |         |
    //           +---------+---------+
    //
    // This enjoys quorum intersection when the orgs each have 3 own-nodes: any
    // org at 67% needs a 4/5 threshold (over its validators and innersets),
    // meaning the org must be agree with at least one neighbour org. This is
    // similar to the 3-org 2-node closed ring case.
    auto orgs = generateOrgs(3, [3]);
    auto qm = interconnectOrgsUnidir(orgs, [
                                               [0, 1],
                                               [0, 2],
                                               [1, 0],
                                               [1, 2],
                                               [2, 0],
                                               [2, 1],
                                           ]);
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
}

// "quorum intersection 8-org core-and-periphery dangling"
unittest
{
    // This configuration "looks kinda strong" -- there's a fully-connected
    // "core" org set and the "periphery" orgs are all set to 3/3 between their
    // own two nodes and the core org they're watching -- but it is still
    // capable of splitting in half because the core orgs' dependency on on
    // periphery orgs allows passing the core org's 5/7 threshold without
    // needing a majority of the core orgs. The core orgs can be satisfied by
    // their own 3 nodes + 1 other core node + 1 periphery org, which is enough
    // to cause the network to split in two 4-org / 10-node halves:
    //
    //    org4           org5
    //       \           /
    //        org0---org1
    //          | \ / |
    //          |  X  |
    //          | / \ |
    //        org2---org3
    //       /           \
    //    org6           org7
    //
    auto orgs = generateOrgs(8, [3, 3, 3, 3, 2, 2, 2, 2]);
    auto qm = interconnectOrgsBidir(
        orgs,
        [// 4 core orgs 0, 1, 2, 3 (with 3 nodes each) which fully depend on one
         // another.
         [0, 1],
         [0, 2],
         [0, 3],
         [1, 2],
         [1, 3],
         [2, 3],
         // 4 "periphery" orgs (with 2 nodes each), each with bidirectional
         // trust with one core org, which is that core org's only paired
         // periphery.
         [0, 4],
         [1, 5],
         [2, 6],
         [3, 7]]);
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(!qic.networkEnjoysQuorumIntersection());
}

// "quorum intersection 8-org core-and-periphery balanced"
unittest
{
    // This configuration strengthens the previous just a bit by making each of
    // the core orgs have _two_ periphery relationships, in a specific
    // "balanced" pattern of peripheral dependency. The periphery nodes are
    // still able to be satisfied by 3/4 threshold so they can "go with" a core
    // node, but the core nodes have been pushed from 5/7 up to 6/8 which means
    // they need their own 3 nodes + 2 periphery orgs + 1 other core
    // org. Needing two periphery orgs means -- due to the balanced distribution
    // of core/periphery relationships -- that one of those periphery orgs spans
    // any possible split across the core, which means there's quorum
    // intersection in all cases.
    //
    //    org4--------   org5
    //       \        \  /|
    //        org0---org1 |
    //       /  | \ / |   |
    //      |   |  X  |   |
    //      |   | / \ |  /
    //      | org2---org3
    //      |/  \        \
    //    org6   --------org7
    //
    auto orgs = generateOrgs(8, [3, 3, 3, 3, 2, 2, 2, 2]);
    auto qm = interconnectOrgsBidir(
        orgs,
        [// 4 core orgs 0, 1, 2, 3 (with 3 nodes each) which fully depend on one
         // another.
         [0, 1],
         [0, 2],
         [0, 3],
         [1, 2],
         [1, 3],
         [2, 3],
         // 4 "periphery" orgs (with 2 nodes each), each with bidirectional
         // trust with two core orgs, with each pair of core orgs having only
         // one peripheral org in common.
         [0, 4],
         [1, 4],
         [1, 5],
         [3, 5],
         [2, 6],
         [0, 6],
         [3, 7],
         [2, 7]]);
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
}

// quorum intersection 8-org core-and-periphery unbalanced
unittest
{
    // This configuration weakens the previous again, just a _tiny_ bit,
    // by un-balancing the periphery-org structure. It's enough to re-introduce
    // the possibility of splitting though.
    //
    //            -------- org5
    //    org4---/----    /
    //       \  /     \  /
    //        org0---org1
    //          | \ / |
    //          |  X  |
    //          | / \ |
    //        org2---org3
    //       /  \     /  \
    //    org6---\----    \
    //            -------- org7
    //
    auto orgs = generateOrgs(8, [3, 3, 3, 3, 2, 2, 2, 2]);
    auto qm = interconnectOrgsBidir(
        orgs,
        [// 4 core orgs 0, 1, 2, 3 (with 3 nodes each) which fully depend on one
         // another.
         [0, 1],
         [0, 2],
         [0, 3],
         [1, 2],
         [1, 3],
         [2, 3],
         // 4 "periphery" orgs (with 2 nodes each), each with bidirectional
         // trust with two core orgs, with two pairs of core orgs paired to
         // the same two peripherals.
         [0, 4],
         [1, 4],
         [0, 5],
         [1, 5],
         [2, 6],
         [3, 6],
         [2, 7],
         [3, 7]]);
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(!qic.networkEnjoysQuorumIntersection());
}

// quorum intersection 6-org 1-node 4-null qsets
unittest
{
    // Generating the following topology with dependencies from the core nodes
    // org0..org1 bidirectionally to one another, but also one-way outwards to
    // some "unknown nodes" org2..org5, which we don't have qsets for.
    //
    //          org2       org4
    //           ^          ^
    //           |          |
    //          org0 <---> org1
    //           |          |
    //           v          v
    //          org3       org5
    //
    // We build this case to explore the correct inferred over-approximate qsets
    // for org2..org5. We know org0..org1 have threshold 67% = 3-of-4 (4 being
    // "self + 3 neighbours"); the current logic in the quorum intersection
    // checker (see buildGraph and convertSCPQuorumSet) will treat this network
    // as _only_ having 2-nodes and will therefore declare it vacuously enjoying
    // quorum intersection due to being halted.
    //
    // (At other points in the design, and possibly again in the future if we
    // change our minds, we modeled this differently, treating the null-qset
    // nodes as either live-and-unknown, or byzantine; both of those cases
    // split.)

    auto orgs = generateOrgs(6, [1]);
    auto qm = interconnectOrgsUnidir(orgs, [
                                               [0, 1],
                                               [1, 0],
                                               [0, 2],
                                               [0, 3],
                                               [1, 4],
                                               [1, 5],
                                           ]);

    // Mark the last 4 orgs as unknown.
    for (size_t i = 2; i < orgs.length; ++i)
    {
        foreach (node; orgs[i])
        {
            qm[node] = nullquorum;
        }
    }

    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
    assert(qic.getMaxQuorumsFound() == 0);
}

// quorum intersection 4-org 1-node 4-null qsets
unittest
{
    // Generating the following topology with dependencies from the core nodes
    // org0..org1 bidirectionally to one another, but also one-way outwards to
    // some "unknown nodes" org2..org3, which we don't have qsets for.
    //
    //           +-> org2 <-+
    //           |          |
    //          org0 <--> org1
    //           |          |
    //           +-> org3 <-+
    //
    // As with the case before, this represents (to the quorum intersection
    // checker's eyes) a halted network which vacuously enjoys quorum
    // intersection.  But if we were using one of the other models for the
    // meaning of a null qset, it might be different: split in the byzantine
    // case, live and enjoying quorum intersection in the live-and-unknown case.

    auto orgs = generateOrgs(4, [1]);
    auto qm = interconnectOrgsUnidir(orgs, [
                                               [0, 1],
                                               [1, 0],
                                               [0, 2],
                                               [0, 3],
                                               [1, 2],
                                               [1, 3],
                                           ]);

    // Mark the last 2 orgs as unknown.
    for (size_t i = 2; i < orgs.length; ++i)
    {
        foreach (node; orgs[i])
        {
            qm[node] = nullquorum;
        }
    }

    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
    assert(qic.getMaxQuorumsFound() == 0);
}

// quorum intersection 6-org 3-node fully-connected
unittest
{
    auto orgs = generateOrgs(6, [3]);
    auto qm = interconnectOrgs(orgs, (size_t i, size_t j) { return true; });
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
}

// quorum intersection performance scaling test
version (PerformanceTests)  // note: this is a heavy-duty test that takes a long time to finish
unittest
{
    // Same as above but with 3-or-5-own-node orgs, so more possible nodes,
    // bigger search space for performance testing.
    auto orgs = generateOrgs(6);
    auto qm = interconnectOrgs(orgs, (size_t i, size_t j) { return true; });
    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());
}

// we replaced the use of std::pair with a fixed-length array
private size_t first (size_t[2] pair) { return pair[0]; }
private size_t second (size_t[2] pair) { return pair[1]; }

// create a QuorumConfig, convert it to SCPQuorumSet and wrap it in shared_ptr
private shared_ptr!SCPQuorumSet makeSharedQuorumSet (size_t threshold,
    PublicKey[] nodes, QuorumConfig[] quorums)
{
    QuorumConfig qc =
    {
        threshold : threshold,
        nodes : nodes,
        quorums : quorums,
    };

    auto scp = toSCPQuorumSet(qc);
    return makeSharedSCPQuorumSet(scp);
}

/// handy constants
private const xvector!SCPQuorumSet nullvec;

/// ditto
private const shared_ptr!SCPQuorumSet nullquorum;

/// helper conversion for PublicKey => NodeID
private NodeID toStellarKey (PublicKey address)
{
    return NodeID(uint256(address));
}
