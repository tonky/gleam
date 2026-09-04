// SPDX-FileCopyrightText: 2026 Gleam Contributors
// SPDX-License-Identifier: Apache-2.0

package devshell

import (
	"github.com/tonky/enve/schema/v1:schema"
	"github.com/tonky/enve/schema/v1/env:env"
	"github.com/tonky/enve/pkgs:pkgs"
)

// -------------------------------------------------------------
// Declarative Gleam Compiler Developer Environment
// -------------------------------------------------------------

devEnv: schema.#DevEnvironment & {
	name: "gleam-compiler-dev-environment"
	build: schema.#RustBuildSpec & {
		pname:   "gleam"
		version: "1.8.1"
		src:     "."
	}
	tools: [
		pkgs.erlang,
		pkgs.elixir,
		pkgs.hex,
		pkgs.rebar3,
		pkgs.nodejs,
		pkgs.bun,
		pkgs.deno,
		pkgs.watchexec,
		pkgs.typescript,
		pkgs.just,
		pkgs.gcc,
		pkgs.mold,
		pkgs.binutils,
		pkgs.gnumake,
		pkgs.procps,
		pkgs.bat,
		pkgs.ripgrep,
		pkgs.git,
	]
	environment: env.#Rust1_80Env & env.#ErlangEnv & env.#GleamEnv & env.#PosixEnv & {
		CC:                                           "gcc"
		CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER:   "gcc"
		CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUSTFLAGS: "-C link-arg=-fuse-ld=mold"
		GLEAM_LOG:                                    "trace"
		RUST_BACKTRACE:                               1
		PAGER:                                        "less"
		ELIXIR_ERL_OPTIONS:                           "+fnu"
		LC_ALL:                                       "C.UTF-8"
		LANG:                                         "C.UTF-8"
		HEX_OFFLINE:                                  1
	}
	shellHook: """
		mix local.hex --force >/dev/null 2>&1 || true
		mix local.rebar --force >/dev/null 2>&1 || true
		echo "========================================================================"
		echo " 🌟 Welcome to the Gleam Compiler Developer Environment (enve)          "
		echo "    Toolchains: Rust, Erlang, Elixir, GCC, Mold, Node, Deno, Bun, TS   "
		echo "    Automation: run 'just' to list available tasks                      "
		echo "========================================================================"
		"""
}

// -------------------------------------------------------------
// WASM Developer Environment Profile (`enve develop --env wasm`)
// -------------------------------------------------------------

wasmEnv: schema.#DevEnvironment & {
	name: "gleam-wasm-dev-environment"
	build: devEnv.build
	tools: [
		pkgs.cargo,
		pkgs.rustc,
		pkgs.rust_analyzer,
		pkgs.wasm_pack,
		pkgs.binaryen,
		pkgs.clang,
		pkgs.lld,
		pkgs.gcc,
		pkgs.nodejs,
		pkgs.just,
		pkgs.gnumake,
		pkgs.git,
	]
	environment: env.#Rust1_80Env & env.#PosixEnv & env.#WasmEnv
}

// -------------------------------------------------------------
// CI Profile (`enve run --env ci -- just test`)
// -------------------------------------------------------------

ciEnv: schema.#DevEnvironment & {
	name:  "gleam-ci-environment"
	build: devEnv.build
	tools: devEnv.tools
	environment: env.#Rust1_80Env & env.#PosixEnv & {
		CI:             1
		RUST_BACKTRACE: 1
		RUST_LOG:       "info"
		GLEAM_LOG:      "info"
	}
}

// -------------------------------------------------------------
// Erlang Version Matrix Profiles (`--env otp27|otp28`)
// -------------------------------------------------------------

otp27Env: schema.#DevEnvironment & {
	name:  "gleam-otp27-dev-environment"
	build: devEnv.build
	tools: [
		pkgs.erlang_27,
		pkgs.elixir,
		pkgs.hex,
		pkgs.rebar3,
		pkgs.bun,
		pkgs.deno,
		pkgs.watchexec,
		pkgs.typescript,
		pkgs.just,
		pkgs.bat,
		pkgs.ripgrep,
	]
	environment: devEnv.environment
}

otp28Env: schema.#DevEnvironment & {
	name:  "gleam-otp28-dev-environment"
	build: devEnv.build
	tools: [
		pkgs.erlang_28,
		pkgs.elixir,
		pkgs.hex,
		pkgs.rebar3,
		pkgs.bun,
		pkgs.deno,
		pkgs.watchexec,
		pkgs.typescript,
		pkgs.just,
		pkgs.bat,
		pkgs.ripgrep,
	]
	environment: devEnv.environment
}
