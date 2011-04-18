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

#Interface javax.jms.QueueBrowser
module JMS::QueueBrowser
  # For each message on the queue call the supplied Proc
  def each(params={}, &block)
    raise "JMS::QueueBrowser::each requires a code block to be executed for each message received" unless block

    e = self.getEnumeration
    while e.hasMoreElements
      block.call(e.nextElement)
    end
  end
end
