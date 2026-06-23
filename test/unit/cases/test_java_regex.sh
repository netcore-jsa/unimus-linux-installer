#!/bin/bash

# Tests supported_java_regex against realistic 'java -version' output.
#
# Note: in production the regex is grepped over the *full* multi-line
# 'java -version' output, where the version also appears on the "(build ...)"
# line preceded by a space - that leading space is what the (?:^| ) anchor
# needs, so positive cases use full multi-line output.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
ROOT="$(cd "${DIR}/../../.." && pwd)";
source "${DIR}/../assert.sh";

# generic.sh defines supported_java_regex (no placeholders, source directly)
source "${ROOT}/target/unimus/os-params/generic.sh";

assert_nonempty "${supported_java_regex}" "supported_java_regex is defined";

java8='openjdk version "1.8.0_362"
OpenJDK Runtime Environment (build 1.8.0_362-b09)
OpenJDK 64-Bit Server VM (build 25.362-b09, mixed mode)';
assert_match "${java8}" "${supported_java_regex}" "accepts OpenJDK 8";

java11='openjdk version "11.0.20" 2023-07-18
OpenJDK Runtime Environment (build 11.0.20+8-post-Ubuntu-1ubuntu1)
OpenJDK 64-Bit Server VM (build 11.0.20+8-post-Ubuntu-1ubuntu1, mixed mode)';
assert_match "${java11}" "${supported_java_regex}" "accepts OpenJDK 11";

java17='openjdk version "17.0.8" 2023-07-18
OpenJDK Runtime Environment (build 17.0.8+7-Debian-1deb12u1)
OpenJDK 64-Bit Server VM (build 17.0.8+7-Debian-1deb12u1, mixed mode, sharing)';
assert_match "${java17}" "${supported_java_regex}" "accepts OpenJDK 17";

java21='openjdk version "21.0.1" 2023-10-17
OpenJDK Runtime Environment (build 21.0.1+12-29)
OpenJDK 64-Bit Server VM (build 21.0.1+12-29, mixed mode, sharing)';
assert_match "${java21}" "${supported_java_regex}" "accepts OpenJDK 21";

corretto17='openjdk version "17.0.9" 2023-10-17 LTS
OpenJDK Runtime Environment Corretto-17.0.9.8.1 (build 17.0.9+8-LTS)
OpenJDK 64-Bit Server VM Corretto-17.0.9.8.1 (build 17.0.9+8-LTS, mixed mode)';
assert_match "${corretto17}" "${supported_java_regex}" "accepts Amazon Corretto 17";

# repo "latest version" lines that install_java greps also carry a leading space
assert_match '  Candidate: 11.0.20+8-1~deb11u1' "${supported_java_regex}" "accepts apt Candidate line";
assert_match 'Version     : 1.8.0.362.b09' "${supported_java_regex}" "accepts yum Version line";

# --- negatives: unsupported / non-java identifiers ---
assert_no_match 'openjdk version "1.7.0_261"' "${supported_java_regex}" "rejects Java 7 version string";
assert_no_match 'java version "1.6.0_45"' "${supported_java_regex}" "rejects Java 6 version string";
assert_no_match 'bash: java: command not found' "${supported_java_regex}" "rejects 'command not found'";

unit_summary;
