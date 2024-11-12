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
  let writer = @buffer.Buffer::new()
  @lib.Write::write(message, writer)
  let bytes = writer.to_bytes()
  assert_eq!(bytes, b"\x0a\x02\x08\x03\x0a\x02\x08\x02")
  let reader = @lib.BytesReader::from_bytes(bytes)
  try {
    (@lib.Read::read!(reader) : @test.RepeatedMessage)
  } catch {
    _ => ()
  } else {
    m => assert_eq!(m, message)
  }
}
