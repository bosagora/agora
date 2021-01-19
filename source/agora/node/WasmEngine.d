/*******************************************************************************

    Contains the wasmer WebAssembly engine to be used for Trust Contracts.
    The submodule `wasmer-d` provides a `D` wrapper of the `wamser` runtime.
    (https://chances.github.io/wasmer-d/wasmer.html)

    Copyright:
        Copyright (c) 2021 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.WasmEngine;

import agora.consensus.state.Ledger;
import agora.utils.Log;

import wasmer;

mixin AddLogger!();

/// Ditto
public class WasmEngine
{
    /// The JIT engine for executing WebAssembly Programs (WASM)
    Engine engine;

    /// The global state that can be manipulated by WebAssembly programs
    /// https://webassembly.github.io/spec/core/exec/runtime.html#syntax-store
    Store store;

    Ledger ledger;

    public void start (ref Ledger ledger)
    {
        log.info("Starting WasmEngine");
        engine = new Engine();
        store = new Store(engine);
        this.ledger = ledger;
        log.info("Started WasmEngine");
    }

    public void stop ()
    {
        log.info("Stopping WasmEngine");
        destroy(store);
        destroy(engine);
        log.info("Stopped WasmEngine");
    }

    public void exampleTime ()
    {
        log.info("Running {} using WasmEngine", __FUNCTION__);
        const wat_callback_module_time = "(module
            (type $FUNCSIG$ii (func (param i32) (result i32)))
            (import \"env\" \"time\" (func $time (param i32) (result i32)))
            (table 0 anyfunc)
            (memory $0 1)
            (export \"memory\" (memory $0))
            (export \"main\" (func $main))
            (func $main (; 1 ;) (result i32)
            (call $time
            (i32.const 0)
            )
            )
        )";
        log.trace("wat (text representation of wasm)");
        log.trace("==============================");
        log.trace("{}", wat_callback_module_time);
        log.trace("==============================");
        auto module_ = Module.from(store, wat_callback_module_time);
        assert(module_.valid, "Error compiling module!");

        auto print = (Module module_, int value)
        {
            return value;
        };
        auto imports = [new Function(store, module_, print.toDelegate).asExtern];
        auto instance = module_.instantiate(imports);
        assert(instance.valid, "Could not instantiate module!");
        auto runFunc = Function.from(instance.exports[1]);
        assert(instance.exports[1].name == "main", "Failed to get the `main` function!");
        assert(runFunc.valid, "`main` function invalid!");
        Value[] results;
        assert(runFunc.call(results), "Error calling the `main` function!");
        assert(results.length == 1, "length of results should be 1!");
        // assert(results[0].value.of.i32 > 0, "time should be greater than 0");
        log.info("Used web assembly engine to get time. Result = {}", results[0].value.of.i32);
        destroy(instance);
        destroy(module_);
    }


    public void exampleAdd ()
    {
        const wat_callback_module_add = `
(module
    (func $myFunc (import "" "myFunc") (result i64))
    (func (export "run") (param $x i32) (param $y i32) (result i64)
    (call $myFunc)
    return
    )
)`;
        log.info("Running {} using WasmEngine", __FUNCTION__);
        log.trace("wat (text representation of wasm)");
        log.trace("==============================");
        log.trace("{}", wat_callback_module_add);
        log.trace("==============================");

        auto module_ = Module.from(store, wat_callback_module_add);
        assert(module_.valid, "Error compiling module!");

        // This is for addFromWasm
        // auto funcType = wasm_functype_new_2_1(wasm_valtype_new_i32(),
        //    wasm_valtype_new_i32(), wasm_valtype_new_i32());
        auto funcType = wasm_functype_new_0_1(wasm_valtype_new_i64());

        //auto imports = [new Function(store, funcType, &addFromWasm).asExtern];
        auto imports = [new Function(store, funcType, &getLedgerValidators, cast(void*) this.ledger).asExtern];
        auto instance = module_.instantiate(imports);
        assert(instance.valid, "Could not instantiate module!");
        auto runFunc = Function.from(instance.exports[0]);
        assert(instance.exports[0].name == "run" && runFunc.valid, "Failed to get the `run` function!");

        //{
            // Here we run the "main" function called "run"
            auto three = new Value(3);
            auto four = new Value(4);
            Value[] results;
            assert(runFunc.call([three, four], results), "Error calling the `run` function!");
            assert(results.length == 1);
            //assert(results[0].value.of.i32 == 7);
            log.info("Used web assembly engine to add 3 and 4. Result = {}", results[0].value.of.i32);
        //}

        // Cleanup
        destroy(three);
        destroy(four);
        destroy(instance);
        destroy(module_);
    }
}

unittest
{
    import std.stdio;
    import std.format;

    Log.root.level(LogLevel.Trace, true);
    auto output = stdout.lockingTextWriter();
    try
    {
        auto wasmEngine = new WasmEngine();
        Ledger ledger = new Ledger();
        wasmEngine.start(ledger);
        wasmEngine.exampleAdd();
        //wasmEngine.exampleTime();
        wasmEngine.stop();
    }
    catch (Exception e)
    {
        output.formattedWrite("%s", e);
    }
    // print logs of the work thread
    CircularAppender!()().print(output);
}

extern(C) wasm_trap_t* addFromWasm (const wasm_val_vec_t* args, wasm_val_vec_t* results)
{
    //int addFromWasm (int a, int b)
    int a = args.data[0].of.i32;
    int b = args.data[1].of.i32;
    results.data[0].kind = WASM_I32;
    results.data[0].of.i32 = (a + b);
    log.info("addFromWasm called with: {} + {}", a, b);
    return null;
}

extern(C) wasm_trap_t* getLedgerValidators (void* env, const wasm_val_vec_t* args, wasm_val_vec_t* results)
{
    log.info("getLedgerValidators called");

    Ledger ledger = cast(Ledger) env;
    results.data[0].kind = WASM_I64;
    results.data[0].of.i64 = ledger.getValidators(ledger.height() + 1).length;
    return null;
}
