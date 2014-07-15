curl -u ${FLOOD_API_TOKEN}: https://api.flood.io/grids \
  -F "grid[region]=ap-southeast-2" \
  -F "grid[infrastructure]=demand" \
  -F "grid[instance_quantity]=10" \
  -F "grid[stop_after]=60"
