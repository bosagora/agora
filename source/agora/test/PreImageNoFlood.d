/*******************************************************************************

    Test for the flood of the posting pre-images not happening

    Copyright:
        Copyright (c) 2019-2022 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.PreImageNoFlood;

version (unittest):

import agora.consensus.data.PreImageInfo;
import agora.test.Base;

import core.atomic;
import core.thread;

/// A validator should not receive the `postPreimage` calls after it has
/// already received the same pre-images so that the flood of the posting
/// pre-images does not happen.
unittest
{
    static class CustomValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        // The pointer to the number of the times the `postPreimage` is called
        private shared int* post_preimage_count;

        ///
        public this (Parameters!(TestValidatorNode.__ctor) args,
            shared(int)* count)
        {
            this.post_preimage_count = count;
            super(args);
        }

        /// This overridden function counts the number to be called
        public override Height postPreimage (in PreImageInfo preimage) @safe
        {
            atomicOp!("+=")(*this.post_preimage_count, 1);
            return super.postPreimage(preimage);
        }
    }

    static class CustomAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        // The number of times the `postPreimage` is called
        public static shared int post_preimage_count;

        /// set base class
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
                this.addNewNode!CustomValidator(conf, &post_preimage_count,
                    file, line);
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf config;
    auto network = makeTestNetwork!CustomAPIManager(config);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    network.generateBlocks(Height(1));

    // The count of calling `postPreimage` does not change after a while
    Thread.sleep(config.preimage_reveal_interval);
    auto prev_post_count = atomicLoad(CustomAPIManager.post_preimage_count);
    Thread.sleep(config.preimage_reveal_interval * 2);
    assert(atomicLoad(CustomAPIManager.post_preimage_count) ==
        prev_post_count);
}

/// A validator should retrieve the pre-images even when the `postPreimage`
/// does not work or the validator misses some pre-images. And the network
/// must generate a block at the height of the `conf.max_preimage_reveal`
/// plus one.
unittest
{
    static class CustomValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        /// It makes the situation where a node receives no pre-image
        public override Height postPreimage (in PreImageInfo preimage) @safe
        {
            return preimage.height;
        }
    }

    static class CustomAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        /// set base class
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
                this.addNewNode!CustomValidator(conf);
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf;
    auto network = makeTestNetwork!CustomAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    network.generateBlocks(Height(conf.max_preimage_reveal + 1));
}
