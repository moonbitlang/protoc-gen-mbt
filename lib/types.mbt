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
pub(all) struct SInt(Int) derive(Default, Eq)

///|
pub impl Show for SInt with output(self, logger) {
  logger..write_string("SInt(")..write_object(self.0).write_string(")")
}

///|
/// `sint64`
pub(all) struct SInt64(Int64) derive(Default, Eq)

///|
pub impl Show for SInt64 with output(self, logger) {
  logger..write_string("SInt64(")..write_object(self.0).write_string(")")
}

///|
/// length
pub(all) struct Len(Int) derive(Default, Eq)

///|
pub impl Show for Len with output(self, logger) {
  logger..write_string("Len(")..write_object(self.0).write_string(")")
}

///|
/// Enum
pub(all) struct Enum(UInt) derive(Default, Eq)

///|
pub impl Show for Enum with output(self, logger) {
  logger..write_string("Enum(")..write_object(self.0).write_string(")")
}
