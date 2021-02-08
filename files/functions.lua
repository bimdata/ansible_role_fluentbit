function convert_ms_to_s(tag, timestamp, record)
   -- Record modified, transform from miliseconds to seconds
   if record["http_response_duration"] ~= nil then
     record["http_response_duration"] = (record["http_response_duration"] / 1000)
   elseif record["tcp_response_duration"] ~= nil then
     record["tcp_response_duration"] = (record["tcp_response_duration"] / 1000)
   end
   return 1, timestamp, record
 end
