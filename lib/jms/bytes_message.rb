################################################################################
#  Copyright 2008, 2009, 2010, 2011  J. Reid Morrison
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################

#Interface javax.jms.BytesMessage
module JMS::BytesMessage
  def data
    # Puts the message body in read-only mode and repositions the stream of
    # bytes to the beginning
    self.reset

    available = self.body_length

    return nil if available == 0

    result = ""
    bytes_size = 1024
    bytes = Java::byte[bytes_size].new

    while (n = available < bytes_size ? available : bytes_size) > 0
      self.read_bytes(bytes, n)
      if n == bytes_size
        result << String.from_java_bytes(bytes)
      else
        result << String.from_java_bytes(bytes)[0..n-1]
      end
      available -= n
    end
    result
  end

  def data=(val)
    self.write_bytes(val.respond_to?(:to_java_bytes) ? val.to_java_bytes : val)
  end

  def to_s
    data
  end

end
