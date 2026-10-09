// Copyright 2024 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
/// `sint32`
pub(all) struct SInt(Int) derive(Default, Eq, Debug)

///|
pub impl Show for SInt with fn output(self, logger) {
  logger..write_string("SInt(")..write_object(self.0).write_string(")")
}

///|
pub extend SInt with Default::{default}

///|
#deprecated("Use `==` instead")
pub extend SInt with Eq::{equal}

///|
#deprecated("Use `!=` instead")
pub extend SInt with Eq::{not_equal}

///|
pub extend SInt with @debug.Debug::{to_repr}

///|
pub extend SInt with Show::{to_string, output}

///|
/// `sint64`
pub(all) struct SInt64(Int64) derive(Default, Eq, Debug)

///|
pub impl Show for SInt64 with fn output(self, logger) {
  logger..write_string("SInt64(")..write_object(self.0).write_string(")")
}

///|
pub extend SInt64 with Default::{default}

///|
#deprecated("Use `==` instead")
pub extend SInt64 with Eq::{equal}

///|
#deprecated("Use `!=` instead")
pub extend SInt64 with Eq::{not_equal}

///|
pub extend SInt64 with @debug.Debug::{to_repr}

///|
pub extend SInt64 with Show::{to_string, output}

///|
/// length
pub(all) struct Len(Int) derive(Default, Eq, Debug)

///|
pub impl Show for Len with fn output(self, logger) {
  logger..write_string("Len(")..write_object(self.0).write_string(")")
}

///|
pub extend Len with Default::{default}

///|
#deprecated("Use `==` instead")
pub extend Len with Eq::{equal}

///|
#deprecated("Use `!=` instead")
pub extend Len with Eq::{not_equal}

///|
pub extend Len with @debug.Debug::{to_repr}

///|
pub extend Len with Show::{to_string, output}

///|
/// Enum
pub(all) struct Enum(UInt) derive(Default, Eq, Debug, Hash, Compare, Arbitrary)

///|
pub impl Show for Enum with fn output(self, logger) {
  logger..write_string("Enum(")..write_object(self.0).write_string(")")
}

///|
pub extend Enum with Default::{default}

///|
#deprecated("Use `==` instead")
pub extend Enum with Eq::{equal}

///|
#deprecated("Use `!=` instead")
pub extend Enum with Eq::{not_equal}

///|
pub extend Enum with @debug.Debug::{to_repr}

///|
pub extend Enum with Hash::{hash, hash_combine}

///|
pub extend Enum with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend Enum with @quickcheck.Arbitrary::{arbitrary}

///|
pub extend Enum with Show::{to_string, output}
