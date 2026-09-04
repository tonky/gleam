# SPDX-FileCopyrightText: 2026 Gleam Contributors
# SPDX-License-Identifier: Apache-2.0

# Gleam Compiler Automation Workflows (Justfile)
# Run `just` or `just --list` to inspect available recipes

default:
    @just --list

# -----------------------------------------------------------------------------
# Core Build & Code Quality
# -----------------------------------------------------------------------------

# Build the Gleam compiler in release mode
build:
    cargo build --release

# Build the Gleam compiler and place it on PATH
install:
    cargo install --path gleam-bin --force --locked

# Run Clippy linter on the compiler codebase
check:
    cargo clippy

# Check formatting across the compiler codebase
fmt:
    cargo fmt --all -- --check

# Format all Rust files in the codebase
fmt-fix:
    cargo fmt --all

# -----------------------------------------------------------------------------
# Unit & Rust Compiler Tests
# -----------------------------------------------------------------------------

# Run compiler Rust unit and integration tests
test-unit:
    cargo test --quiet

# Run compiler performance benchmarks
bench:
    cd benchmark/list && cargo run --quiet -- run

# Continuously run compiler tests on source changes
watch-unit:
    watchexec -e rs,toml,gleam,html "cargo test --quiet"

# -----------------------------------------------------------------------------
# Language Target Spec Tests (test/language)
# -----------------------------------------------------------------------------

# Run language test suite targeting Erlang
test-lang-erlang:
    cd test/language && cargo run --quiet -- clean && cargo run --quiet -- test --target erlang

# Run language test suite targeting JavaScript (Node.js)
test-lang-node:
    cd test/language && cargo run --quiet -- clean && cargo run --quiet -- test --target javascript --runtime nodejs

# Run language test suite targeting JavaScript (Deno)
test-lang-deno:
    cd test/language && cargo run --quiet -- clean && cargo run --quiet -- test --target javascript --runtime deno

# Run language test suite targeting JavaScript (Bun)
test-lang-bun:
    cd test/language && cargo run --quiet -- clean && cargo run --quiet -- test --target javascript --runtime bun

# Run language test suite on all supported targets (Erlang, Node.js, Deno, Bun)
test-lang: test-lang-erlang test-lang-node test-lang-deno test-lang-bun

# Continuously run language test suite on file changes
watch-lang:
    watchexec "cd test/language && cargo run --quiet -- test --target erlang"

# -----------------------------------------------------------------------------
# Project Integration Tests
# -----------------------------------------------------------------------------

# Run Erlang project integration tests
test-proj-erlang:
    cd test/project_erlang && cargo run -- clean && cargo run -- check && cargo run -- test

# Run JavaScript (Node.js) project integration tests
test-proj-node:
    cd test/project_javascript && cargo run -- clean && cargo run -- check && cargo run -- test

# Run Deno project integration tests
test-proj-deno:
    cd test/project_deno && cargo run -- clean && cargo run -- check && cargo run -- test

# Run all project-level integration test fixtures
test-proj: test-proj-erlang test-proj-node test-proj-deno

# Run JavaScript prelude core tests
test-prelude:
    cd test/javascript_prelude && cp ../../compiler-core/templates/prelude.mjs prelude.mjs && node main.mjs && rm -f prelude.mjs

# Check that generated TypeScript declarations compile
test-types:
    cd test/typescript_declarations && cargo run --quiet -- build && bunx tsc ./main.ts --strict --noEmit --skipLibCheck false --lib es2020,dom && bunx tsc ./typescript_is_overload.ts --strict --noEmit --skipLibCheck false --lib es2020,dom

# Run gleam export hex-tarball and verify tarball creation
test-hex:
    cd test/hextarball && cargo run -- clean && cargo run -- export hex-tarball

# -----------------------------------------------------------------------------
# WebAssembly (WASM)
# -----------------------------------------------------------------------------

# Build Gleam compiler to WebAssembly via wasm-pack
build-wasm:
    wasm-pack build --target web compiler-wasm

# Run WebAssembly compiler tests
test-wasm:
    unset CC && wasm-pack test --node compiler-wasm

# -----------------------------------------------------------------------------
# Top-Level Complete Test Pipeline
# -----------------------------------------------------------------------------

# Run complete test suite across all compiler and target matrices
test: test-unit check test-lang test-proj test-prelude test-types test-hex
