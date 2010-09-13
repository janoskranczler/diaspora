#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



require File.dirname(__FILE__) + '/../../spec_helper'

describe User do
   before do
      @user = Factory.create(:user)
      @aspect = @user.aspect(:name => 'heroes')
      @aspect2 = @user.aspect(:name => 'losers')

      @user2 = Factory.create :user
      @user2_aspect = @user2.aspect(:name => 'dudes')

      friend_users(@user, @aspect, @user2, @user2_aspect)

      @user3 = Factory.create :user
      @user3_aspect = @user3.aspect(:name => 'dudes')
      friend_users(@user, @aspect2, @user3, @user3_aspect)
      
      @user4 = Factory.create :user
      @user4_aspect = @user4.aspect(:name => 'dudes')
      friend_users(@user, @aspect2, @user4, @user4_aspect)
   end

    it 'should generate a valid stream for a aspect of people' do
      status_message1 = @user2.post :status_message, :message => "hi", :to => @user2_aspect.id
      status_message2 = @user3.post :status_message, :message => "heyyyy", :to => @user3_aspect.id
      status_message3 = @user4.post :status_message, :message => "yooo", :to => @user4_aspect.id

      @user.receive status_message1.to_diaspora_xml
      @user.receive status_message2.to_diaspora_xml
      @user.receive status_message3.to_diaspora_xml
      @user.reload

      @user.visible_posts(:by_members_of => @aspect).include?(status_message1).should be true
      @user.visible_posts(:by_members_of => @aspect).include?(status_message2).should be false
      @user.visible_posts(:by_members_of => @aspect).include?(status_message3).should be false

      @user.visible_posts(:by_members_of => @aspect2).include?(status_message1).should be false
      @user.visible_posts(:by_members_of => @aspect2).include?(status_message2).should be true
      @user.visible_posts(:by_members_of => @aspect2).include?(status_message3).should be true
    end
end

