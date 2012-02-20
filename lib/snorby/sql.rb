# Snorby - All About Simplicity.
# 
# Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'snorby/sql/mysql'
require 'snorby/sql/postgresql'

module Snorby
  module Sql

      def db_adapter
        @adapter ||= DataMapper.repository(:default).adapter
      end

      #
      # DM Select
      #
      def select(sql)
        db_adapter.select(sql)
      end

      #
      # DM Execute
      #
      def execute(sql)
        db_adapter.execute(sql)
      end

      def options
        @options ||= DataMapper.repository.adapter.options
      end


      def self.included(base)
        
        adapter_type = DataMapper.repository.adapter.options[:adapter]

        base.module_eval do
        
          case adapter_type 

          when 'mysql'
              include Snorby::Sql::Mysql
          when 'postgres'
              include Snorby::Sql::Postgresql
          else
            raise 'unknown adapter type: ' + adapter_type
          end

        end

      end

      class SqlHelper
        include Snorby::Sql
      end
      
  end
end
