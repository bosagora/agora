/*******************************************************************************

    Apply version upgrades to a node

    To allow for a smooth upgrade path for Agora node, there is a built-in
    upgrade system: When a node starts, it checks a specific table in stateDB,
    and gradually run upgrade scripts as needed.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Versioning;

import agora.common.Config;
import agora.common.Ensure;
import agora.common.ManagedDatabase;
import agora.node.BlockStorage;
import agora.utils.Log;

import semver;

import std.path;

/*******************************************************************************

    Apply all required version upgrades to the state

    This is called from the FullNode's constructor after all the state handling
    members (`stateDB`, `cacheDB`, block `storage`) have been initialized.

    If any upgrade is needed at all (the version stored in the metadata
    table is different from the one we're running), we apply the required
    fix(es). This process can also handle downgrades.

    The logger is also initialized so we can provide feedback to the user.
    The config has already been parsed, so any fix needed would need to
    happen in two steps (one version allowing the new syntax and doing the
    fix, then a new version rejecting the old syntax).

    Params:
      stateDB = The node's `stateDB`, holding the blockchain state
      cacheDB = The node's `cacheDB`, holding the node's cached data
      storage = The node's block storage, holding known blocks
      current = The version we are currently running, as read from
                the version file
      config  = The parsed configuration
      log     = Logger to output any message to, if any

    Throws:
      If an error happened during the upgrade, as we don't want to continue
      and throw random errors to the user in a seemingly unrelated place.

    ***************************************************************************/

package void applyVersionDifferences (
    ManagedDatabase stateDB, ManagedDatabase cacheDB, IBlockStorage storage,
    string current, in Config config, Logger log)
{
    // We currently use this in a few places, allow for a transition period
    if (current == "HEAD")
    {
        log.info("Current version is set to HEAD - cannot check for upgrades");
        return;
    }

    void printFatalMessages ()
    {
        log.fatal("Cannot continue initialization - State DB is in an inconsistent state");
        log.fatal("Please fix your installation if possible, or remove {} ",
                  config.node.data_dir.buildPath("state.db"));
        log.fatal("This will rebuild your blockchain state from scratch, and may take some time");
        log.fatal("It is recommended to also remove the cache DB at {} if the state DB is removed",
                  config.node.data_dir.buildPath("state.db"));
        log.fatal("If you believe this is an issue with Agora, please report an issue at " ~
                  "https://github.com/bosagora/agora/");
    }

    const vers = SemVer(current);
    ensure(vers.isValid, "Version '{}' is not a valid version", current);

    const exists = stateDB.execute(
        "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='metadata'")
        .oneValue!int;

    // TODO: Remove once v0.17.0 has been deployed and all nodes have a metadata table
    version (none)
    {
        if (!exists)
        {
            stateDB.execute("CREATE TABLE metadata (key TEXT UNIQUE NOT NULL, value TEXT NOT NULL)");
            stateDB.setMetadataVersion(current);
            return;
        }
    }
    else
    {
    if (!exists)
    {
        // If the `metadata` table doesn't exists, it means either the DB
        // is compromised or this is the first run - Let's check if it's the later.
        const tables = stateDB.execute(
            "SELECT COUNT(*) FROM sqlite_master WHERE type='table'")
            .oneValue!int;

        if (tables == 0)
        {
            // Create it and return, since there is no existing state
            stateDB.execute("CREATE TABLE metadata (key TEXT UNIQUE NOT NULL, value TEXT NOT NULL)");
            stateDB.setMetadataVersion(current);
            return;
        }

        log.fatal("No 'metadata' table exists in stateDB, but stateDB has {} tables!", tables);
        printFatalMessages();
        ensure(false, "Could not determine previous state of the node - Check logs for more infos");
    }
    }

    auto results = stateDB.execute("SELECT value FROM metadata WHERE key='version'");
    if (results.empty())
    {
        printFatalMessages();
        ensure(false, "Could not find version information in metadata table - Check logs for more infos");
    }
    const oldVersStr = results.oneValue!string;
    const oldVers = SemVer(oldVersStr);
    if (!oldVers.isValid())
    {
        printFatalMessages();
        ensure(false, "Version stored in metadata ({}) is not a valid version - " ~
               "Check logs for more infos", oldVersStr);
    }

    // Most common case, do not output any message
    if (oldVers == vers) return;

    if (oldVers < vers)
    {
        const size_t upgrades = 1;
        log.info("Need to apply {} upgrades from {} to {}", upgrades, oldVers, vers);
    }
    else
    {
        const size_t downgrades = 1;
        log.info("Need to apply {} downgrades from {} to {}", downgrades, oldVers, vers);
    }
    stateDB.setMetadataVersion(current);
}

/// Set the current version in the metadata
private void setMetadataVersion (ManagedDatabase stateDB, string version_)
{
    stateDB.execute("INSERT OR REPLACE INTO metadata (key, value) VALUES ('version', ?)", version_);
}
