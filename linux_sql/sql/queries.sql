--Group hosts by hardware info
SELECT
    cpu_number,
    id as host_id,
    total_mem
FROM host_info
GROUP BY cpu_number
ORDER BY total_mem DESC;


--Average memory usage
SELECT
    host_usage.host_id,
    host_info.hostname as host_name,
    (date_trunc('hour', host_usage.timestamp) + INTERVAL '5 min' * ROUND(date_part('minute', host_usage.timestamp) / 5.0)) as timestamp,
    AVG(((host_info.total_mem - (host_usage.memory_free * 1024)) * 100) / host_info.total_mem) OVER (
        PARTITION BY host_usage.host_id
        ORDER BY
            host_usage.timestamp
    ) as avg_used_mem_percentage
FROM host_usage
INNER JOIN host_info
ON host_info.id = host_usage.host_id;
