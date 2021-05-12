function http_add_message(tag, timestamp, record)
    if record["http_request_method"] ~= nil and
        record["http_request_path"] ~= nil and
        record["http_response_status_code"] ~= nil then
        record["message"] = record["http_request_method"] .. " " .. record["http_response_status_code"] .. " " .. record["http_request_path"]
    end
    return 1, timestamp, record
end
function convert_ms_to_s(tag, timestamp, record)
   -- Record modified, transform from miliseconds to seconds
   if record["http_response_duration"] ~= nil then
     record["http_response_duration"] = (record["http_response_duration"] / 1000)
   elseif record["tcp_response_duration"] ~= nil then
     record["tcp_response_duration"] = (record["tcp_response_duration"] / 1000)
   end
   return 1, timestamp, record
 end
