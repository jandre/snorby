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

module Snorby
  module Sql 
    module Postgresql
      
      def latest_five_distinct_signatures
        sql = %{
          select distinct signature
          from (select signature, timestamp from event
          order by timestamp desc
          ) a
          limit 5;
        }

        select(sql)
      end


      def update_signature_count
        sql = %{
          update signature set events_count = (select count(*) as count
          from event where event.signature = signature.sig_id);
        }
 
        execute(sql)
      end
 
      def has_timestamp_index?
        sql = %{
          SELECT * FROM pg_class c, pg_class c2, pg_index i
          WHERE c.oid = (SELECT oid FROM pg_class WHERE relname ~ '^(event)$')
          AND c.oid = i.indrelid
          AND i.indexrelid = c2.oid
          AND c2.relname = 'index_timestamp_cid_sid' limit 1
        }
        !select(sql).empty?
      end

      def install_inet_ntoa
        # install inet_ntoa if not present.
        sql = %{
          CREATE OR REPLACE FUNCTION INET_NTOA(bigint) RETURNS inet STRICT IMMUTABLE AS $$ SELECT '0.0.0.0'::inet+$1 $$ LANGUAGE SQL;
          CREATE OR REPLACE FUNCTION INET_NTOA(int) RETURNS inet STRICT IMMUTABLE AS $$ select '0.0.0.0'::inet+$1 $$ LANGUAGE SQL;
        }
        
        execute(sql)
      end

      def validate_cache_indexes
        unless has_timestamp_index?
          execute("create index index_timestamp_cid_sid on  event (  timestamp,  cid, sid );")
        end
      end

      def setup_db
        validate_cache_indexes
        install_inet_ntoa
      end
 
      def sql_min_max
        sql = %{
          select min(cid), max(cid) from event 
          where 
          timestamp >= '#{@stime}' and timestamp < '#{@etime}' 
          and sid = #{@sensor.sid.to_i};
        } 
 
        select(sql)
      end
 
      def sql_event_count
        sql = %{
          select count(*) as "count(*)" from event 
          where sid = #{@sensor.sid.to_i} and timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}'
        }
 
        select(sql)
      end
 
      def sql_signature
        sql = %{
          select signature, sig_name, c as "count(*)" from
          (select signature,  count(*) as c from event  
          join signature  on event.signature = signature.sig_id  
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}' 
          and sid = #{@sensor.sid.to_i}
          group by signature) a 
          inner join signature b on a.signature = b.sig_id
        }
 
        select(sql)
      end
      
      def sql_source_ip
        sql = %{
          select INET_NTOA(ip_src) as "INET_NTOA(ip_src)", count(*) as "count(*)" from event  
          inner join iphdr on event.cid  = iphdr.cid 
          and event.sid = iphdr.sid where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}'
          and event.sid = #{@sensor.sid.to_i}
          group by INET_NTOA(ip_src); 
        }
 
        select(sql)
      end
 
      def sql_destination_ip
        sql = %{
          select INET_NTOA(ip_dst) as "INET_NTOA(ip_dst)", count(*) as "count(*)" from event 
          inner join iphdr on event.cid  = iphdr.cid 
          and event.sid = iphdr.sid where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}'
          and event.sid = #{@sensor.sid.to_i}
          group by INET_NTOA(ip_dst); 
        }
 
        select(sql)
      end
 
      def sql_severity
        sql = %{
          select sig_priority, count(*) as "count(*)" from event  
          inner join signature on event.signature = signature.sig_id 
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}'
          and event.sid = #{@sensor.sid.to_i}
          group by sig_priority; 
        }
 
        select(sql)
      end
 
      def sql_sensor
        sql = %{
          select sid, count(*) as "count(*)" from event   
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}'
          and event.sid = #{@sensor.sid.to_i}
          group by sid; 
        }
 
        select(sql)
      end
 
      def sql_tcp
        sql = %{
          select   count(*) as "count(*)" from event  
          inner join tcphdr on event.cid  = tcphdr.cid 
          and event.sid = tcphdr.sid
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}' and event.sid = #{@sensor.sid.to_i};
        }
 
        select(sql)
      end
 
      def sql_udp
        sql = %{
          select   count(*) as "count(*)" from event 
          inner join udphdr on event.cid  = udphdr.cid 
          and event.sid = udphdr.sid
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}' and event.sid = #{@sensor.sid.to_i};
        }
 
        select(sql)
      end
 
      def sql_icmp
        sql = %{
          select   count(*) as "count(*)" from event  
          inner join icmphdr on 
          event.cid  = icmphdr.cid and event.sid = icmphdr.sid 
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}' and event.sid = #{@sensor.sid.to_i};
        }
 
        select(sql)
      end

    end
  end
end
