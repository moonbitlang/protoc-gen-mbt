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

test "a message" {
  let message = @test.RepeatedMessage::default()
  message.bar_message = [
    @test.BarMessage::{ b_int32: 3 },
    @test.BarMessage::{ b_int32: 2 },
  ]
  let writer = @buffer.new()
  @lib.Write::write(message, writer)
  let bytes = writer.to_bytes()
  assert_eq!(bytes, b"\x0a\x02\x08\x03\x0a\x02\x08\x02")
  let reader = @lib.BytesReader::from_bytes(bytes)
  try {
    let m = (@lib.Read::read!(reader) : @test.RepeatedMessage)
    assert_eq!(m, message)
  } catch {
    e => raise e
  }
}

test "string" {
  let message = @test.FooMessage::default()
  message.f_string = "中文"
  let writer = @buffer.new()
  @lib.Write::write(message, writer)
  let bytes = writer.to_bytes()
  assert_eq!(
    bytes, b"\x08\x00\x10\x00\x18\x00\x20\x00\x28\x00\x30\x00\x38\x00\x40\x00\x49\x00\x00\x00\x00\x00\x00\x00\x00\x51\x00\x00\x00\x00\x00\x00\x00\x00\x5d\x00\x00\x00\x00\x65\x00\x00\x00\x00\x69\x00\x00\x00\x00\x00\x00\x00\x00\x75\x00\x00\x00\x00\x7a\x00\x82\x01\x06\xe4\xb8\xad\xe6\x96\x87\x92\x01\x02\x08\x00\x9a\x01\x00\xa2\x01\x00\xaa\x01\x00\xba\x01\x0a\x0a\x04\x0a\x02\x08\x00\x10\x00\x1a\x00\xc2\x01\x04\x0a\x02\x08\x00\xc8\x01\x00",
  )
  let reader = @lib.BytesReader::from_bytes(bytes)
  try {
    let m = (@lib.Read::read!(reader) : @test.FooMessage)
    assert_eq!(m, message)
  } catch {
    e => raise e
  }
}
