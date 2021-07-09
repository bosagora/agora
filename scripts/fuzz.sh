#!/bin/sh

cd ${FUZZER_WORK_DIR}
# compile spec
dotnet ${RESTLER_BIN_DIR}/Restler.dll compile --api_spec ${SPEC_DIR}/spec.yaml

dotnet ${RESTLER_BIN_DIR}/Restler.dll fuzz --grammar_file "Compile/grammar.py" --dictionary_file "Compile/dict.json" \
    --settings ${FUZZER_SETTINGS} --time_budget 1 --target_ip ${FUZZ_TARGET_IP} --target_port ${FUZZ_TARGET_PORT} \
    --host ${FUZZ_TARGET_HOST}
