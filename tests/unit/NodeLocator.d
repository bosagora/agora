/*******************************************************************************

    Test GeoIP integration for network crawler

    This test is disabled by default because the GeoIP databases require
    registration to be downloaded (they are free, the registration is solely
    to allow the distributor to notify of any GDPR deletion request).

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module tests.unit.NodeLocator;

import std.process;
import std.stdio;

import agora.network.NodeLocator;

private int main ()
{
    auto path = environment.get("AGORA_GEOIP_PATH");
    if (!path.length)
    {
        stderr.writeln("Skipping ", __FILE_FULL_PATH__, " test because it requires GeoIP databases");
        stderr.writeln("Provide the GeoIP database path via the `AGORA_GEOIP_PATH` environment variable to run it");
        return 0;
    }

    auto node_locator = new NodeLocatorGeoIP(path);
    assert(node_locator.start());
    assert(node_locator.extractValues(
               "211.179.51.66",
               [
                   "continent->names->en",
                   "country->names->en",
                   "city->names->en",
                   "location->latitude",
                   "location->longitude",
                   ]) ==
           ["Asia", "South Korea", "Seoul (Namdaemunno 5(o)-ga)", "37.5562", "126.975"]);
    node_locator.stop();
    return 0;
}
